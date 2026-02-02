import 'package:hive/hive.dart';

part 'debuff.g.dart';

@HiveType(typeId: 20)
class Debuff extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // "Demon's Grip", "Shadow's Curse", etc.

  @HiveField(2)
  int tier; // 1, 2, or 3

  @HiveField(3)
  String habitId; // Which bad habit caused it

  @HiveField(4)
  double xpReductionPercent; // 0.10, 0.20, 0.30

  @HiveField(5)
  Map<String, int> tempStatReduction; // {'willpower': 2}

  @HiveField(6)
  DebuffSpecialEffect? specialEffect;

  @HiveField(7)
  DateTime expiresAt;

  @HiveField(8)
  DateTime createdAt;

  Debuff({
    required this.id,
    required this.name,
    required this.tier,
    required this.habitId,
    required this.xpReductionPercent,
    required this.tempStatReduction,
    this.specialEffect,
    required this.expiresAt,
    required this.createdAt,
  });

  bool get isActive => DateTime.now().isBefore(expiresAt);

  int get daysRemaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  int get hoursRemaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inHours > 0 ? diff.inHours : 0;
  }
}

@HiveType(typeId: 21)
enum DebuffSpecialEffect {
  @HiveField(0)
  levelBlock, // Cannot level up (Screen 10PM tier 3)

  @HiveField(1)
  habitLock, // Morning habits locked (Snooze tier 3)

  @HiveField(2)
  intWisBlock, // Can't earn INT/WIS (Gaming tier 3)

  @HiveField(3)
  strEndBlock, // Can't earn STR/END (Junk Food tier 3)

  @HiveField(4)
  hpCapReduction, // Max HP -20% (Junk Food tier 3)
}
