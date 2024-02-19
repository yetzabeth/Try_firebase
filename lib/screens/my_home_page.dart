import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  String _currentAddress = 'Ubicación desconocida';
  LatLng _initialCameraPosition = const LatLng(0, 0);
  bool _isLocationLoaded = false;
  final TextEditingController _searchController = TextEditingController();
  List<AutocompletePrediction>? _places;
  late LocationService _locationService;
  late PlacesService _placesService;
  late GooglePlace googlePlace; // Define googlePlace aquí

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _placesService =
        PlacesService("AIzaSyA9qvrnsVxG7t_3unWiOG3OOZN0qwGbOFE"); 
    googlePlace = GooglePlace(
        "AIzaSyA9qvrnsVxG7t_3unWiOG3OOZN0qwGbOFE"); // Inicializa googlePlace
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _getCurrentLocation();
            },
            child: const Text('Actualizar ubicación'),
          ),
          const SizedBox(height: 20),
          Text(
            'Ubicación actual: $_currentAddress',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLocationLoaded
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialCameraPosition,
                      zoom: 16,
                    ),
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('userLocation'),
                        position: _initialCameraPosition,
                      ),
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar profesionales',
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchPlaces();
                  },
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: _places != null
                ? ListView.builder(
                    itemCount: _places!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_places![index].description ?? ''),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      String address = await _locationService.getCurrentAddress(position);
      setState(() {
        _currentAddress = address;
        _initialCameraPosition = LatLng(
          position.latitude,
          position.longitude,
        );
        _isLocationLoaded = true;
      });
    } catch (e) {
      print("Error obtaining current location: $e");
    }
  }

  Future<void> _searchPlaces() async {
    try {
      if (_searchController.text.isNotEmpty) {
        final places = await googlePlace.autocomplete.get( // Utiliza googlePlace
          _searchController.text,
          types: 'geocode',
          language: 'es',
        );
        setState(() {
          _places = places!.predictions;
        });
      }
    } catch (e) {
      print("Error searching places: $e");
    }
  }
}
