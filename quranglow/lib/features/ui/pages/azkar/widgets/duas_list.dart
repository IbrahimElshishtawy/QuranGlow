// lib/features/ui/pages/azkar/widgets/duas_list.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../../../core/model/reminder/dua.dart';

class DuasList extends StatelessWidget {
  const DuasList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final duas = _seedDuas;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final d = duas[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(d.title, style: t.titleMedium),
                const SizedBox(height: 8),
                Text(d.text, textAlign: TextAlign.justify),
                if (d.ref != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'المصدر: ${d.ref}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: duas.length,
    );
  }
}

final List<Dua> _seedDuas = [
  Dua(
    title: 'دعاء الاستغفار',
    text: 'اللهم إنك عفو كريم تحب العفو فاعفُ عني.',
    ref: 'سنن الترمذي',
  ),
  Dua(
    title: 'دعاء الهمّ',
    text:
        'اللهم إني أعوذ بك من الهم والحَزَن، وأعوذ بك من العجز والكسل، وأعوذ بك من الجُبن والبُخل، وأعوذ بك من غلبة الدَّين وقهر الرجال.',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء السفر',
    text: 'سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون.',
    ref: 'صحيح مسلم',
  ),
  Dua(
    title: 'دعاء قبل النوم',
    text: 'باسمك اللهم أحيا وباسمك أموت.',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء الاستيقاظ',
    text: 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور.',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء الخروج من المنزل',
    text: 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.',
    ref: 'سنن أبي داود',
  ),
  Dua(
    title: 'دعاء دخول المنزل',
    text:
        'اللهم إني أسألك خير المولج وخير المخرج، بسم الله ولجنا وبسم الله خرجنا وعلى الله ربنا توكلنا.',
    ref: 'سنن أبي داود',
  ),
  Dua(
    title: 'دعاء دخول المسجد',
    text: 'اللهم افتح لي أبواب رحمتك.',
    ref: 'صحيح مسلم',
  ),
  Dua(
    title: 'دعاء الخروج من المسجد',
    text: 'اللهم إني أسألك من فضلك.',
    ref: 'صحيح مسلم',
  ),
  Dua(
    title: 'دعاء لبس الثوب الجديد',
    text:
        'اللهم لك الحمد، أنت كسوتنيه، أسألك خيره وخير ما صُنع له، وأعوذ بك من شره وشر ما صُنع له.',
    ref: 'سنن أبي داود',
  ),
  Dua(
    title: 'دعاء دخول الخلاء',
    text: 'اللهم إني أعوذ بك من الخُبث والخبائث.',
    ref: 'صحيح البخاري',
  ),
  Dua(title: 'دعاء الخروج من الخلاء', text: 'غفرانك.', ref: 'سنن الترمذي'),
  Dua(
    title: 'دعاء الرزق',
    text: 'اللهم اكفني بحلالك عن حرامك، وأغنني بفضلك عمن سواك.',
    ref: 'الترمذي',
  ),
  Dua(
    title: 'دعاء الكرب',
    text:
        'لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السماوات ورب الأرض ورب العرش الكريم.',
    ref: 'صحيح البخاري',
  ),
  Dua(title: 'دعاء المطر', text: 'اللهم صيبًا نافعًا.', ref: 'صحيح البخاري'),
  Dua(
    title: 'دعاء عند رؤية الهلال',
    text:
        'اللهم أهله علينا بالأمن والإيمان، والسلامة والإسلام، والتوفيق لما تحب وترضى.',
    ref: 'الترمذي',
  ),
  Dua(
    title: 'دعاء الخوف',
    text: 'حسبنا الله ونعم الوكيل.',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء المريض',
    text:
        'اللهم رب الناس أذهب البأس، اشفِ أنت الشافي، لا شفاء إلا شفاؤك شفاءً لا يغادر سقمًا.',
    ref: 'صحيح البخاري',
  ),
  Dua(
    title: 'دعاء للموتى',
    text: 'اللهم اغفر له وارحمه، وعافه واعف عنه، وأكرم نزله، ووسع مدخله.',
    ref: 'صحيح مسلم',
  ),
  Dua(
    title: 'دعاء الرضا بالقضاء',
    text:
        'اللهم رضِّني بما قضيت لي، حتى لا أحب تأخير ما عجلت، ولا تعجيل ما أخرت.',
    ref: 'الحاكم',
  ),
];
