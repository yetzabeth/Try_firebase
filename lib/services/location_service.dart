import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../zonas_codigos_postales.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String subLocality = place.subLocality ?? '';
      String subLocalityText =
          subLocality.isNotEmpty ? '$subLocality, ' : '';
      String addressLine = place.street ?? '';
      String locality = place.locality ?? '';
      String postalCode = place.postalCode ?? '';
      List<String> zones = postalCode.isNotEmpty
          ? _mapPostalCodeToZone(postalCode) // Agrega el prefijo '_'
          : ["Desconocida"];
      String address =
          '${addressLine.isNotEmpty ? '$addressLine, ' : ''}${subLocalityText.isNotEmpty ? subLocalityText : ''}${locality.isNotEmpty ? '$locality, ' : ''}${postalCode.isNotEmpty ? '$postalCode, ' : ''}${place.country}';
      return "$address\nZonas: ${zones.join(", ")}";
    } catch (e) {
      return "No se pudo obtener la dirección: $e";
    }
  }

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
          var zona =
              departamento.keys.firstWhere((key) => departamento[key] == codigos);
          foundZones.add(zona);
        }
      }
    }
    return foundZones;
  }
}
