class AdhanSoundOption {
  const AdhanSoundOption({
    required this.id,
    required this.label,
    required this.resourceName,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String resourceName;
  final String assetPath;
}

class AdhanSounds {
  static const makkah = AdhanSoundOption(
    id: 'makkah',
    label: 'أذان مكة',
    resourceName: 'adhan_makkah',
    assetPath: 'android/app/src/main/res/raw/adhan_makkah.mp3',
  );

  static const madinah = AdhanSoundOption(
    id: 'madinah',
    label: 'أذان المدينة',
    resourceName: 'adhan_madinah',
    assetPath: 'android/app/src/main/res/raw/adhan_madinah.mp3',
  );

  static const alAqsa = AdhanSoundOption(
    id: 'alaqsa',
    label: 'أذان الأقصى',
    resourceName: 'adhan_alaqsa',
    assetPath: 'android/app/src/main/res/raw/adhan_alaqsa.mp3',
  );

  static const values = <AdhanSoundOption>[makkah, madinah, alAqsa];

  static AdhanSoundOption byId(String id) {
    for (final option in values) {
      if (option.id == id) return option;
    }
    return makkah;
  }
}
