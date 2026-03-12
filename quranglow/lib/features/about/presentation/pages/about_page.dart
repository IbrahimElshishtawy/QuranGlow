import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quranglow/core/widgets/pro_app_bar.dart';
import 'package:quranglow/features/about/presentation/widgets/about_contact_tile.dart';
import 'package:quranglow/features/about/presentation/widgets/about_feature_tile.dart';
import 'package:quranglow/features/about/presentation/widgets/about_hero_card.dart';
import 'package:quranglow/features/about/presentation/widgets/about_section_card.dart';
import 'package:quranglow/features/about/presentation/widgets/about_share_card.dart';
import 'package:url_launcher/url_launcher.dart';

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
            const AboutHeroCard(),
            const SizedBox(height: 14),
            const AboutSectionCard(
              title: 'QuranGlow',
              subtitle:
                  'تطبيق قرآني يومي مصمم لتجربة قراءة واستماع أكثر هدوءًا وتنظيمًا.',
              child: Column(
                children: [
                  AboutFeatureTile(
                    icon: Icons.menu_book_rounded,
                    title: 'قراءة المصحف',
                    subtitle:
                        'تصفح السور، التنقل بين الآيات، وحفظ موضع القراءة.',
                  ),
                  AboutFeatureTile(
                    icon: Icons.headphones_rounded,
                    title: 'الاستماع والتنزيل',
                    subtitle:
                        'تشغيل السور والآيات مع مكتبة صوتية داخلية للتنزيلات.',
                  ),
                  AboutFeatureTile(
                    icon: Icons.auto_stories_rounded,
                    title: 'التفسير والبحث',
                    subtitle:
                        'الوصول السريع إلى التفسير والبحث داخل الآيات والسور.',
                  ),
                  AboutFeatureTile(
                    icon: Icons.flag_rounded,
                    title: 'الأهداف والمتابعة',
                    subtitle:
                        'متابعة الورد اليومي، الإحصائيات، والعادات القرآنية.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AboutSectionCard(
              title: 'المطور',
              subtitle: 'تم تطوير التطبيق بواسطة:',
              child: AboutContactTile(
                icon: Icons.person_rounded,
                title: _developerName,
                value: 'Flutter Developer',
                onCopy: () => _copy(context, _developerName, 'اسم المطور'),
              ),
            ),
            const SizedBox(height: 14),
            AboutSectionCard(
              title: 'التواصل',
              subtitle:
                  'يمكنك نسخ أي وسيلة تواصل أو الضغط على الزر للانتقال للرابط مباشرة.',
              child: Column(
                children: [
                  AboutContactTile(
                    icon: Icons.phone_rounded,
                    title: 'رقم الهاتف',
                    value: _phone,
                    onCopy: () => _copy(context, _phone, 'رقم الهاتف'),
                  ),
                  AboutContactTile(
                    icon: Icons.facebook_rounded,
                    title: 'Facebook',
                    value: _facebook,
                    onCopy: () => _copy(context, _facebook, 'رابط Facebook'),
                    onOpen: () => _openLink(context, _facebook, 'Facebook'),
                  ),
                  AboutContactTile(
                    icon: Icons.work_rounded,
                    title: 'LinkedIn',
                    value: _linkedin,
                    onCopy: () => _copy(context, _linkedin, 'رابط LinkedIn'),
                    onOpen: () => _openLink(context, _linkedin, 'LinkedIn'),
                  ),
                  AboutContactTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Instagram',
                    value: _instagram,
                    onCopy: () => _copy(context, _instagram, 'رابط Instagram'),
                    onOpen: () => _openLink(context, _instagram, 'Instagram'),
                  ),
                  AboutContactTile(
                    icon: Icons.code_rounded,
                    title: 'GitHub',
                    value: _github,
                    onCopy: () => _copy(context, _github, 'رابط GitHub'),
                    onOpen: () => _openLink(context, _github, 'GitHub'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AboutShareCard(
              shareText: _shareText,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم نسخ $label')));
  }

  static Future<void> _openLink(
    BuildContext context,
    String value,
    String label,
  ) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر فتح $label')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر فتح $label')));
    }
  }
}
