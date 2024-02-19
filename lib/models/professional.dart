import 'package:google_maps_flutter/google_maps_flutter.dart';

class Professional {
  final String id;
  final String name;
  final String address;
  final LatLng location;

  Professional({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });
}
