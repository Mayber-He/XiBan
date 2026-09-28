import 'package:flutter/material.dart';

import '../chat/model_config.dart';
import '../chat/model_config_controller.dart';

class ModelSettingsPage extends StatefulWidget {
  const ModelSettingsPage({super.key, required this.controller});
  final ModelConfigController controller;

  @override
  State<ModelSettingsPage> createState() => _ModelSettingsPageState();
}

class _ModelSettingsPageState extends State<ModelSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrl = TextEditingController();
  final _apiKey = TextEditingController();
  final _model = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _baseUrl.dispose();
    _apiKey.dispose();
    _model.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized || widget.controller.isLoading) return;
    _initialized = true;
    final config = widget.controller.config;
    if (config == null) return;
    _baseUrl.text = config.baseUrl;
    _apiKey.text = config.apiKey;
    _model.text = config.model;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.controller.save(
        ModelConfig(
          baseUrl: _baseUrl.text.trim(),
          apiKey: _apiKey.text.trim(),
          model: _model.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('模型配置已保存')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存失败，请检查本机存储权限')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    await widget.controller.clear();
    _baseUrl.clear();
    _apiKey.clear();
    _model.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已清除配置，聊天将使用本地演示')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模型配置')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          _initialize();
          if (widget.controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OpenAI 兼容接口',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '支持提供 /chat/completions 的 OpenAI 格式服务。保存后聊天会立即使用此模型；清除配置则恢复本地演示回复。',
                          ),
                          const SizedBox(height: 16),
                          _form(),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: _saving ? null : _save,
                                icon: const Icon(Icons.save_outlined),
                                label: Text(_saving ? '保存中…' : '保存配置'),
                              ),
                              if (widget.controller.isConfigured)
                                OutlinedButton.icon(
                                  onPressed: _saving ? null : _clear,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('清除配置'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '连接状态',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                widget.controller.isConfigured
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: widget.controller.isConfigured
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.controller.isConfigured
                                    ? '已配置 · ${widget.controller.config!.model}'
                                    : '未配置 · 当前使用本地演示',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'API Key 保存在此设备的应用偏好设置中。请求会直接从客户端发送到你填写的服务商；请勿在不可信设备上保存密钥。',
                          ),
                          if (widget.controller.hasError)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('读取配置失败，请检查本机存储权限。'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _form() => Form(
    key: _formKey,
    child: Column(
      children: [
        TextFormField(
          controller: _baseUrl,
          key: const Key('model-base-url'),
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'https://api.example.com/v1',
            helperText: '可填写 API 根地址，也可直接填写到 /chat/completions',
          ),
          validator: (value) =>
              _required(value, 'Base URL') ?? _validUrl(value),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _apiKey,
          key: const Key('model-api-key'),
          obscureText: _obscureKey,
          decoration: InputDecoration(
            labelText: 'API Key',
            hintText: 'sk-…',
            suffixIcon: IconButton(
              tooltip: _obscureKey ? '显示密钥' : '隐藏密钥',
              onPressed: () => setState(() => _obscureKey = !_obscureKey),
              icon: Icon(
                _obscureKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) => _required(value, 'API Key'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _model,
          key: const Key('model-name'),
          decoration: const InputDecoration(
            labelText: '模型名称',
            hintText: 'gpt-4o-mini',
          ),
          validator: (value) => _required(value, '模型名称'),
        ),
      ],
    ),
  );

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '请输入$label' : null;
  String? _validUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    return uri == null ||
            !uri.hasScheme ||
            uri.host.isEmpty ||
            !{'http', 'https'}.contains(uri.scheme.toLowerCase())
        ? '请输入有效的 HTTP 或 HTTPS 地址'
        : null;
  }
}
