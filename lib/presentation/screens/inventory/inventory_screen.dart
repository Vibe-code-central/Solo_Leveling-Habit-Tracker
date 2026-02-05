import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/shop_item.dart';
import '../../../data/models/user_inventory.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'All',
    'Consumables',
    'Equipment',
    'Other',
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

  List<InventoryItem> _getItemsForCategory(
      UserInventory inventory, ShopProvider shop, int index) {
    final allItems = inventory.activeItems;
    if (index == 0) return allItems;

    return allItems.where((item) {
      final shopItem = shop.catalog.firstWhere((i) => i.id == item.shopItemId,
          orElse: () => ShopItem(
                id: 'unknown',
                name: 'Unknown',
                description: '',
                cost: 0,
                type: ShopItemType.special,
                rarity: ShopItemRarity.common,
                isOneTimeUse: true,
                effects: {},
              ));

      if (index == 1) return shopItem.type == ShopItemType.consumable;
      if (index == 2) {
        return shopItem.type == ShopItemType.protection ||
            shopItem.type == ShopItemType.permanent ||
            shopItem.type == ShopItemType.legendary;
      }
      return shopItem.type == ShopItemType.cosmetic ||
          shopItem.type == ShopItemType.special ||
          shopItem.type == ShopItemType.streakItem ||
          shopItem.type == ShopItemType.lifestylePass;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.systemBlack,
      appBar: AppBar(
        title: const Text('INVENTORY',
            style:
                TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.systemPurple.withOpacity(0.2),
                Colors.transparent
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.systemCyan,
          labelColor: AppTheme.systemCyan,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
              fontFamily: 'Rajdhani', fontWeight: FontWeight.bold),
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Consumer2<UserProvider, ShopProvider>(
        builder: (context, userProvider, shopProvider, child) {
          final inventory = userProvider.inventory;
          if (inventory == null || inventory.items.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(_categories.length, (index) {
              final items =
                  _getItemsForCategory(inventory, shopProvider, index);
              if (items.isEmpty)
                return _buildEmptyState(message: 'No items in this category');
              return _buildInventoryList(items, shopProvider, userProvider);
            }),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({String message = 'Inventory is empty'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.backpack_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                const TextStyle(color: Colors.white54, fontFamily: 'Rajdhani'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(
      List<InventoryItem> items, ShopProvider shop, UserProvider userProvider) {
    // Group items by ID
    final grouped = <String, List<InventoryItem>>{};
    for (var item in items) {
      if (!grouped.containsKey(item.shopItemId)) {
        grouped[item.shopItemId] = [];
      }
      grouped[item.shopItemId]!.add(item);
    }

    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final itemId = keys[index];
        final group = grouped[itemId]!;
        final count = group.length;
        final firstItem = group.first;
        final shopItem = shop.catalog.firstWhere((i) => i.id == itemId,
            orElse: () => ShopItem(
                  id: 'unknown',
                  name: 'Unknown Item',
                  description: 'This item is not in the catalog.',
                  cost: 0,
                  type: ShopItemType.special,
                  rarity: ShopItemRarity.common,
                  isOneTimeUse: false,
                  effects: {},
                ));

        return _buildInventoryCard(
            shopItem, count, firstItem, userProvider, shop);
      },
    );
  }

  Widget _buildInventoryCard(
      ShopItem item,
      int count,
      InventoryItem inventoryItem,
      UserProvider userProvider,
      ShopProvider shop) {
    final rarityColor = Color(item.rarityColor);
    final canUse = item.type == ShopItemType.consumable ||
        (item.type == ShopItemType.permanent &&
            (item.effects?.containsKey('statBonus') ?? false));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy.withOpacity(0.6),
        border: Border.all(color: rarityColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon/Image Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rarityColor.withOpacity(0.3)),
              ),
              child: Icon(
                _getIconForType(item.type),
                color: rarityColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Quantity & Action
            Column(
              children: [
                Text(
                  'x$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (canUse)
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.systemCyan.withOpacity(0.2),
                        foregroundColor: AppTheme.systemCyan,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(color: AppTheme.systemCyan),
                      ),
                      onPressed: () =>
                          _useItem(inventoryItem, item, userProvider, shop),
                      child: const Text('USE', style: TextStyle(fontSize: 10)),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PASSIVE',
                        style: TextStyle(fontSize: 9, color: Colors.white54)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ShopItemType type) {
    switch (type) {
      case ShopItemType.consumable:
        return Icons.local_drink;
      case ShopItemType.protection:
        return Icons.shield;
      case ShopItemType.permanent:
        return Icons.auto_awesome;
      case ShopItemType.legendary:
        return Icons.workspace_premium; // Crown replacement
      case ShopItemType.cosmetic:
        return Icons.palette;
      case ShopItemType.special:
        return Icons.star;
      case ShopItemType.streakItem:
        return Icons.local_fire_department;
      case ShopItemType.lifestylePass:
        return Icons.card_membership;
    }
  }

  Future<void> _useItem(InventoryItem inventoryItem, ShopItem shopItem,
      UserProvider userProvider, ShopProvider shop) async {
    try {
      final result = await shop.useItem(inventoryItem.id, userProvider);
      if (mounted) {
        final success = result['success'] as bool;
        final message = result['message'] as String;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                success ? AppTheme.systemCyan : AppTheme.systemCrimson,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error using item: $e'),
            backgroundColor: AppTheme.systemCrimson,
          ),
        );
      }
    }
  }
}
