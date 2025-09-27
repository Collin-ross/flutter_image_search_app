import 'dart:async';
import 'image_repository.dart';
import 'photo_model.dart';

class ImageSearchController {
  ImageSearchController(this._repo);

  final ImageRepository _repo;

  final List<Photo> items = [];
  bool isLoading = false;
  bool hasMore = true;
  String query = '';
  String? error;

  int _page = 1;
  static const int _perPage = 30;

  Timer? _debounce;

  void dispose() {
    _debounce?.cancel();
  }

  // Debounced text field handler
  void onQueryChanged(String q, void Function() refresh) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchImmediate(q, refresh);
    });
  }

  // Immediate search (used for first load & pull-to-refresh)
  Future<void> searchImmediate(String q, void Function() refresh) async {
    query = q.trim();
    error = null;
    items.clear();
    hasMore = true;
    _page = 1;

    if (query.isEmpty) {
      refresh();
      return;
    }

    isLoading = true;
    refresh();

    try {
      final results = await _repo.search(
        query: query,
        page: _page,
        perPage: _perPage,
      );
      items.addAll(results);
      hasMore = results.length == _perPage;
    } catch (e) {
      error = e.toString();
      hasMore = false;
    } finally {
      isLoading = false;
      refresh();
    }
  }

  // Infinite scroll pagination
  Future<void> loadMore(void Function() refresh) async {
    if (isLoading || !hasMore || query.isEmpty) return;

    isLoading = true;
    error = null;
    refresh();

    try {
      _page += 1;
      final results = await _repo.search(
        query: query,
        page: _page,
        perPage: _perPage,
      );
      items.addAll(results);
      hasMore = results.length == _perPage;
    } catch (e) {
      error = e.toString();
      hasMore = false;
    } finally {
      isLoading = false;
      refresh();
    }
  }
}
