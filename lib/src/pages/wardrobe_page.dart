import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../wardrobe/wardrobe_controller.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key, required this.controller});

  final WardrobeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日衣橱',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '挑一套喜欢的穿搭，让陪伴更有日常感。',
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 650 ? 3 : 2;
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                          children: [
                            Card(
                              color: const Color(0xFFFFF2ED),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppTheme.coral,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '当前穿着：${current.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.hasError) ...[
                              const SizedBox(height: 10),
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Text('穿搭保存失败，请稍后重试。'),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: wardrobeOutfits.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 284,
                                  ),
                              itemBuilder: (context, index) {
                                final outfit = wardrobeOutfits[index];
                                final isCurrent = outfit.id == current.id;
                                return _OutfitCard(
                                  outfit: outfit,
                                  isCurrent: isCurrent,
                                  onSelect: () => controller.select(outfit.id),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '原创矢量穿搭示意 · 非真人照片。授权素材接入后可替换为正式角色服装。',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        );
                      },
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
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.outfit,
    required this.isCurrent,
    required this.onSelect,
  });

  final WardrobeOutfit outfit;
  final bool isCurrent;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${outfit.name}，${outfit.occasion}穿搭示意，非真人照片',
      selected: isCurrent,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isCurrent ? AppTheme.coral : AppTheme.border,
            width: isCurrent ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          outfit.backgroundColor,
                          outfit.backgroundColor.withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -18,
                    top: -26,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.36),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 96,
                      height: 112,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(42),
                      ),
                      child: Icon(
                        outfit.icon,
                        size: 44,
                        color: outfit.accentColor,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        outfit.occasion,
                        style: TextStyle(
                          color: outfit.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.coral,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    outfit.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: isCurrent
                        ? FilledButton.tonal(
                            onPressed: null,
                            child: const Text('正在穿着'),
                          )
                        : OutlinedButton(
                            key: Key('outfit-select-${outfit.id}'),
                            onPressed: onSelect,
                            child: const Text('换上这套'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
