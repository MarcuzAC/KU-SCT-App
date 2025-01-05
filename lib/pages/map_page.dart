// ignore_for_file: prefer_const_constructors, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final String destination;

  const MapPage({super.key, required this.destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location locationController = Location();

  static const LatLng kasungu = LatLng(-13.032833, 33.483211);
  static const LatLng linga = LatLng(-13.063228, 33.438791);

  LatLng? currentP;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _getDirections();
    _getLocationUpdates();
  }

  void _initializeMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('kasungu'),
        position: kasungu,
        infoWindow: InfoWindow(
          title: 'Kasungu',
          snippet: 'A great place to visit!',
        ),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('linga'),
        position: linga,
        infoWindow: InfoWindow(
          title: 'Linga',
          snippet: 'Another wonderful destination!',
        ),
      ),
    );
  }

  Future<void> _getDirections() async {
    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print("API Key is missing.");
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${kasungu.latitude},${kasungu.longitude}&destination=${linga.latitude},${linga.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];

      if (routes.isNotEmpty) {
        final route = routes[0];
        if (route['legs'] != null && route['legs'][0]['steps'] != null) {
          final steps = route['legs'][0]['steps'];

          List<LatLng> routeCoords = [];
          for (var step in steps) {
            final lat = step['end_location']['lat'];
            final lng = step['end_location']['lng'];
            routeCoords.add(LatLng(lat, lng));
          }

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: routeCoords,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        }
      }
    } else {
      print('Failed to load directions: ${response.reasonPhrase}');
    }
  }

  Future<void> _getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View with Route'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: kasungu,
              zoom: 13,
            ),
            markers: {
              ..._markers,
              if (currentP != null)
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: currentP!,
                  infoWindow: const InfoWindow(
                    title: 'Your Location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
            },
            polylines: _polylines,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              if (currentP != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(currentP!),
                );
              }
            },
          ),
          if (currentP == null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(width: 8.0),
                        Text('Getting your location...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
