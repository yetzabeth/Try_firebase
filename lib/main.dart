import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const myHomePage = MyHomePage();
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: myHomePage,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentAddress = 'Ubicación desconocida';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                var status = await Permission.location.request(); // Solicitar permiso de ubicación
                if (status.isGranted) {
                  // Si se otorga el permiso de ubicación, obtener la ubicación actual
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  // ignore: use_build_context_synchronously
                  String address = await _getCurrentAddress(position, context); // Pasar el contexto aquí
                  setState(() {
                    _currentAddress = address;
                  });
                } else {
                  // Si no se otorga el permiso, mostrar un mensaje de error
                  // ignore: use_build_context_synchronously
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
            Text('Ubicación actual: $_currentAddress'),
          ],
        ),
      ),
    );
  }

  Future<String> _getCurrentAddress(Position position, BuildContext context) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.country}";
    } catch (e) {
      return "No se pudo obtener la dirección: $e";
    }
  }
}
