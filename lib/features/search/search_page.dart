import 'package:flutter/material.dart';

/// Single-page UI: search field + results area (shell only).
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: const [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search images',
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Results will appear here')),
            ),
          ],
        ),
      ),
    );
  }
}
