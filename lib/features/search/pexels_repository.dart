import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'image_repository.dart';
import 'photo_model.dart';

class PexelsRepository implements ImageRepository {
  static String get _apiKey {
    const fromDefine = String.fromEnvironment('PEXELS_API_KEY');
    return fromDefine.isNotEmpty
        ? fromDefine
        : (dotenv.env['PEXELS_API_KEY'] ?? '');
  }

  static const _base = 'api.pexels.com';

  @override
  Future<List<Photo>> search({
    required String query,
    required int page,
    required int perPage,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError('Missing PEXELS_API_KEY. Provide .env or --dart-define.');
    }

    final uri = Uri.https(_base, '/v1/search', {
      'query': query,
      'page': '$page',
      'per_page': '$perPage',
    });

    final res = await http.get(uri, headers: {'Authorization': _apiKey});

    if (res.statusCode != 200) {
      throw Exception('Pexels HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(res.body) as Map<String, dynamic>;
    final List<dynamic> photosJson =
        (jsonMap['photos'] as List<dynamic>?) ?? const [];

    return photosJson.map((e) {
      final m = e as Map<String, dynamic>;
      final src = (m['src'] as Map<String, dynamic>?) ?? const {};
      final url = (src['large'] ?? src['medium'] ?? src['original']) as String;
      return Photo(
        id: '${m['id']}',
        photographer: (m['photographer'] as String?) ?? 'Unknown',
        imageUrl: url,
      );
    }).toList();
  }
}
