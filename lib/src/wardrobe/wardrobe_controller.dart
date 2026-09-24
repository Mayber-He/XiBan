import 'package:flutter/material.dart';

import '../character/character_state.dart';
import 'outfit_repository.dart';

class WardrobeOutfit {
  const WardrobeOutfit({
    required this.id,
    required this.name,
    required this.occasion,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String id;
  final String name;
  final String occasion;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}

const wardrobeOutfits = <WardrobeOutfit>[
  WardrobeOutfit(
    id: 'daily',
    name: '午后漫步',
    occasion: '日常',
    description: '柔软针织与轻盈长裙',
    icon: Icons.wb_sunny_outlined,
    accentColor: Color(0xFFA75B4D),
    backgroundColor: Color(0xFFF7E7DF),
  ),
  WardrobeOutfit(
    id: 'home',
    name: '慵懒时光',
    occasion: '居家',
    description: '舒适家居服的穿搭灵感',
    icon: Icons.weekend_outlined,
    accentColor: Color(0xFF7C6E9A),
    backgroundColor: Color(0xFFEDE9F3),
  ),
  WardrobeOutfit(
    id: 'commute',
    name: '轻简通勤',
    occasion: '通勤',
    description: '清爽利落的日常搭配',
    icon: Icons.directions_walk_rounded,
    accentColor: Color(0xFF557A73),
    backgroundColor: Color(0xFFE4EFEB),
  ),
  WardrobeOutfit(
    id: 'festival',
    name: '节日小聚',
    occasion: '节日',
    description: '带一点亮色的特别搭配',
    icon: Icons.auto_awesome_outlined,
    accentColor: Color(0xFF9A713F),
    backgroundColor: Color(0xFFF4ECDD),
  ),
];

class WardrobeController extends ChangeNotifier {
  WardrobeController({required this.repository, required this.characterState});

  final OutfitRepository repository;
  final ValueNotifier<CharacterState> characterState;
  bool _isLoading = true;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  WardrobeOutfit get currentOutfit => wardrobeOutfits.firstWhere(
    (outfit) => outfit.id == characterState.value.currentOutfitId,
    orElse: () => wardrobeOutfits.first,
  );

  Future<void> load() async {
    try {
      final savedId = await repository.loadCurrentOutfitId();
      if (wardrobeOutfits.any((outfit) => outfit.id == savedId)) {
        characterState.value = characterState.value.withOutfit(savedId!);
      }
      _hasError = false;
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> select(String outfitId) async {
    if (!wardrobeOutfits.any((outfit) => outfit.id == outfitId)) return;
    try {
      await repository.saveCurrentOutfitId(outfitId);
      characterState.value = characterState.value.withOutfit(outfitId);
      _hasError = false;
    } catch (_) {
      _hasError = true;
    }
    notifyListeners();
  }
}
