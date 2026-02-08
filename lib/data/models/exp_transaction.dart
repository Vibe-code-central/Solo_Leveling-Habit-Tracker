import 'package:hive/hive.dart';

part 'exp_transaction.g.dart';

@HiveType(typeId: 38)
enum ExpTransactionType {
  @HiveField(0)
  habitCompletion,

  @HiveField(1)
  streakBonus,

  @HiveField(2)
  achievement,

  @HiveField(3)
  gateClear,

  @HiveField(4)
  penalty,

  @HiveField(5)
  adminGrant,

  @HiveField(6)
  undo,
}

@HiveType(typeId: 39)
class ExpTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  ExpTransactionType type;

  @HiveField(3)
  int xpChange;

  @HiveField(4)
  String source;

  @HiveField(5)
  int xpBefore;

  @HiveField(6)
  int xpAfter;

  ExpTransaction({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.xpChange,
    required this.source,
    required this.xpBefore,
    required this.xpAfter,
  });
}
