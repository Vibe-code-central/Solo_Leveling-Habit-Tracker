// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 9;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as AchievementCategory,
      xpReward: fields[4] as int,
      statRewards: (fields[5] as Map).cast<String, int>(),
      titleUnlock: fields[6] as String?,
      shadowUnlock: fields[7] as String?,
      isUnlocked: fields[8] as bool,
      unlockedAt: fields[9] as DateTime?,
      targetValue: fields[10] as int,
      currentProgress: fields[11] as int,
      icon: fields[12] as String,
      rarity: fields[13] as AchievementRarity,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.xpReward)
      ..writeByte(5)
      ..write(obj.statRewards)
      ..writeByte(6)
      ..write(obj.titleUnlock)
      ..writeByte(7)
      ..write(obj.shadowUnlock)
      ..writeByte(8)
      ..write(obj.isUnlocked)
      ..writeByte(9)
      ..write(obj.unlockedAt)
      ..writeByte(10)
      ..write(obj.targetValue)
      ..writeByte(11)
      ..write(obj.currentProgress)
      ..writeByte(12)
      ..write(obj.icon)
      ..writeByte(13)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementRarityAdapter extends TypeAdapter<AchievementRarity> {
  @override
  final int typeId = 11;

  @override
  AchievementRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementRarity.common;
      case 1:
        return AchievementRarity.rare;
      case 2:
        return AchievementRarity.epic;
      case 3:
        return AchievementRarity.legendary;
      case 4:
        return AchievementRarity.mythic;
      default:
        return AchievementRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementRarity obj) {
    switch (obj) {
      case AchievementRarity.common:
        writer.writeByte(0);
        break;
      case AchievementRarity.rare:
        writer.writeByte(1);
        break;
      case AchievementRarity.epic:
        writer.writeByte(2);
        break;
      case AchievementRarity.legendary:
        writer.writeByte(3);
        break;
      case AchievementRarity.mythic:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementCategoryAdapter extends TypeAdapter<AchievementCategory> {
  @override
  final int typeId = 10;

  @override
  AchievementCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementCategory.monarchsPath;
      case 1:
        return AchievementCategory.flameKeeper;
      case 2:
        return AchievementCategory.bossSlayer;
      case 3:
        return AchievementCategory.statMaster;
      case 4:
        return AchievementCategory.perfectHunter;
      case 5:
        return AchievementCategory.collector;
      default:
        return AchievementCategory.monarchsPath;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementCategory obj) {
    switch (obj) {
      case AchievementCategory.monarchsPath:
        writer.writeByte(0);
        break;
      case AchievementCategory.flameKeeper:
        writer.writeByte(1);
        break;
      case AchievementCategory.bossSlayer:
        writer.writeByte(2);
        break;
      case AchievementCategory.statMaster:
        writer.writeByte(3);
        break;
      case AchievementCategory.perfectHunter:
        writer.writeByte(4);
        break;
      case AchievementCategory.collector:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
