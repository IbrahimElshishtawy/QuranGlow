import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class TafsirReaderPage extends StatelessWidget {
  const TafsirReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as TafsirArgs?;
    final surah = args?.surah ?? 1;
    final ayah = args?.ayah ?? 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('تفسير: سورة $surah آية $ayah')),
        body: Center(
          child: Text(
            'هنا حمّل التفسير الفعلي حسب السورة والآية',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
