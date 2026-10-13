# مدیریت حضور و غیاب نیرو برق

اپلیکیشن اندروید برای مدیریت حضور و غیاب نیروهای برق، مخصوص استفاده سرپرستان در محل کار.

## ویژگی‌ها

- 📋 **مدیریت نیروها**: ثبت، ویرایش، جستجو و غیرفعال‌سازی نیروها
- 📅 **تقویم جلالی**: انتخاب تاریخ با تقویم شمسی کامل
- ✅ **ثبت حضور و غیاب**: 5 حالت (حاضر، غایب، دیر، مرخصی، ماموریت) با ساعت ورود/خروج
- 📊 **گزارش‌گیری**: PDF روزانه/ماهانه، Excel ماهانه، گزارش فردی کارمند
- 💾 **دیتابیس محلی**: SQLite - کاملاً آفلاین
- 🌐 **رابط کاربری فارسی**: RTL، فونت و اعداد فارسی، متریال دیزاین 3

## تکنولوژی‌ها

- **Flutter 3.x** + Dart
- **SQLite** (sqflite) برای دیتابیس محلی
- **Jalali Calendar** (`shamsi_date`) برای تقویم شمسی
- **PDF** (pdf, printing) برای گزارش PDF
- **Excel** (excel) برای خروجی اکسل
- **Share Plus** برای اشتراک‌گذاری فایل‌ها

## ساخت APK

مراحل کامل در فایل [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) آمده است.

خلاصه:
```bash
cd attendance_app
# تنظیم flutter.sdk در android/local.properties
flutter pub get
flutter build apk --release
```

خروجی: `build/app/outputs/flutter-apk/app-release.apk`

## ساختار دیتابیس

### جدول `workers`
| ستون | نوع | توضیح |
|------|-----|-------|
| id | INTEGER PK | شناسه |
| name | TEXT | نام و نام خانوادگی |
| national_code | TEXT UNIQUE | کد ملی |
| phone | TEXT | شماره تماس |
| role | INTEGER |سمت (0=تکنسین،1=مهندس،2=سرپرست،3=کمک) |
| address | TEXT | آدرس |
| emergency_contact | TEXT | نام تماس اضطراری |
| emergency_phone | TEXT | تلفن اضطراری |
| created_at | INTEGER | زمان ثبت |
| is_active | INTEGER | فعال/غیرفعال |

### جدول `attendance_records`
| ستون | نوع | توضیح |
|------|-----|-------|
| id | INTEGER PK | شناسه |
| worker_id | INTEGER FK | مرجع به workers |
| date | INTEGER | تاریخ (millis) |
| status | INTEGER | وضعیت (0=حاضر،1=غایب،2=دیر،3=مرخصی،4=ماموریت) |
| note | TEXT | توضیحات |
| check_in_time | INTEGER | ساعت ورود |
| check_out_time | INTEGER | ساعت خروج |
| location | TEXT | موقعیت مکانی |
| created_at | INTEGER | زمان ثبت |

## نصب روی گوشی

1. فایل `app-release.apk` را به گوشی منتقل کنید
2. از تنظیمات > امنیت > نصب از منابع ناشناس را فعال کنید
3. فایل APK را باز کرده و نصب کنید

## لایسنس

MIT License