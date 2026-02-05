import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/shop_item.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../inventory/inventory_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'All',
    'Consumables',
    'Protection',
    'Permanent',
    'Legendary',
    'Cosmetic',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ShopItem> _getItemsForCategory(ShopProvider shop, int index) {
    switch (index) {
      case 0:
        return shop.catalog;
      case 1:
        return shop.consumables;
      case 2:
        return shop.protection;
      case 3:
        return shop.permanent;
      case 4:
        return shop.legendary;
      case 5:
        return shop.cosmetic;
      case 6:
        return [...shop.special, ...shop.streakItems, ...shop.lifestylePass];
      default:
        return shop.catalog;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.systemBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withOpacity(0.2),
                Colors.transparent
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM SHOP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
              ),
              const Spacer(),
              // Gold Balance
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold.withOpacity(0.15),
                  border: Border.all(color: AppTheme.amberGold, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on,
                        color: AppTheme.amberGold, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${userProvider.gold}',
                      style: TextStyle(
                        color: AppTheme.amberGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.backpack, color: AppTheme.systemCyan),
                tooltip: 'Inventory',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppTheme.primaryPurple.withOpacity(0.3), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.primaryPurple,
        labelColor: AppTheme.primaryPurple,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Rajdhani',
        ),
        tabs: _categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return Consumer2<ShopProvider, UserProvider>(
      builder: (context, shop, userProvider, child) {
        return TabBarView(
          controller: _tabController,
          children: _categories.asMap().entries.map((entry) {
            final items = _getItemsForCategory(shop, entry.key);

            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No items in this category',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(items[index], shop, userProvider);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildItemCard(
      ShopItem item, ShopProvider shop, UserProvider userProvider) {
    final canAfford = shop.canPurchase(item.id, userProvider);
    final rarityColor = Color(item.rarityColor);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.systemNavy.withOpacity(0.6),
        border: Border.all(color: rarityColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(item, shop, userProvider),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.2),
                  border: Border.all(color: rarityColor, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.rarityName.toUpperCase(),
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Item Name
              Text(
                item.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Stock/Cooldown indicators
              if (item.maxStock != null || item.cooldownHours != null)
                _buildItemStatus(item, shop),

              const SizedBox(height: 8),

              // Price & Buy Button
              Row(
                children: [
                  Icon(Icons.monetization_on,
                      color: AppTheme.amberGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${item.cost}',
                    style: TextStyle(
                      color: AppTheme.amberGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  const Spacer(),
                  if (!canAfford)
                    Icon(Icons.lock, color: Colors.red.shade300, size: 18)
                  else
                    Icon(Icons.shopping_cart,
                        color: AppTheme.primaryPurple, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemStatus(ShopItem item, ShopProvider shop) {
    final widgets = <Widget>[];

    // Stock indicator
    if (item.maxStock != null) {
      final stock =
          shop.catalog.firstWhere((i) => i.id == item.id).maxStock ?? 0;
      widgets.add(
        Row(
          children: [
            Icon(Icons.inventory_2,
                size: 12, color: stock > 0 ? Colors.green : Colors.red),
            const SizedBox(width: 4),
            Text(
              'Stock: $stock',
              style: TextStyle(
                color: stock > 0 ? Colors.green : Colors.red,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    // Cooldown indicator (if recently purchased)
    if (item.cooldownHours != null) {
      widgets.add(
        Row(
          children: [
            Icon(Icons.schedule, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '${item.cooldownHours}h CD',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets
          .map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: w,
              ))
          .toList(),
    );
  }

  void _showItemDetails(
      ShopItem item, ShopProvider shop, UserProvider userProvider) {
    final canAfford = shop.canPurchase(item.id, userProvider);
    final rarityColor = Color(item.rarityColor);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppTheme.systemBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: rarityColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rarityColor.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.2),
                      border: Border.all(color: rarityColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.rarityName.toUpperCase(),
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rajdhani',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Effects
                    if (item.effects != null && item.effects!.isNotEmpty) ...[
                      Text(
                        'EFFECTS',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...item.effects!.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatEffect(e.key, e.value),
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Restrictions
                    if (item.lifetimePurchaseLimit != null ||
                        item.maxStock != null ||
                        item.cooldownHours != null) ...[
                      Text(
                        'RESTRICTIONS',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.lifetimePurchaseLimit != null)
                        _buildRestriction(
                            'Max Purchases', '${item.lifetimePurchaseLimit}'),
                      if (item.maxStock != null)
                        _buildRestriction(
                            'Available Stock', '${item.maxStock}'),
                      if (item.cooldownHours != null)
                        _buildRestriction(
                            'Cooldown', '${item.cooldownHours} hours'),
                    ],
                  ],
                ),
              ),
            ),

            // Purchase Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top:
                      BorderSide(color: rarityColor.withOpacity(0.3), width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on,
                          color: AppTheme.amberGold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${item.cost} Gold',
                        style: TextStyle(
                          color: AppTheme.amberGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: canAfford
                          ? () => _purchaseItem(item, shop, userProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? rarityColor : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        canAfford ? 'PURCHASE' : 'INSUFFICIENT GOLD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
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

  Widget _buildRestriction(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatEffect(String key, dynamic value) {
    switch (key) {
      case 'hpRestore':
        return 'Restores $value HP';
      case 'mpRestore':
        return 'Restores $value MP';
      case 'fullRestore':
        return 'Fully restores HP and MP';
      case 'xpBoostPercent':
        return '+$value% XP gain';
      case 'goldBoostPercent':
        return '+$value% Gold gain';
      case 'durationHours':
        return 'Duration: $value hours';
      case 'streakProtectionDays':
        return 'Protects streak for $value days';
      case 'passiveXpBoost':
        return '+$value% XP (Permanent)';
      case 'passiveGoldBoost':
        return '+$value% Gold (Permanent)';
      case 'maxHpBonus':
        return '+$value Max HP (Permanent)';
      case 'maxMpBonus':
        return '+$value Max MP (Permanent)';
      case 'statBonus':
        if (value is Map) {
          return 'Stat Boost: ${value.entries.map((e) => '+${e.value} ${e.key}').join(', ')}';
        }
        return 'Permanent stat boost';
      case 'unlockTitle':
        return 'Unlocks title: "$value"';
      case 'unlockTheme':
        return 'Unlocks theme';
      default:
        return '$key: $value';
    }
  }

  Future<void> _purchaseItem(
      ShopItem item, ShopProvider shop, UserProvider userProvider) async {
    Navigator.pop(context); // Close bottom sheet

    final success = await shop.purchaseItem(item.id, userProvider);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.name} purchased successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.systemNavy,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Purchase failed. Check requirements.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
