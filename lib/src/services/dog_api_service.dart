import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dog_breed.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DogApiService {
  // TODO: cambia esto por tu propia API Key de The Dog API
  static final String _apiKey = dotenv.env['DOG_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.thedogapi.com/v1';

  Future<List<DogBreed>> getBreeds() async {
    final url = Uri.parse('$_baseUrl/breeds');

    final res = await http.get(url, headers: {'x-api-key': _apiKey});

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => DogBreed.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar razas: ${res.statusCode}');
    }
  }

  Future<List<DogBreed>> searchBreeds(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse('$_baseUrl/breeds/search?q=$query');

    final res = await http.get(url, headers: {'x-api-key': _apiKey});

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      // Nota: este endpoint devuelve un JSON ligeramente diferente (sin image),
      // podrías extenderlo luego para buscar la imagen por id.
      return data.map((e) => DogBreed.fromJson(e)).toList();
    } else {
      throw Exception('Error en búsqueda: ${res.statusCode}');
    }
  }
}
