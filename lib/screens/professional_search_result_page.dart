import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/professional.dart'; // Importa el modelo Professional desde el archivo correspondiente

class ProfessionalSearchResultPage extends StatelessWidget {
  final List<Professional> professionals; // Lista de profesionales
  const ProfessionalSearchResultPage({Key? key, required this.professionals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define la posición inicial del mapa (puedes ajustarla según tus necesidades)
    final LatLng initialPosition = professionals.isNotEmpty ? professionals.first.location : LatLng(0, 0);

    return Scaffold(
      key: key, // Añade esta línea para corregir el error
      appBar: AppBar(
        title: const Text('Resultados de búsqueda'), // Utiliza const para mejorar el rendimiento
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              // Configura el mapa con los marcadores de los profesionales
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 10, // Ajusta el nivel de zoom según tus necesidades
              ),
              markers: professionals.map((professional) {
                return Marker(
                  markerId: MarkerId(professional.id),
                  position: professional.location,
                  infoWindow: InfoWindow(title: professional.name),
                );
              }).toSet(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: professionals.length,
              itemBuilder: (context, index) {
                final professional = professionals[index];
                return ListTile(
                  title: Text(professional.name),
                  subtitle: Text(professional.address),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
