// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      level: fields[1] as int,
      currentXP: fields[2] as int,
      totalXP: fields[3] as int,
      rank: fields[4] as HunterRank,
      hunterClass: fields[5] as HunterClass,
      stats: fields[6] as PlayerStats,
      currentHP: fields[7] as int,
      maxHP: fields[8] as int,
      currentMP: fields[9] as int,
      maxMP: fields[10] as int,
      unlockedShadows: (fields[11] as List?)?.cast<String>(),
      activeBuffs: (fields[12] as List?)?.cast<ActiveBuff>(),
      activeDebuffs: (fields[13] as List?)?.cast<ActiveDebuff>(),
      createdAt: fields[14] as DateTime,
      lastActive: fields[15] as DateTime,
      title: fields[16] as String,
      consecutiveDays: fields[17] as int,
      isInPenaltyZone: fields[18] as bool,
      unlockedTitles: (fields[19] as List?)?.cast<String>(),
      bossesDefeated: fields[20] as int,
      currentWeekBossProgress: fields[21] as int,
      lastBossWeek: fields[22] as int,
      gold: fields[23] as int?,
      dataIntegrityHash: fields[24] as String?,
      securityViolationCount: fields[25] as int?,
      xpGainTimestamps: (fields[26] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.currentXP)
      ..writeByte(3)
      ..write(obj.totalXP)
      ..writeByte(4)
      ..write(obj.rank)
      ..writeByte(5)
      ..write(obj.hunterClass)
      ..writeByte(6)
      ..write(obj.stats)
      ..writeByte(7)
      ..write(obj.currentHP)
      ..writeByte(8)
      ..write(obj.maxHP)
      ..writeByte(9)
      ..write(obj.currentMP)
      ..writeByte(10)
      ..write(obj.maxMP)
      ..writeByte(11)
      ..write(obj.unlockedShadows)
      ..writeByte(12)
      ..write(obj.activeBuffs)
      ..writeByte(13)
      ..write(obj.activeDebuffs)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.lastActive)
      ..writeByte(16)
      ..write(obj.title)
      ..writeByte(17)
      ..write(obj.consecutiveDays)
      ..writeByte(18)
      ..write(obj.isInPenaltyZone)
      ..writeByte(19)
      ..write(obj.unlockedTitles)
      ..writeByte(20)
      ..write(obj.bossesDefeated)
      ..writeByte(21)
      ..write(obj.currentWeekBossProgress)
      ..writeByte(22)
      ..write(obj.lastBossWeek)
      ..writeByte(23)
      ..write(obj.gold)
      ..writeByte(24)
      ..write(obj.dataIntegrityHash)
      ..writeByte(25)
      ..write(obj.securityViolationCount)
      ..writeByte(26)
      ..write(obj.xpGainTimestamps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId = 1;

  @override
  PlayerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStats(
      strength: fields[0] as int,
      willpower: fields[1] as int,
      charisma: fields[2] as int,
      endurance: fields[3] as int,
      wisdom: fields[4] as int,
      intelligence: fields[5] as int,
      awareness: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.strength)
      ..writeByte(1)
      ..write(obj.willpower)
      ..writeByte(2)
      ..write(obj.charisma)
      ..writeByte(3)
      ..write(obj.endurance)
      ..writeByte(4)
      ..write(obj.wisdom)
      ..writeByte(5)
      ..write(obj.intelligence)
      ..writeByte(6)
      ..write(obj.awareness);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActiveBuffAdapter extends TypeAdapter<ActiveBuff> {
  @override
  final int typeId = 4;

  @override
  ActiveBuff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveBuff(
      name: fields[0] as String,
      description: fields[1] as String,
      expiresAt: fields[2] as DateTime,
      statModifiers: (fields[3] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ActiveBuff obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.expiresAt)
      ..writeByte(3)
      ..write(obj.statModifiers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveBuffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActiveDebuffAdapter extends TypeAdapter<ActiveDebuff> {
  @override
  final int typeId = 5;

  @override
  ActiveDebuff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveDebuff(
      name: fields[0] as String,
      description: fields[1] as String,
      expiresAt: fields[2] as DateTime,
      statModifiers: (fields[3] as Map).cast<String, double>(),
      stackCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveDebuff obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.expiresAt)
      ..writeByte(3)
      ..write(obj.statModifiers)
      ..writeByte(4)
      ..write(obj.stackCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveDebuffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HunterRankAdapter extends TypeAdapter<HunterRank> {
  @override
  final int typeId = 2;

  @override
  HunterRank read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HunterRank.eRank;
      case 1:
        return HunterRank.dRank;
      case 2:
        return HunterRank.cRank;
      case 3:
        return HunterRank.bRank;
      case 4:
        return HunterRank.aRank;
      case 5:
        return HunterRank.sRank;
      case 6:
        return HunterRank.specialSRank;
      default:
        return HunterRank.eRank;
    }
  }

  @override
  void write(BinaryWriter writer, HunterRank obj) {
    switch (obj) {
      case HunterRank.eRank:
        writer.writeByte(0);
        break;
      case HunterRank.dRank:
        writer.writeByte(1);
        break;
      case HunterRank.cRank:
        writer.writeByte(2);
        break;
      case HunterRank.bRank:
        writer.writeByte(3);
        break;
      case HunterRank.aRank:
        writer.writeByte(4);
        break;
      case HunterRank.sRank:
        writer.writeByte(5);
        break;
      case HunterRank.specialSRank:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HunterRankAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HunterClassAdapter extends TypeAdapter<HunterClass> {
  @override
  final int typeId = 3;

  @override
  HunterClass read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HunterClass.warrior;
      case 1:
        return HunterClass.mage;
      case 2:
        return HunterClass.assassin;
      default:
        return HunterClass.warrior;
    }
  }

  @override
  void write(BinaryWriter writer, HunterClass obj) {
    switch (obj) {
      case HunterClass.warrior:
        writer.writeByte(0);
        break;
      case HunterClass.mage:
        writer.writeByte(1);
        break;
      case HunterClass.assassin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HunterClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
