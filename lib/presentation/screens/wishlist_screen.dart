import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final items = wishlistProvider.items;

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
                  subtitle: 'BoardPocket',
                  title: l10n.wishlist,
                  trailing: ProfileAvatar(
                    onTap: () => context.push('/settings'),
                  ),
                ),
                ChipSelector(
                  items: [l10n.all, 'Strategy', 'Party'],
                  selected: _selectedFilter,
                  onSelected: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: wishlistProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? EmptyState(
                          icon: Icons.favorite_border,
                          title: l10n.yourWishlistIsEmpty,
                          subtitle: l10n.addGamesYouWant,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return _buildWishlistItem(
                              context,
                              isDark,
                              items[index],
                            );
                          },
                        ),
                ),
                const BottomTabBar(activeRoute: '/wishlist'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-wishlist'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    bool isDark,
    WishlistItem item,
  ) {
    return ListItem(
      title: item.title,
      subtitle: 'Added on ${_formatDate(item.createdAt)}',
      localImagePath: item.imagePath,
      networkImageUrl: item.imageUrl,
      tag: item.tag,
      trailingText: item.price,
      onTap: () => context.push('/edit-wishlist/${item.id}'),
      actions: [
        ListItemAction(
          icon: Icons.shopping_cart,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          iconColor: Colors.orange,
          onTap: () => _launchUrl(item.purchaseUrl),
        ),
        ListItemAction(
          icon: Icons.edit,
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          iconColor: Colors.blue,
          onTap: () => context.push('/edit-wishlist/${item.id}'),
        ),
        ListItemAction(
          icon: Icons.delete,
          backgroundColor: Colors.grey.withValues(alpha: 0.1),
          iconColor: Colors.grey,
          onTap: () => context.read<WishlistProvider>().deleteItem(item.id),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
