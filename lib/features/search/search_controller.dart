import 'dart:async';
import 'photo_model.dart';
import 'image_repository.dart';

/// Holds state, debounce, and pagination (wired later).
class SearchController {
  String query = '';
  final items = <Photo>[];
  int page = 1;
  final int perPage = 30;
  bool isLoading = false;
  bool hasMore = true;
  String? error;

  Timer? _debounce;

  void onQueryChanged(String q, void Function() notify) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      // TODO: implement reset + fetch
      query = q.trim();
      notify();
    });
  }

  void dispose() => _debounce?.cancel();
}
