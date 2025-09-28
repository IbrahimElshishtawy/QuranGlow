import 'package:quranglow/core/model/aya.dart';

class Surah {
  final int number;
  final String name;
  final List<Aya> ayat;

  Surah({required this.number, required this.name, required this.ayat});
}
