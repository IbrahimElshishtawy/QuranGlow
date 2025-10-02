// lib/core/service/goals_service.dart
import 'package:quranglow/core/model/Goal.dart';

class GoalsService {
  Future<List<Goal>> listGoals() async {
    // مؤقتًا: بيانات وهمية
    return [
      Goal(title: 'ختمة رمضان', progress: .62),
      Goal(title: 'ورد اليوم', progress: .35),
      Goal(title: 'حفظ جزء عمّ', progress: .12),
    ];
  }
}
