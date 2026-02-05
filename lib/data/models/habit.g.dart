// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 6;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as HabitType,
      tier: fields[4] as HabitTier,
      xpReward: fields[5] as int,
      xpPenalty: fields[6] as int,
      createdAt: fields[16] as DateTime,
      statRewards: (fields[7] as Map?)?.cast<String, int>(),
      statPenalties: (fields[8] as Map?)?.cast<String, int>(),
      hpDamage: fields[9] as int,
      mpDrain: fields[10] as int,
      debuffName: fields[17] as String?,
      consecutiveCompletions: fields[26] as int,
      lastBadHabitDate: fields[27] as DateTime?,
      streakBonus: fields[18] as int,
      completedDates: (fields[11] as List?)?.cast<DateTime>(),
      failedDates: (fields[12] as List?)?.cast<DateTime>(),
      currentStreak: fields[13] as int,
      longestStreak: fields[14] as int,
      isActive: fields[15] as bool,
      isCustom: fields[19] as bool,
      currentCount: fields[20] as int,
      maxCount: fields[21] as int,
      xpPerCount: fields[22] as int,
      isCounterBased: fields[23] as bool,
      lastCounterIncrement: fields[24] as DateTime?,
      minMinutesBetweenIncrements: fields[25] as int?,
      goldReward: fields[28] as int?,
      goldPenalty: fields[29] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.tier)
      ..writeByte(5)
      ..write(obj.xpReward)
      ..writeByte(6)
      ..write(obj.xpPenalty)
      ..writeByte(7)
      ..write(obj.statRewards)
      ..writeByte(8)
      ..write(obj.statPenalties)
      ..writeByte(9)
      ..write(obj.hpDamage)
      ..writeByte(10)
      ..write(obj.mpDrain)
      ..writeByte(11)
      ..write(obj.completedDates)
      ..writeByte(12)
      ..write(obj.failedDates)
      ..writeByte(13)
      ..write(obj.currentStreak)
      ..writeByte(14)
      ..write(obj.longestStreak)
      ..writeByte(15)
      ..write(obj.isActive)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.debuffName)
      ..writeByte(18)
      ..write(obj.streakBonus)
      ..writeByte(19)
      ..write(obj.isCustom)
      ..writeByte(20)
      ..write(obj.currentCount)
      ..writeByte(21)
      ..write(obj.maxCount)
      ..writeByte(22)
      ..write(obj.xpPerCount)
      ..writeByte(23)
      ..write(obj.isCounterBased)
      ..writeByte(24)
      ..write(obj.lastCounterIncrement)
      ..writeByte(25)
      ..write(obj.minMinutesBetweenIncrements)
      ..writeByte(26)
      ..write(obj.consecutiveCompletions)
      ..writeByte(27)
      ..write(obj.lastBadHabitDate)
      ..writeByte(28)
      ..write(obj.goldReward)
      ..writeByte(29)
      ..write(obj.goldPenalty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 7;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.good;
      case 1:
        return HabitType.bad;
      default:
        return HabitType.good;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.good:
        writer.writeByte(0);
        break;
      case HabitType.bad:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTierAdapter extends TypeAdapter<HabitTier> {
  @override
  final int typeId = 8;

  @override
  HabitTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitTier.s;
      case 1:
        return HabitTier.a;
      case 2:
        return HabitTier.b;
      case 3:
        return HabitTier.c;
      case 4:
        return HabitTier.severe;
      case 5:
        return HabitTier.catastrophic;
      default:
        return HabitTier.s;
    }
  }

  @override
  void write(BinaryWriter writer, HabitTier obj) {
    switch (obj) {
      case HabitTier.s:
        writer.writeByte(0);
        break;
      case HabitTier.a:
        writer.writeByte(1);
        break;
      case HabitTier.b:
        writer.writeByte(2);
        break;
      case HabitTier.c:
        writer.writeByte(3);
        break;
      case HabitTier.severe:
        writer.writeByte(4);
        break;
      case HabitTier.catastrophic:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
