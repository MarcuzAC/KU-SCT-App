// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class MapPage extends StatefulWidget {
  const MapPage({super.key, required String destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng kasungu = LatLng(-13.032833, 33.483211);
  static const LatLng linga = LatLng(-13.063228, 33.438791);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {}; // Set of polylines to display on the map

  @override
  void initState() {
    super.initState();
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
    _getDirections();
  }

  // Function to get directions from Google Directions API
  Future<void> _getDirections() async {
    final String apiKey =
        dotenv.env['GOOGLE_MAPS_API_KEY'] ?? ''; // Fetch from .env file
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
        final legs = route['legs'][0];
        final steps = legs['steps'];

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
    } else {
      throw Exception('Failed to load directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View with Route'),
        backgroundColor: const Color(0xFF4CAF50), // Green color for the AppBar
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: kasungu, zoom: 13),
        markers: _markers, // Set of markers
        polylines: _polylines, // Set of polylines for the route
        mapType: MapType.normal, // Standard map type
      ),
    );
  }
}
