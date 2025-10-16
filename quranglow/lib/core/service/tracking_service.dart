import 'package:quranglow/core/storage/local_storage.dart';

class TrackingService {
  final LocalStorage storage;
  TrackingService(this.storage);

  static const _kStats = 'stats_v1';

  Future<Map<String, dynamic>> _load() async =>
      storage.getMap(_kStats) ??
      {
        'totalSeconds': 0,
        'ayatCount': 0,
        'sessions': 0,
        'streakDays': 0,
        'lastDay': '',
        'weekly': List<int>.filled(7, 0),
        'activeStart': null, // ISO string
      };

  Future<void> _save(Map<String, dynamic> m) async =>
      storage.putMap(_kStats, m);

  /// يبدأ جلسة قراءة
  Future<void> startSession() async {
    final m = await _load();
    if (m['activeStart'] == null) {
      m['activeStart'] = DateTime.now().toIso8601String();
      m['sessions'] = (m['sessions'] as int) + 1;
      // حساب الستريك
      final today = DateTime.now();
      final dayStr = '${today.year}-${today.month}-${today.day}';
      final last = m['lastDay'] as String? ?? '';
      if (last.isEmpty) {
        m['streakDays'] = 1;
      } else {
        final parts = last.split('-').map(int.parse).toList();
        final lastDate = DateTime(parts[0], parts[1], parts[2]);
        final diff = today.difference(lastDate).inDays;
        if (diff == 1) {
          m['streakDays'] = (m['streakDays'] as int) + 1;
        } else if (diff > 1) {
          m['streakDays'] = 1;
        }
      }
      m['lastDay'] = dayStr;
      await _save(m);
    }
  }

  /// ينهي الجلسة ويضيف مدتها
  Future<void> endSession() async {
    final m = await _load();
    final startIso = m['activeStart'] as String?;
    if (startIso != null) {
      final start = DateTime.parse(startIso);
      final sec = DateTime.now().difference(start).inSeconds;
      m['totalSeconds'] = (m['totalSeconds'] as int) + sec;
      m['activeStart'] = null;

      // تحديث weekly: اليوم من 0..6 (السبت..الجمعة حسب احتياجك)
      final dow = DateTime.now().weekday; // 1..7 (الإثنين..الأحد)
      final idx = (dow % 7); // 0..6
      final weekly = (m['weekly'] as List).cast<int>();
      final val = weekly[idx];
      // نحول الوقت إلى نسبة تقريبية 0..100
      final pct = ((sec / 1800) * 100).clamp(0, 100).toInt(); // 30 دقيقة = 100%
      weekly[idx] = (val + pct).clamp(0, 100);
      m['weekly'] = weekly;

      await _save(m);
    }
  }

  /// زيادة عدد الآيات المقروءة
  Future<void> incAyat(int count) async {
    final m = await _load();
    m['ayatCount'] = (m['ayatCount'] as int) + count;
    await _save(m);
  }

  /// إرجاع ملخص للإحصائيات
  Future<Map<String, dynamic>> getStats() => _load();
}
