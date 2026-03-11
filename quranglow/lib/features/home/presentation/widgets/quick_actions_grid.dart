import 'package:flutter/material.dart';
import 'package:quranglow/features/home/presentation/widgets/home_surface_card.dart';
import 'package:quranglow/features/home/presentation/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _actions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('إجراءات سريعة'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth;
            final cross = w < 600 ? 2 : (w < 900 ? 3 : 4);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.04,
              ),
              itemBuilder: (_, i) => _ActionCard(item: items[i]),
            );
          },
        ),
      ],
    );
  }

  List<_ActionItem> _actions(BuildContext context) => [
    _ActionItem(
      'التفسير',
      Icons.menu_book_outlined,
      () => Navigator.pushNamed(context, AppRoutes.tafsir),
    ),
    _ActionItem(
      'السور',
      Icons.list_alt_rounded,
      () => Navigator.pushNamed(context, AppRoutes.surahs),
    ),
    _ActionItem(
      'القبلة',
      Icons.explore_rounded,
      () => Navigator.pushNamed(context, AppRoutes.qibla),
    ),
    _ActionItem(
      'المحفوظات',
      Icons.bookmark_rounded,
      () => Navigator.pushNamed(context, AppRoutes.bookmarks),
    ),
    _ActionItem(
      'التنزيلات',
      Icons.download_rounded,
      () => Navigator.pushNamed(context, AppRoutes.downloads),
    ),
    _ActionItem(
      'الإحصائيات',
      Icons.insights_rounded,
      () => Navigator.pushNamed(context, AppRoutes.stats),
    ),
  ];
}

class _ActionItem {
  const _ActionItem(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: item.title,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: HomeSurfaceCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, size: 26, color: cs.primary),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
