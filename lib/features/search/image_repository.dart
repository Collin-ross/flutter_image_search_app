import 'photo_model.dart';

abstract class ImageRepository {
  Future<List<Photo>> search({
    required String query,
    required int page,
    required int perPage,
  });
}
