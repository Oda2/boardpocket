import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../router/router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/services.dart';

/// Lets the user look up a cover reference for a game by name.
///
/// Returns the chosen image URL through [GoRouter] (`context.popOrGo(url)`), or
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
  CoverSearchResult? _result;
  bool _isLoading = false;
  CoverSearchFailure? _failure;
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
        _result = null;
        _isLoading = false;
        _failure = null;
      });
      return;
    }

    // Long debounce on purpose: these APIs rate-limit hard and every extra
    // keystroke would otherwise cost a request (Wikimedia answers 429 quickly).
    _debounce = Timer(
      const Duration(milliseconds: 800),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _failure = null;
    });

    try {
      final result = await _service.search(query);
      // Ignore responses that arrived after a newer search started.
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } on CoverSearchException catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _result = null;
        _isLoading = false;
        _failure = e.failure;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _result = null;
        _isLoading = false;
        _failure = CoverSearchFailure.offline;
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
            _buildHeader(context, l10n),
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.popOrGo(),
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
    if (_isLoading && _result == null) {
      return const Center(child: AppLoading());
    }

    final failure = _failure;
    if (failure != null) {
      return EmptyState(
        icon: failure == CoverSearchFailure.rateLimited
            ? Icons.hourglass_top
            : Icons.wifi_off,
        title: switch (failure) {
          CoverSearchFailure.rateLimited => l10n.coverSearchBusy,
          CoverSearchFailure.offline => l10n.coverSearchError,
          CoverSearchFailure.none => l10n.coverSearchError,
        },
        subtitle: switch (failure) {
          CoverSearchFailure.rateLimited => l10n.coverSearchBusyDesc,
          _ => l10n.coverSearchErrorDesc,
        },
      );
    }

    final result = _result;
    if (result == null || result.items.isEmpty) {
      return EmptyState(
        icon: Icons.image_search,
        title: l10n.coverSearchNoResults,
        subtitle: l10n.coverSearchNoResultsDesc,
      );
    }

    return Column(
      children: [
        if (result.relaxed) _buildRelaxedNotice(l10n),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: result.items.length,
            itemBuilder: (context, index) => _CoverTile(
              result: result.items[index],
              onTap: () => context.pop(result.items[index].imageUrl),
            ),
          ),
        ),
      ],
    );
  }

  /// Tells the user the results are for a shorter version of what they typed.
  Widget _buildRelaxedNotice(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.coverSearchRelaxed(_result!.usedQuery),
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
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
