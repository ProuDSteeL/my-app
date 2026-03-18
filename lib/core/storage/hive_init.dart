import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'hive_keys.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  // Type adapters will be registered here as models are created
  // Open essential boxes
  await Future.wait([
    Hive.openBox<String>(HiveKeys.syncQueueBox),
    Hive.openBox<dynamic>(HiveKeys.userPrefsBox),
  ]);
}
