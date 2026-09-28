import 'package:flutter/foundation.dart';

import 'model_config.dart';
import 'model_config_repository.dart';

class ModelConfigController extends ChangeNotifier {
  ModelConfigController({required this.repository});
  final ModelConfigRepository repository;
  ModelConfig? _config;
  bool _isLoading = true;
  bool _hasError = false;

  ModelConfig? get config => _config;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isConfigured => _config?.isConfigured ?? false;

  Future<void> load() async {
    try {
      _config = await repository.load();
      _hasError = false;
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(ModelConfig config) async {
    await repository.save(config);
    _config = config;
    _hasError = false;
    notifyListeners();
  }

  Future<void> clear() async {
    await repository.clear();
    _config = null;
    _hasError = false;
    notifyListeners();
  }
}
