import 'package:flutter/widgets.dart';

import 'src/companion_app.dart';
import 'src/memory/memory_repository.dart';
import 'src/wardrobe/outfit_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CompanionApp(
      memoryRepository: SharedPreferencesMemoryRepository(),
      outfitRepository: SharedPreferencesOutfitRepository(),
    ),
  );
}
