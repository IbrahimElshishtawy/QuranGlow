// lib/features/ui/pages/downloads/downloads_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/downloads/DownloadsPageState.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  final bool embedded;
  const DownloadsPage({super.key, this.embedded = true});

  @override
  ConsumerState<DownloadsPage> createState() => DownloadsPageState();
}
