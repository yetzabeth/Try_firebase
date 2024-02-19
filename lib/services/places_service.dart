import 'package:google_place/google_place.dart';

class PlacesService {
  late GooglePlace _googlePlace;

  PlacesService(String apiKey) {
    _googlePlace = GooglePlace(apiKey);
  }

  Future<List<AutocompletePrediction>> searchPlaces(String query) async {
    try {
      final places = await _googlePlace.autocomplete.get(
        query,
        types: 'geocode',
        language: 'es',
      );
      return places!.predictions!;
    } catch (e) {
      throw Exception("Error searching places: $e");
    }
  }
}
