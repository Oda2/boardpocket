import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../app_header.dart';
import '../app_search_bar.dart';
import '../chip_selector.dart';
import '../profile_avatar.dart';
import '../empty_state.dart';
import '../../../presentation/widgets/bottom_tab_bar.dart';

class FilterableListScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String activeRoute;
  final String addRoute;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final List<String> filters;
  final bool showSearch;
  final String searchHint;
  final List<Widget> body;
  final bool isLoading;
  final bool isEmpty;
  final String? selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<String>? onSearchChanged;
  final String searchQuery;

  const FilterableListScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.activeRoute,
    required this.addRoute,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.filters,
    this.showSearch = true,
    required this.searchHint,
    required this.body,
    this.isLoading = false,
    this.isEmpty = false,
    this.selectedFilter,
    this.onFilterChanged,
    this.onSearchChanged,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  subtitle: subtitle,
                  title: title,
                  trailing: ProfileAvatar(
                    onTap: () => context.push('/settings'),
                  ),
                ),
                if (showSearch)
                  AppSearchBar(hint: searchHint, onChanged: onSearchChanged),
                if (filters.isNotEmpty)
                  ChipSelector(
                    items: filters,
                    selected: selectedFilter ?? filters.first,
                    onSelected: onFilterChanged ?? (_) {},
                  ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isEmpty
                      ? EmptyState(
                          icon: emptyIcon,
                          title: emptyTitle,
                          subtitle: emptySubtitle,
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: body,
                        ),
                ),
                BottomTabBar(activeRoute: activeRoute),
              ],
            ),
            Positioned(
              right: 24,
              bottom: 100,
              child: FloatingActionButton(
                onPressed: () => context.push(addRoute),
                backgroundColor: AppColors.primary,
                elevation: 4,
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
