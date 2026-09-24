import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'memory/memory_repository.dart';
import 'theme/app_theme.dart';

class CompanionApp extends StatelessWidget {
  const CompanionApp({super.key, this.memoryRepository});

  final MemoryRepository? memoryRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '陪伴时光',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(memoryRepository: memoryRepository),
    );
  }
}
