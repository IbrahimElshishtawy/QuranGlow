import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quranglow/core/widgets/pro_app_bar.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _developerName = 'Ibrahim Elshishtawy';
  static const _phone = '01223070571';
  static const _facebook =
      'https://www.facebook.com/p/Ibrahim-El-ShiShtawy-100025661886698/';
  static const _linkedin =
      'https://www.linkedin.com/in/ibrahim-elshishtawy-0a67b334a/?originalSubdomain=eg';
  static const _instagram = 'https://www.instagram.com/hima_shishtawy/';
  static const _github = 'https://github.com/IbrahimElshishtawy';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const ProAppBar(
          title: 'عن التطبيق',
          subtitle: 'تعرف على QuranGlow والمطور ووسائل التواصل',
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroCard(colorScheme: cs, theme: theme),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'QuranGlow',
              subtitle: 'تطبيق قرآني يومي مصمم لتجربة قراءة واستماع أكثر هدوءًا وتنظيمًا.',
              child: Column(
                children: const [
                  _FeatureTile(
                    icon: Icons.menu_book_rounded,
                    title: 'قراءة المصحف',
                    subtitle: 'تصفح السور، التنقل بين الآيات، وحفظ موضع القراءة.',
                  ),
                  _FeatureTile(
                    icon: Icons.headphones_rounded,
                    title: 'الاستماع والتنزيل',
                    subtitle: 'تشغيل السور والآيات مع مكتبة صوتية داخلية للتنزيلات.',
                  ),
                  _FeatureTile(
                    icon: Icons.auto_stories_rounded,
                    title: 'التفسير والبحث',
                    subtitle: 'الوصول السريع إلى التفسير والبحث داخل الآيات والسور.',
                  ),
                  _FeatureTile(
                    icon: Icons.flag_rounded,
                    title: 'الأهداف والمتابعة',
                    subtitle: 'متابعة الورد اليومي، الإحصائيات، والعادات القرآنية.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'المطور',
              subtitle: 'تم تطوير التطبيق بواسطة:',
              child: _ContactTile(
                icon: Icons.person_rounded,
                title: _developerName,
                value: 'Flutter Developer',
                onCopy: () => _copy(context, _developerName, 'اسم المطور'),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'التواصل',
              subtitle: 'تقدر تنسخ أي وسيلة تواصل أو تشارك بيانات المطور مباشرة.',
              child: Column(
                children: [
                  _ContactTile(
                    icon: Icons.phone_rounded,
                    title: 'رقم الهاتف',
                    value: _phone,
                    onCopy: () => _copy(context, _phone, 'رقم الهاتف'),
                  ),
                  _ContactTile(
                    icon: Icons.facebook_rounded,
                    title: 'Facebook',
                    value: _facebook,
                    onCopy: () => _copy(context, _facebook, 'رابط Facebook'),
                  ),
                  _ContactTile(
                    icon: Icons.work_rounded,
                    title: 'LinkedIn',
                    value: _linkedin,
                    onCopy: () => _copy(context, _linkedin, 'رابط LinkedIn'),
                  ),
                  _ContactTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Instagram',
                    value: _instagram,
                    onCopy: () => _copy(context, _instagram, 'رابط Instagram'),
                  ),
                  _ContactTile(
                    icon: Icons.code_rounded,
                    title: 'GitHub',
                    value: _github,
                    onCopy: () => _copy(context, _github, 'رابط GitHub'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مشاركة بيانات المطور',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مفيد لو حابب ترسل صفحة التواصل أو بيانات المطور لشخص آخر.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Share.share(_shareText),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('مشاركة المعلومات'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _shareText => [
        'QuranGlow',
        'المطور: $_developerName',
        'الهاتف: $_phone',
        'Facebook: $_facebook',
        'LinkedIn: $_linkedin',
        'Instagram: $_instagram',
        'GitHub: $_github',
      ].join('\n');

  static Future<void> _copy(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ $label')),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colorScheme, required this.theme});

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colorScheme.primary.withValues(alpha: 0.18),
            colorScheme.tertiary.withValues(alpha: 0.10),
            colorScheme.surface,
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.96),
                  colorScheme.primary.withValues(alpha: 0.74),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: colorScheme.onPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QuranGlow',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تجربة قرآنية تجمع بين المصحف، الاستماع، التفسير، الأهداف، والتنزيلات في واجهة واحدة.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    value,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'نسخ',
              onPressed: onCopy,
              icon: const Icon(Icons.content_copy_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
