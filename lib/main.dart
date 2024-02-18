import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

// Importa el archivo de mapeo de códigos postales con zonas
import 'zonas_codigos_postales.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
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
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                String address = await _getCurrentAddress(position);
                setState(() {
                  _currentAddress = address;
                  _initialCameraPosition = LatLng(
                    position.latitude,
                    position.longitude,
                  );
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
                ? SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: GoogleMap(
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
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Future<String> _getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      // Obtener el nombre del barrio o zona
      String subLocality = place.subLocality ?? '';
      String subLocalityText = subLocality.isNotEmpty ? '$subLocality, ' : '';

      // Obtener la dirección en una línea
      String addressLine = place.street ?? '';
      String locality = place.locality ?? '';
      String postalCode = place.postalCode ?? '';
      String address = '${addressLine.isNotEmpty ? '$addressLine, ' : ''}${subLocalityText.isNotEmpty ? subLocalityText : ''}${locality.isNotEmpty ? '$locality, ' : ''}${postalCode.isNotEmpty ? '$postalCode, ' : ''}${place.country}';

      // Obtener la zona basada en el código postal
      List<String> zones = postalCode.isNotEmpty ? _mapPostalCodeToZone(postalCode) : ["Desconocida"];

      // Concatenar la dirección completa
      return "$address\nZonas: ${zones.join(", ")}";
    } catch (e) {
      return "No se pudo obtener la dirección: $e";
    }
  }

  // Método para mapear el código postal a una lista de zonas
  List<String> _mapPostalCodeToZone(String postalCode) {
    // Lista para almacenar las zonas encontradas
    List<String> foundZones = [];

    // Itera sobre cada entrada en el mapa zonasCodigosPostales
    for (var departamento in zonasCodigosPostales.values) {
      // Itera sobre cada lista de códigos postales del departamento
      for (var codigos in departamento.values) {
        // Si la lista de códigos contiene el código postal actual, agrega la zona a la lista de zonas encontradas
        if (codigos.contains(postalCode)) {
          // Encuentra la zona correspondiente al código postal
          var zona = departamento.keys.firstWhere((key) => departamento[key] == codigos);
          foundZones.add(zona);
        }
      }
    }
    return foundZones;
  }
}
