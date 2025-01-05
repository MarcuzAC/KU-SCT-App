// ignore_for_file: use_super_parameters, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _places = [];
  Location locationController = Location();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // Function to load locations from SharedPreferences
  _loadLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load the stored locations, but if there are none, start with predefined locations
    setState(() {
      _places = prefs.getStringList('places') ?? ['Kasungu', 'Linga'];
    });
  }

  // Function to save locations to SharedPreferences
  _saveLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('places', _places);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Destination',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Roboto', // Custom font
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 6.0, // More elevation for depth
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where would you like to go?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose a destination from the list below:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the map page with selected destination
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            destination: _places[index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white,
                      shadowColor: Colors.green.shade200,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          _places[index],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            // Allow the user to edit the location name
                            String? newName =
                                await _showEditDialog(context, _places[index]);
                            if (newName != null && newName.isNotEmpty) {
                              setState(() {
                                _places[index] = newName;
                                _saveLocations(); // Save the updated list
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add Location button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: _addLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Add Your Location',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch the user's current location and add it to the list
  Future<void> _addLocation() async {
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

    LocationData currentLocation = await locationController.getLocation();

    // Add the new location to the list with a default name
    setState(() {
      _places.add(
          'Your Location: ${currentLocation.latitude}, ${currentLocation.longitude}');
      _saveLocations(); // Save the updated list
    });
  }

  // Function to show a dialog for editing the name of the location
  Future<String?> _showEditDialog(
      BuildContext context, String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Location Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new location name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text); // Return the new name
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
