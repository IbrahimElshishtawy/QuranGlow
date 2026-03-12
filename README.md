# QuranGlow

<div align="center">
  <img src="assets/iosn/icongrowquran.jpg" alt="QuranGlow Logo" width="120" />
  <h1>QuranGlow</h1>
  <p>تطبيق قرآني حديث يجمع بين القراءة، الاستماع، التفسير، الأذكار، القبلة، والتنزيلات في تجربة واحدة أنيقة وسريعة.</p>
  <p>
    <a href="https://github.com/IbrahimElshishtawy/QuranGlow/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/IbrahimElshishtawy/QuranGlow?display_name=tag&style=for-the-badge"></a>
    <a href="https://github.com/IbrahimElshishtawy/QuranGlow/releases/latest/download/app-release.apk"><img alt="Download APK" src="https://img.shields.io/badge/Download-APK-0f766e?style=for-the-badge&logo=android"></a>
    <a href="#-التشغيل-محلياً"><img alt="Flutter" src="https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"></a>
  </p>
</div>

## لماذا QuranGlow؟

`QuranGlow` ليس مجرد قارئ للمصحف، بل مساحة يومية متكاملة تساعد المستخدم على القراءة والتدبر والاستماع والمتابعة بشكل منظم وسهل.

- مصحف واضح وتجربة قراءة مريحة.
- مشغل صوتي لتلاوات القرآن مع إمكانيات تنزيل المقاطع.
- تفسير للآيات للوصول إلى المعنى بسرعة.
- أذكار وتسبيح ضمن التطبيق.
- اتجاه القبلة ومواقيت الصلاة.
- بحث داخل المحتوى ومحفوظات للرجوع السريع.
- أهداف وإحصاءات لمتابعة الاستمرار اليومي.
- إشعارات ومزامنة مدعومة بـ Firebase.

## المميزات الرئيسية

| الميزة | الوصف |
| --- | --- |
| المصحف | تصفح وقراءة القرآن بواجهة عربية حديثة |
| التفسير | استعراض تفسير الآيات من داخل التطبيق |
| الصوتيات | تشغيل التلاوات وإدارة التنزيلات |
| البحث | الوصول السريع إلى السور والآيات والمحتوى |
| الأذكار | أذكار يومية مع سبحة رقمية |
| القبلة | تحديد اتجاه القبلة من داخل التطبيق |
| الإحصاءات | متابعة الأهداف والتقدم والاستخدام |
| الإشعارات | تذكيرات وتنبيهات قابلة للإدارة |

## التحميل

يمكن تحميل آخر نسخة مباشرة من GitHub Releases:

- [تحميل APK مباشرة](https://github.com/IbrahimElshishtawy/QuranGlow/releases/latest/download/app-release.apk)
- [فتح صفحة آخر إصدار](https://github.com/IbrahimElshishtawy/QuranGlow/releases/latest)

حتى يعمل رابط التحميل المباشر بشكل صحيح، ارفع ملف الـ APK في كل Release بهذا الاسم بالضبط:

`app-release.apk`

الملف الجاهز لديك حالياً موجود هنا:

`build/app/outputs/flutter-apk/app-release.apk`

## كيف تنشر النسخة على GitHub

بعد ما تجهز نسخة الـ release:

```bash
flutter build apk --release
```

ثم:

1. افتح صفحة `Releases` في GitHub.
2. أنشئ `New release`.
3. ارفع الملف الموجود في `build/app/outputs/flutter-apk/app-release.apk`.
4. لا تغيّر اسم الملف، واتركه `app-release.apk`.
5. انشر الـ Release.

بعدها سيعمل زر التحميل الموجود في هذا `README` تلقائياً على آخر إصدار.

## لقطات مقترحة للعرض

إذا أردت أن يظهر المشروع بشكل أقوى على GitHub، أضف لاحقاً صوراً من التطبيق داخل مجلد مثل `docs/screenshots/` ثم ضعها هنا. أفضل لقطات للدعاية:

- الشاشة الرئيسية
- شاشة المصحف
- شاشة التفسير
- شاشة المشغل والتنزيلات
- شاشة القبلة أو الأذكار

## التشغيل محلياً

```bash
flutter pub get
flutter run
```

## التقنيات المستخدمة

- Flutter
- Riverpod
- Hive
- Firebase
- Just Audio
- Flutter Local Notifications

## جاهزية README

الروابط داخل هذا `README` مربوطة الآن مباشرة بالمستودع:

`IbrahimElshishtawy/QuranGlow`
