import 'package:hive/hive.dart';

part 'user_inventory.g.dart';

/// Transaction types for Gold economy tracking
@HiveType(typeId: 28)
enum TransactionType {
  @HiveField(0)
  habitCompletion, // Earned from good habit

  @HiveField(1)
  streakMilestone, // Earned from streak bonus

  @HiveField(2)
  levelUp, // Earned from leveling up

  @HiveField(3)
  gateClear, // Earned from clearing gate

  @HiveField(4)
  shopPurchase, // Spent on shop item

  @HiveField(5)
  adminGrant, // Debug/admin grant

  @HiveField(6)
  penalty, // Lost to penalty
}

/// A single transaction record (immutable)
@HiveType(typeId: 29)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  int goldChange; // Positive for earn, negative for spend

  @HiveField(4)
  String source; // E.g., "Habit: ARISE", "Shop: Lesser Healing Potion"

  @HiveField(5)
  int goldBefore;

  @HiveField(6)
  int goldAfter;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.goldChange,
    required this.source,
    required this.goldBefore,
    required this.goldAfter,
  });
}

/// An item in the user's inventory
@HiveType(typeId: 30)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String id; // Unique instance ID

  @HiveField(1)
  String shopItemId; // Reference to ShopItem.id

  @HiveField(2)
  DateTime acquiredAt;

  @HiveField(3)
  bool isUsed;

  @HiveField(4)
  DateTime? usedAt;

  InventoryItem({
    required this.id,
    required this.shopItemId,
    required this.acquiredAt,
    this.isUsed = false,
    this.usedAt,
  });
}

/// User's inventory and Gold management
@HiveType(typeId: 31)
class UserInventory extends HiveObject {
  @HiveField(0)
  int gold;

  @HiveField(1)
  List<InventoryItem> items;

  @HiveField(2)
  List<Transaction> transactions;

  /// Track lifetime purchases per item ID
  @HiveField(3)
  Map<String, int> lifetimePurchases;

  /// Track last purchase time per item ID (Unix epoch)
  @HiveField(4)
  Map<String, int> lastPurchaseTime;

  UserInventory({
    this.gold = 0,
    List<InventoryItem>? items,
    List<Transaction>? transactions,
    Map<String, int>? lifetimePurchases,
    Map<String, int>? lastPurchaseTime,
  })  : items = items ?? [],
        transactions = transactions ?? [],
        lifetimePurchases = lifetimePurchases ?? {},
        lastPurchaseTime = lastPurchaseTime ?? {};

  /// Get active (unused) items
  List<InventoryItem> get activeItems =>
      items.where((item) => !item.isUsed).toList();

  /// Get active items of a specific type
  List<InventoryItem> getItemsByShopId(String shopItemId) {
    return activeItems.where((item) => item.shopItemId == shopItemId).toList();
  }

  /// Count active items by shop ID
  int countItems(String shopItemId) {
    return activeItems.where((item) => item.shopItemId == shopItemId).length;
  }

  /// Add transaction and update gold
  void addTransaction(Transaction transaction) {
    gold += transaction.goldChange;
    transactions.add(transaction);
  }

  /// Calculate total Gold earned from all transactions
  int get totalGoldEarned {
    return transactions
        .where((t) => t.goldChange > 0)
        .fold(0, (sum, t) => sum + t.goldChange);
  }

  /// Calculate total Gold spent from all transactions
  int get totalGoldSpent {
    return transactions
        .where((t) => t.goldChange < 0)
        .fold(0, (sum, t) => sum + t.goldChange.abs());
  }
}
