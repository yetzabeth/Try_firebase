import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importa LatLng desde google_maps_flutter
import '../models/location.dart' as MyLocation;
import '../services/location_service.dart';
import '../utils/zonas_codigos_postales.dart';

class LocationController {
  final LocationService _locationService = LocationService();

  Future<MyLocation.Location> getCurrentLocation() async {
    final Position position = await _locationService.getCurrentPosition();
    final String address = await _getCurrentAddress(position);
    // Utiliza LatLng para crear la posición
    return MyLocation.Location(address: address, position: LatLng(position.latitude, position.longitude));
  }

  Future<String> _getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      String subLocality = place.subLocality ?? '';
      String subLocalityText = subLocality.isNotEmpty ? '$subLocality, ' : '';

      String addressLine = place.street ?? '';
      String locality = place.locality ?? '';
      String postalCode = place.postalCode ?? '';
      String address = '${addressLine.isNotEmpty ? '$addressLine, ' : ''}${subLocalityText.isNotEmpty ? subLocalityText : ''}${locality.isNotEmpty ? '$locality, ' : ''}${postalCode.isNotEmpty ? '$postalCode, ' : ''}${place.country}';

      List<String> zones = postalCode.isNotEmpty ? _mapPostalCodeToZone(postalCode) : ["Desconocida"];

      return "$address\nZonas: ${zones.join(", ")}";
    } catch (e) {
      return "No se pudo obtener la dirección: $e";
    }
  }

  List<String> _mapPostalCodeToZone(String postalCode) {
    List<String> foundZones = [];
    for (var departamento in zonasCodigosPostales.values) {
      for (var codigos in departamento.values) {
        if (codigos.contains(postalCode)) {
          var zona = departamento.keys.firstWhere((key) => departamento[key] == codigos);
          foundZones.add(zona);
        }
      }
    }
    return foundZones;
  }
}
