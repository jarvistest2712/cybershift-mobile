import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StoreService {
  static const String boxName = 'playerData';
  
  static const String keyBits = 'bits';
  static const String keyShieldLevel = 'shieldLevel';
  static const String keySpeedLevel = 'speedLevel';

  late Box box;
  final ValueNotifier<int> bitsNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox(boxName);
    bitsNotifier.value = bits;
  }

  int get bits => box.get(keyBits, defaultValue: 0);
  int get shieldLevel => box.get(keyShieldLevel, defaultValue: 0);
  int get speedLevel => box.get(keySpeedLevel, defaultValue: 0);

  void addBits(int amount) {
    int newAmount = bits + amount;
    box.put(keyBits, newAmount);
    bitsNotifier.value = newAmount;
  }

  bool buyUpgrade(String key, int cost) {
    if (bits >= cost) {
      addBits(-cost);
      int currentLevel = box.get(key, defaultValue: 0);
      box.put(key, currentLevel + 1);
      return true;
    }
    return false;
  }
}

class UpgradeItem {
  final String name;
  final String key;
  final int baseCost;
  final String description;

  UpgradeItem({
    required this.name,
    required this.key,
    required this.baseCost,
    required this.description,
  });

  int getCost(int currentLevel) {
    return baseCost * (currentLevel + 1);
  }
}
