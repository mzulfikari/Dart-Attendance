# مدیریت حضور و غیاب نیروهای برق

اپلیکیشن اندرویدی برای ثبت و مدیریت اطلاعات نیروهای پروژه‌های برق، کنترل روزانه حضور و غیاب و تهیه گزارش‌های قابل اشتراک‌گذاری. این پروژه با **Flutter و Dart** توسعه داده شده و اطلاعات اصلی را در پایگاه داده محلی **SQLite** نگهداری می‌کند.

<p align="center">
  <a href="https://github.com/mzulfikari/Dart-Attendance/actions/workflows/blank.yml"><img src="https://github.com/mzulfikari/Dart-Attendance/actions/workflows/blank.yml/badge.svg?branch=main" alt="Android APK Build"></a>
  <img src="https://img.shields.io/badge/Flutter-3.22.2-02569B?logo=flutter&logoColor=white" alt="Flutter 3.22.2">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white" alt="SQLite">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License"></a>
</p>

<p align="center">
  <a href="https://github.com/mzulfikari/Dart-Attendance/actions/workflows/blank.yml">وضعیت ساخت APK</a>
  ·
  <a href="https://github.com/mzulfikari/Dart-Attendance/releases">نسخه‌های منتشرشده</a>
  ·
  <a href="https://github.com/mzulfikari/Dart-Attendance/issues">گزارش مشکل و پیشنهاد</a>
</p>

---

## فهرست مطالب

- [قابلیت‌ها](#قابلیت‌ها)
- [فناوری‌ها](#فناوری‌ها)
- [دریافت و نصب اپلیکیشن](#دریافت-و-نصب-اپلیکیشن)
- [راه‌اندازی محیط توسعه](#راه‌اندازی-محیط-توسعه)
- [ساخت APK](#ساخت-apk)
- [ساختار پروژه](#ساختار-پروژه)
- [مدل داده](#مدل-داده)
- [ذخیره‌سازی و حریم خصوصی](#ذخیره‌سازی-و-حریم-خصوصی)
- [ساخت خودکار با GitHub Actions](#ساخت-خودکار-با-github-actions)
- [آزمون و بررسی کد](#آزمون-و-بررسی-کد)
- [مشارکت در پروژه](#مشارکت-در-پروژه)
- [مجوز](#مجوز)

## قابلیت‌ها

### مدیریت نیروها
- ثبت نیروی جدید و ویرایش اطلاعات ثبت‌شده
- مشاهده فهرست نیروها و جزئیات هر نیرو
- فعال یا غیرفعال کردن نیروها
- نگهداری نام، کد ملی، شماره تماس، سمت شغلی و اطلاعات تماس اضطراری
- جلوگیری از ثبت کد ملی تکراری در سطح پایگاه داده

### ثبت حضور و غیاب
- ثبت وضعیت حضور هر نیرو برای یک روز مشخص
- انتخاب و نمایش تاریخ با تقویم شمسی
- ثبت ساعت ورود و خروج و توضیحات رکورد
- مشاهده سوابق حضور و غیاب هر نیرو
- ثبت یکی از پنج وضعیت زیر:

| مقدار | وضعیت | کاربرد |
|---:|---|---|
| 0 | حاضر | حضور عادی |
| 1 | غایب | عدم حضور |
| 2 | تأخیر | حضور با تأخیر |
| 3 | مرخصی | مرخصی کاری |
| 4 | مأموریت | مأموریت کاری |

برای هر نیرو، رکوردهای روزانه در منطق برنامه بر اساس روز تقویمی مدیریت می‌شوند؛ ثبت مجدد همان روز، رکورد موجود را به‌روزرسانی می‌کند.

### گزارش‌گیری و خروجی
- تهیه گزارش روزانه در قالب PDF
- تهیه گزارش ماهانه در قالب PDF
- تهیه گزارش ماهانه در قالب Excel
- تهیه گزارش اختصاصی نیروی انتخاب‌شده
- اشتراک‌گذاری فایل‌های گزارش از طریق امکانات دستگاه
- استفاده از فونت‌های همراه پروژه برای نمایش متن فارسی در گزارش PDF

### رابط کاربری فارسی
- زبان فارسی و چیدمان راست‌چین (RTL)
- تقویم شمسی و نمایش تاریخ با ارقام فارسی
- طراحی مبتنی بر Material Design 3

## فناوری‌ها

| فناوری / کتابخانه | کاربرد |
|---|---|
| [Flutter](https://flutter.dev/) | ساخت رابط کاربری اپلیکیشن |
| [Dart](https://dart.dev/) | زبان برنامه‌نویسی |
| [SQLite](https://www.sqlite.org/) | ذخیره‌سازی محلی داده‌ها |
| [sqflite](https://pub.dev/packages/sqflite) | دسترسی به پایگاه داده SQLite |
| [shamsi_date](https://pub.dev/packages/shamsi_date) | تبدیل و کار با تاریخ شمسی |
| [intl](https://pub.dev/packages/intl) | ابزارهای قالب‌بندی و محلی‌سازی |
| [pdf](https://pub.dev/packages/pdf) | تولید گزارش PDF |
| [printing](https://pub.dev/packages/printing) | ابزارهای چاپ و کار با PDF |
| [excel](https://pub.dev/packages/excel) | ساخت فایل Excel |
| [share_plus](https://pub.dev/packages/share_plus) | اشتراک‌گذاری فایل‌ها |
| [path_provider](https://pub.dev/packages/path_provider) | دسترسی به مسیرهای ذخیره‌سازی برنامه |

## دریافت و نصب اپلیکیشن

### دریافت APK آماده

1. وارد بخش [GitHub Actions](https://github.com/mzulfikari/Dart-Attendance/actions/workflows/blank.yml) شوید.
2. آخرین اجرای موفق با عنوان **Build Android APK** را باز کنید.
3. در قسمت **Artifacts**، فایل **attendance-apk** را دانلود کنید.
4. فایل ZIP دانلودشده را استخراج کنید و فایل <code>app-release.apk</code> را روی دستگاه اندرویدی نصب کنید.

Artifactهای Actions دائمی نیستند و طبق تنظیم فعلی Workflow پس از **۳۰ روز** منقضی می‌شوند. برای نسخه‌های منتشرشده، بخش [Releases](https://github.com/mzulfikari/Dart-Attendance/releases) را بررسی کنید.

> **نکته امضای APK:** اگر کلید امضای انتشار در Secrets مخزن تنظیم نشده باشد، Workflow فعلی از کلید امضای debug برای ساخت APK استفاده می‌کند. چنین فایلی برای تست مناسب است؛ برای انتشار پایدار و به‌روزرسانی مطمئن، کلید اختصاصی انتشار باید به‌درستی پیکربندی شود.

### نصب روی گوشی

1. فایل APK را به گوشی منتقل کنید.
2. در صورت نمایش هشدار، اجازه نصب از این منبع را در تنظیمات اندروید فعال کنید.
3. فایل APK را باز کنید و نصب را انجام دهید.
4. پس از نصب، برنامه را اجرا کنید.

## راه‌اندازی محیط توسعه

### پیش‌نیازها

- Flutter SDK سازگار با پروژه؛ Workflow فعلی از Flutter **3.22.2 stable** استفاده می‌کند.
- Dart SDK همراه نسخه سازگار Flutter
- Android Studio و Android SDK
- Java JDK 17 برای هم‌خوانی با محیط CI
- Git

برای بررسی نصب ابزارها:

~~~bash
flutter doctor
~~~

### دریافت و اجرای پروژه

~~~bash
git clone https://github.com/mzulfikari/Dart-Attendance.git
cd Dart-Attendance/attendance_app
~~~

وابستگی‌ها را نصب کنید:

~~~bash
flutter pub get
~~~

در صورت نیاز، مسیر Flutter SDK و Android SDK را در فایل محلی <code>android/local.properties</code> تنظیم کنید. این فایل مخصوص محیط توسعه است و نباید به مخزن ارسال شود.

اجرای برنامه روی شبیه‌ساز یا دستگاه متصل:

~~~bash
flutter run
~~~

برای راهنمای جزئی‌تر ساخت اندروید، فایل [attendance_app/BUILD_INSTRUCTIONS.md](attendance_app/BUILD_INSTRUCTIONS.md) را ببینید.

## ساخت APK

از داخل پوشه <code>attendance_app</code> دستور زیر را اجرا کنید:

~~~bash
flutter build apk --release
~~~

فایل خروجی در مسیر زیر ساخته می‌شود:

~~~text
attendance_app/build/app/outputs/flutter-apk/app-release.apk
~~~

برای ساخت نسخه آزمایشی Debug:

~~~bash
flutter build apk --debug
~~~

> فایل‌های خروجی پوشه <code>build/</code> تولیدی هستند و در مخزن نگهداری نمی‌شوند.

## ساختار پروژه

~~~text
Dart-Attendance/
├── .github/
│   └── workflows/
│       └── blank.yml                 # ساخت خودکار و انتشار APK
├── attendance_app/
│   ├── android/                      # تنظیمات بومی اندروید و Gradle
│   ├── assets/
│   │   └── fonts/                    # فونت‌های موردنیاز گزارش PDF
│   ├── lib/
│   │   ├── main.dart                 # نقطه ورود و پیکربندی برنامه
│   │   ├── models/
│   │   │   └── models.dart           # مدل‌های نیرو و حضور و غیاب
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── workers_screen.dart
│   │   │   ├── worker_form_screen.dart
│   │   │   ├── worker_detail_screen.dart
│   │   │   ├── attendance_screen.dart
│   │   │   └── reports_screen.dart
│   │   ├── services/
│   │   │   ├── database_service.dart # عملیات SQLite
│   │   │   └── report_service.dart   # تولید گزارش‌ها
│   │   └── utils/
│   │       └── jalali_utils.dart     # ابزارهای تاریخ شمسی
│   ├── test/                         # تست‌های خودکار
│   ├── pubspec.yaml                  # وابستگی‌ها و تنظیمات Flutter
│   ├── README.md                     # مستندات پوشه اپلیکیشن
│   ├── BUILD_INSTRUCTIONS.md         # راهنمای ساخت APK
│   └── GITHUB_ACTIONS_GUIDE.md       # راهنمای Workflow
├── LICENSE
└── README.md                         # مستندات اصلی مخزن
~~~

## مدل داده

داده‌های اصلی در دو جدول SQLite نگهداری می‌شوند.

### جدول <code>workers</code>

| ستون | نوع | توضیح |
|---|---|---|
| <code>id</code> | INTEGER PRIMARY KEY | شناسه یکتا |
| <code>name</code> | TEXT NOT NULL | نام و نام خانوادگی |
| <code>national_code</code> | TEXT UNIQUE NOT NULL | کد ملی یکتا |
| <code>phone</code> | TEXT NOT NULL | شماره تماس |
| <code>role</code> | INTEGER NOT NULL | کد سمت شغلی |
| <code>address</code> | TEXT | آدرس |
| <code>emergency_contact</code> | TEXT | نام مخاطب اضطراری |
| <code>emergency_phone</code> | TEXT | شماره تماس اضطراری |
| <code>created_at</code> | INTEGER NOT NULL | زمان ایجاد برحسب میلی‌ثانیه |
| <code>is_active</code> | INTEGER NOT NULL | وضعیت فعال (۱) یا غیرفعال (۰) |

کد سمت شغلی بر اساس ترتیب enum در مدل برنامه ذخیره می‌شود:

- <code>0</code>: تکنسین
- <code>1</code>: مهندس
- <code>2</code>: سرپرست
- <code>3</code>: کمک‌نیرو

### جدول <code>attendance_records</code>

| ستون | نوع | توضیح |
|---|---|---|
| <code>id</code> | INTEGER PRIMARY KEY | شناسه یکتا |
| <code>worker_id</code> | INTEGER NOT NULL | شناسه نیرو؛ کلید خارجی به <code>workers.id</code> |
| <code>date</code> | INTEGER NOT NULL | تاریخ رکورد برحسب Unix timestamp میلی‌ثانیه |
| <code>status</code> | INTEGER NOT NULL | کد وضعیت حضور و غیاب |
| <code>note</code> | TEXT | توضیحات |
| <code>check_in_time</code> | INTEGER | زمان ورود برحسب میلی‌ثانیه |
| <code>check_out_time</code> | INTEGER | زمان خروج برحسب میلی‌ثانیه |
| <code>location</code> | TEXT | فیلد متنی موقعیت مکانی |
| <code>created_at</code> | INTEGER NOT NULL | زمان ایجاد رکورد برحسب میلی‌ثانیه |

رابطه هر نیرو با سوابق حضور و غیاب یک‌به‌چند است. در SQLite، حذف نیرو با توجه به قید <code>ON DELETE CASCADE</code> سوابق مرتبط او را نیز حذف می‌کند. برای تاریخ و شناسه نیرو نیز ایندکس تعریف شده است تا جست‌وجوهای متداول سریع‌تر انجام شوند.

> این بخش توصیف ساختار فعلی کد است؛ تغییر در مدل‌ها یا دیتابیس باید هم‌زمان در مستندات و تست‌های مرتبط منعکس شود.

## ذخیره‌سازی و حریم خصوصی

- پایگاه داده برنامه با نام <code>attendance.db</code> در فضای اسناد اختصاصی برنامه روی دستگاه ساخته می‌شود.
- برای ثبت و مشاهده اطلاعات اصلی، به حساب کاربری یا سرور مرکزی نیاز نیست.
- اطلاعات پرسنلی مانند کد ملی، شماره تماس و اطلاعات تماس اضطراری حساس‌اند؛ دستگاه را ایمن نگه دارید و فایل‌های خروجی را فقط با افراد مجاز به اشتراک بگذارید.
- پیش از حذف برنامه، پاک‌کردن داده‌های آن یا تعویض گوشی، برای تهیه نسخه پشتیبان از اطلاعات مهم برنامه‌ریزی کنید.
- قابلیت همگام‌سازی ابری یا بازیابی خودکار اطلاعات در نسخه فعلی مستند نشده است؛ بنابراین حذف داده‌های محلی می‌تواند باعث ازدست‌رفتن اطلاعات شود.

## ساخت خودکار با GitHub Actions

Workflow موجود در [<code>.github/workflows/blank.yml</code>](.github/workflows/blank.yml) این مراحل را اجرا می‌کند:

1. دریافت کد مخزن
2. راه‌اندازی Java 17 و Flutter 3.22.2
3. دریافت وابستگی‌ها
4. اجرای <code>flutter analyze --no-pub</code>
5. اجرای تست‌ها با <code>flutter test</code>
6. ساخت APK با <code>flutter build apk --release</code>
7. بررسی وجود فایل خروجی و بارگذاری Artifact با نام <code>attendance-apk</code>

Workflow با Push به شاخه <code>main</code>، درخواست Pull Request به <code>main</code>، برچسب نسخه با الگوی <code>v*</code> و اجرای دستی قابل اجراست. برای انتشار نسخه، برچسب باید از قالب <code>vMAJOR.MINOR.PATCH</code> پیروی کند؛ برای مثال:

~~~bash
git tag v1.0.0
git push origin v1.0.0
~~~

پس از موفقیت Job ساخت، Workflow فایل APK را به GitHub Release همان برچسب اضافه می‌کند. برای مشاهده نتیجه، به [Actions](https://github.com/mzulfikari/Dart-Attendance/actions) یا [Releases](https://github.com/mzulfikari/Dart-Attendance/releases) بروید.

**نکته:** ساخت موفق APK به معنی عبور از تست روی همه مدل‌های گوشی نیست. پیش از انتشار عمومی، نصب و امکانات اصلی برنامه را روی دستگاه واقعی نیز بررسی کنید.

## آزمون و بررسی کد

از داخل پوشه <code>attendance_app</code> اجرا کنید:

~~~bash
# بررسی خطاها و هشدارهای Dart/Flutter
flutter analyze

# اجرای تست‌های خودکار
flutter test
~~~

تست‌های موجود شامل بررسی ابزارهای تبدیل و قالب‌بندی تاریخ شمسی و در دسترس بودن فونت‌های PDF در Assets هستند.

## مشارکت در پروژه

برای گزارش خطا یا پیشنهاد قابلیت:

1. ابتدا [Issues](https://github.com/mzulfikari/Dart-Attendance/issues) را بررسی کنید.
2. یک Issue با شرح روشن، مراحل بازتولید مشکل و نتیجه مورد انتظار ثبت کنید.
3. برای تغییرات کد، یک شاخه جداگانه بسازید و Pull Request ارسال کنید.
4. پیش از ارسال تغییرات، <code>flutter analyze</code> و <code>flutter test</code> را اجرا کنید.

## مجوز

این پروژه تحت مجوز [MIT](LICENSE) منتشر شده است. برای جزئیات، فایل مجوز مخزن را مطالعه کنید.
