import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/app_search_bar.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/services.dart';

/// Lets the user look up a cover reference for a game by name.
///
/// Returns the chosen image URL through [GoRouter] (`context.pop(url)`), or
/// pops with `null` when the user backs out.
class CoverSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const CoverSearchScreen({super.key, this.initialQuery});

  @override
  State<CoverSearchScreen> createState() => _CoverSearchScreenState();
}

class _CoverSearchScreenState extends State<CoverSearchScreen> {
  final _service = CoverSearchService();
  final _controller = TextEditingController();

  Timer? _debounce;
  List<CoverImageResult> _results = const [];
  bool _isLoading = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      _runSearch(initial);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    // Debounced so we stay well inside the anonymous rate limit (20/min).
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _service.search(query);
      // Ignore responses that arrived after a newer search started.
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = const [];
        _isLoading = false;
        _error = 'error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            AppSearchBar(
              hint: l10n.searchCoversHint,
              onChanged: _onQueryChanged,
              controller: _controller,
            ),
            Expanded(child: _buildBody(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              l10n.searchCovers,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.wifi_off,
        title: l10n.coverSearchError,
        subtitle: l10n.coverSearchErrorDesc,
      );
    }

    if (_results.isEmpty) {
      return EmptyState(
        icon: Icons.image_search,
        title: l10n.searchCovers,
        subtitle: l10n.searchCoversHint,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) => _CoverTile(
        result: _results[index],
        onTap: () => context.pop(_results[index].imageUrl),
      ),
    );
  }
}

class _CoverTile extends StatelessWidget {
  final CoverImageResult result;
  final VoidCallback onTap;

  const _CoverTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ThemeContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AdaptiveImage(networkUrl: result.thumbnailUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    result.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
