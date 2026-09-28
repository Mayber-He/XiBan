import 'package:shared_preferences/shared_preferences.dart';

import 'model_config.dart';

abstract interface class ModelConfigRepository {
  Future<ModelConfig?> load();
  Future<void> save(ModelConfig config);
  Future<void> clear();
}

class SharedPreferencesModelConfigRepository implements ModelConfigRepository {
  SharedPreferencesModelConfigRepository({this.preferences});
  final SharedPreferences? preferences;
  Future<SharedPreferences> get _store async =>
      preferences ?? SharedPreferences.getInstance();
  static const _baseUrlKey = 'model_base_url_v1';
  static const _apiKeyKey = 'model_api_key_v1';
  static const _modelKey = 'model_name_v1';

  @override
  Future<ModelConfig?> load() async {
    final store = await _store;
    final baseUrl = store.getString(_baseUrlKey);
    final apiKey = store.getString(_apiKeyKey);
    final model = store.getString(_modelKey);
    if (baseUrl == null || apiKey == null || model == null) return null;
    return ModelConfig(baseUrl: baseUrl, apiKey: apiKey, model: model);
  }

  @override
  Future<void> save(ModelConfig config) async {
    final store = await _store;
    await store.setString(_baseUrlKey, config.baseUrl.trim());
    await store.setString(_apiKeyKey, config.apiKey.trim());
    await store.setString(_modelKey, config.model.trim());
  }

  @override
  Future<void> clear() async {
    final store = await _store;
    await store.remove(_baseUrlKey);
    await store.remove(_apiKeyKey);
    await store.remove(_modelKey);
  }
}
