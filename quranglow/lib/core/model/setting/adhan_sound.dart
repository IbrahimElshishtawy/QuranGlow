class AdhanSoundOption {
  const AdhanSoundOption({
    required this.id,
    required this.label,
    required this.resourceName,
  });

  final String id;
  final String label;
  final String resourceName;
}

class AdhanSounds {
  static const makkah = AdhanSoundOption(
    id: 'makkah',
    label: 'أذان مكة',
    resourceName: 'adhan_makkah',
  );

  static const madinah = AdhanSoundOption(
    id: 'madinah',
    label: 'أذان المدينة',
    resourceName: 'adhan_madinah',
  );

  static const alAqsa = AdhanSoundOption(
    id: 'alaqsa',
    label: 'أذان الأقصى',
    resourceName: 'adhan_alaqsa',
  );

  static const values = <AdhanSoundOption>[makkah, madinah, alAqsa];

  static AdhanSoundOption byId(String id) {
    for (final option in values) {
      if (option.id == id) return option;
    }
    return makkah;
  }
}
