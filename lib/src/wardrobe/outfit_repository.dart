import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OutfitRepository {
  Future<String?> loadCurrentOutfitId();
  Future<void> saveCurrentOutfitId(String outfitId);
}

class SharedPreferencesOutfitRepository implements OutfitRepository {
  SharedPreferencesOutfitRepository({this.preferences});

  static const _currentOutfitKey = 'companion_current_outfit_v1';

  final SharedPreferences? preferences;

  Future<SharedPreferences> get _store async =>
      preferences ?? SharedPreferences.getInstance();

  @override
  Future<String?> loadCurrentOutfitId() async =>
      (await _store).getString(_currentOutfitKey);

  @override
  Future<void> saveCurrentOutfitId(String outfitId) async {
    await (await _store).setString(_currentOutfitKey, outfitId);
  }
}

class InMemoryOutfitRepository implements OutfitRepository {
  String? _currentId;

  @override
  Future<String?> loadCurrentOutfitId() async => _currentId;

  @override
  Future<void> saveCurrentOutfitId(String outfitId) async {
    _currentId = outfitId;
  }
}
