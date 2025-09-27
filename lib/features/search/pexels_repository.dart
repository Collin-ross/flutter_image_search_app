import 'dart:convert';
import 'package:http/http.dart' as http;
import 'image_repository.dart';
import 'photo_model.dart';

class PexelsRepository implements ImageRepository {
  static const _apiKey = String.fromEnvironment('PEXELS_API_KEY');

  @override
  Future<List<Photo>> search({
    required String query,
    required int page,
    required int perPage,
  }) async {
    // TODO: implement real HTTP call; returning empty for now.
    return <Photo>[];
  }
}
