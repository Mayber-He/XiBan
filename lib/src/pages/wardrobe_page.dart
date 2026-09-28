import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../wardrobe/wardrobe_controller.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key, required this.controller});

  final WardrobeController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今天穿什么',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '挑一套喜欢的穿搭，换个心情。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.checkroom_outlined, color: AppTheme.coral),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final current = controller.currentOutfit;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 2, 24, 28),
                    children: [
                      _CurrentOutfit(current: current),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '穿搭灵感',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '${wardrobeOutfits.length} 套',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < wardrobeOutfits.length;
                              index++
                            ) ...[
                              if (index > 0)
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              _OutfitRow(
                                outfit: wardrobeOutfits[index],
                                isCurrent:
                                    wardrobeOutfits[index].id == current.id,
                                onSelect: () => controller.select(
                                  wardrobeOutfits[index].id,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (controller.hasError) ...[
                        const SizedBox(height: 12),
                        Text(
                          '穿搭暂时无法保存，请稍后重试。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        'AI 角色插画 · 穿搭为原创灵感示意',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CurrentOutfit extends StatelessWidget {
  const _CurrentOutfit({required this.current});
  final WardrobeOutfit current;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF2E8DE),
      borderRadius: BorderRadius.circular(22),
    ),
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        SizedBox(
          width: 132,
          height: 172,
          child: Image.asset(
            'assets/companion_portrait.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '正在穿着 · ${current.occasion}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.coral),
                ),
                const SizedBox(height: 8),
                Text(
                  current.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  current.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _OutfitRow extends StatelessWidget {
  const _OutfitRow({
    required this.outfit,
    required this.isCurrent,
    required this.onSelect,
  });

  final WardrobeOutfit outfit;
  final bool isCurrent;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '${outfit.name}，${outfit.occasion}穿搭示意',
    selected: isCurrent,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: outfit.backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(outfit.icon, color: outfit.accentColor, size: 21),
      ),
      title: Text(outfit.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('${outfit.occasion} · ${outfit.description}'),
      trailing: isCurrent
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.coral)
          : TextButton(
              key: Key('outfit-select-${outfit.id}'),
              onPressed: onSelect,
              child: const Text('换上'),
            ),
      onTap: isCurrent ? null : onSelect,
    ),
  );
}
