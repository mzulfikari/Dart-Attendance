# راهنمای ساخت APK - اپلیکیشن مدیریت حضور و غیاب نیرو برق

## پیش‌نیازها

### 1. نصب Flutter SDK
```bash
# دانلود Flutter SDK
# ویندوز: https://docs.flutter.dev/get-started/install/windows
# یا با Chocolatey:
choco install flutter

# یا با Scoop:
scoop install flutter
```

### 2. نصب Java JDK 17+
```bash
# ویندوز - از Oracle یا Adoptium:
# https://adoptium.net/temurin/releases/
# یا با Chocolatey:
choco install temurin17

# متغیر محیطی JAVA_HOME را تنظیم کنید:
# JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot
```

### 3. نصب Android Studio
```bash
# دانلود از: https://developer.android.com/studio
# در Android Studio:
# 1. Tools > SDK Manager > SDK Platforms > Android 14 (API 34) را تیک بزنید
# 2. SDK Tools > Android SDK Build-Tools 34.x.x را تیک بزنید
# 3. SDK Tools > Android Emulator را تیک بزنید
# 4. Apply > OK
```

### 4. تنظیم متغیرهای محیطی
```bash
# به PATH ویندوز اضافه کنید:
# %LOCALAPPDATA%\Android\Sdk\platform-tools
# %LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin
# مسیر flutter\bin
```

### 5. بررسی نصب
```bash
flutter doctor
flutter doctor --android-licenses
```

---

## مراحل ساخت APK

### 1. ورود به پوشه پروژه
```bash
cd attendance_app
```

### 2. تنظیم local.properties
فایل `android/local.properties` را باز کنید و مسیر Flutter SDK را تنظیم کنید:
```properties
flutter.sdk=C:\src\flutter
flutter.versionCode=1
flutter.versionName=1.0.0
```

### 3. دریافت dependencies
```bash
flutter pub get
```

### 4. تولید کد (اگر نیاز باشد)
```bash
# در صورت استفاده از code generation
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. ساخت APK Debug (برای تست)
```bash
flutter build apk --debug
```
خروجی: `build/app/outputs/flutter-apk/app-debug.apk`

### 6. ساخت APK Release (برای انتشار)
```bash
flutter build apk --release
```
خروجی: `build/app/outputs/flutter-apk/app-release.apk`

### 7. ساخت App Bundle (برای گوگل پلی)
```bash
flutter build appbundle --release
```
خروجی: `build/app/outputs/bundle/release/app-release.aab`

---

## امضای APK (برای انتشار رسمی)

### 1. تولید keystore
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. ایجاد key.properties
فایل `android/key.properties` بسازید:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 3. ویرایش android/app/build.gradle
در بخش `android`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

در ابتدای فایل (قبل از `android`):
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### 4. ساخت APK امضا شده
```bash
flutter build apk --release
```

---

## نصب روی گوشی

### روش 1: از طریق ADB
```bash
# گوشی را با کابل USB وصل کنید
# USB Debugging را در Developer Options فعال کنید
adb install build/app/outputs/flutter-apk/app-release.apk
```

### روش 2: انتقال فایل
فایل APK را به گوشی کپی کرده و از فایل منیجر نصب کنید.

---

## عیب‌یابی رایج

### خطای "Flutter SDK not found"
```bash
# مسیر flutter در local.properties را بررسی کنید
flutter doctor -v
```

### خطای "SDK location not found"
```bash
# Android SDK مسیر درست در local.properties یا ANDROID_HOME تنظیم شده باشد
```

### خطای Gradle version
```bash
# در android/gradle/wrapper/gradle-wrapper.properties:
# distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
```

### خطای "minSdkVersion"
```bash
# در android/app/build.gradle:
# minSdkVersion 21
```

### خطای permission
```bash
# در AndroidManifest.xml permission ها بررسی شده باشند
# برای Android 13+ باید در Runtime هم permission بگیرید
```

---

## ساختار پروژه

```
attendance_app/
├── android/                 # پروژه اندروید
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/electrical/attendance/MainActivity.kt
│   │       └── res/
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradle.properties
│   └── gradlew / gradlew.bat
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── models.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   └── report_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── workers_screen.dart
│   │   ├── worker_form_screen.dart
│   │   ├── worker_detail_screen.dart
│   │   ├── attendance_screen.dart
│   │   └── reports_screen.dart
│   └── utils/
│       └── jalali_utils.dart
├── pubspec.yaml
└── BUILD_INSTRUCTIONS.md
```

---

## ویژگی‌های اپلیکیشن

✅ **مدیریت نیروها**: افزودن، ویرایش، حذف، فعال/غیرفعال
✅ **ثبت حضور و غیاب**: حاضر، غایب، دیر، مرخصی، ماموریت
✅ **تقویم جلالی**: انتخاب تاریخ با تقویم شمسی
✅ **گزارش‌گیری**:
  - گزارش روزانه (PDF)
  - گزارش ماهانه (PDF + Excel)
  - گزارش فردی کارمند (PDF)
✅ **دیتابیس محلی**: SQLite (sqflite) - آفلاین کار می‌کند
✅ **رابط کاربری فارسی**: RTL، فونت فارسی، اعداد فارسی
✅ **ماتریال دیزاین 3**: UI مدرن و ساده

---

## پشتیبانی

برای سوال یا مشکل:
- چک کنید `flutter doctor -v`
- لاگ‌های Gradle در `android/.gradle` را بررسی کنید
- در صورت بروز خطا، `flutter clean` و مجدداً `flutter pub get` کنید