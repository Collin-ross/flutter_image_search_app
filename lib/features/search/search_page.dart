import 'package:flutter/material.dart';
import 'search_controller.dart';
import 'pexels_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ImageSearchController controller;
  final TextEditingController textCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = ImageSearchController(PexelsRepository());
    scrollCtrl.addListener(() {
      const threshold = 400.0;
      if (scrollCtrl.position.pixels >
              scrollCtrl.position.maxScrollExtent - threshold &&
          !controller.isLoading &&
          controller.hasMore) {
        controller.loadMore(_refresh);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.searchImmediate(textCtrl.text, _refresh);
          },
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: textCtrl,
                    onChanged: (v) => controller.onQueryChanged(v, _refresh),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search images (e.g., “mountains”, “dogs”)',
                      suffixIcon: textCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                textCtrl.clear();
                                controller.searchImmediate('', _refresh);
                              },
                            ),
                    ),
                  ),
                ),
              ),

              // States
              if (controller.query.isEmpty && controller.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Centered(text: 'Start typing to search'),
                )
              else if (controller.error != null && controller.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorMessage(
                    message: controller.error!,
                    onRetry: () =>
                        controller.searchImmediate(textCtrl.text, _refresh),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: controller.items.length +
                        // add one slot for the loader/footer while paging
                        (controller.isLoading || controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Footer loader tile
                      if (index >= controller.items.length) {
                        return const _FooterLoader();
                      }

                      final photo = controller.items[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              photo.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (c, child, progress) {
                                if (progress == null) return child;
                                return const _ShimmerTile();
                              },
                              errorBuilder: (c, _, __) => const ColoredBox(
                                color: Color(0x11000000),
                                child: Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              right: 8,
                              child: _AttributionChip(text: photo.photographer),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final String text;
  const _Centered({required this.text});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(text, style: Theme.of(context).textTheme.titleMedium));
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorMessage({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _AttributionChip extends StatelessWidget {
  final String text;
  const _AttributionChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _FooterLoader extends StatelessWidget {
  const _FooterLoader();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-1, -0.3),
          end: Alignment(1, 0.3),
          colors: [Color(0xFFEEEEEE), Color(0xFFDADADA), Color(0xFFEEEEEE)],
          stops: [0.2, 0.5, 0.8],
        ),
      ),
    );
  }
}
