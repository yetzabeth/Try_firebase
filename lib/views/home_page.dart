import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/location_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocationController _locationController = LocationController();
  String _currentAddress = 'Ubicación desconocida';
  LatLng _initialCameraPosition = const LatLng(0, 0);
  bool _isLocationLoaded = false;

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
            onPressed: () async {
              var status = await Permission.location.request();
              if (status.isGranted) {
                var position = await _locationController.getCurrentLocation();
                setState(() {
                  _currentAddress = position.address;
                  _initialCameraPosition = position.position;
                  _isLocationLoaded = true;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Se requiere permiso de ubicación.'),
                  ),
                );
              }
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
                    markers: {
                      Marker(
                        markerId: const MarkerId('userLocation'),
                        position: _initialCameraPosition,
                      ),
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
