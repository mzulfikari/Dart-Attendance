# نحوه استفاده از GitHub Actions برای ساخت خودکار APK

## ۱. پروژه را به GitHub push کنید

```bash
cd F:\app-to to task\attendance_app

# اگر git نصب نیست: winget install Git.Git

git init
git add .
git commit -m "Initial commit: Electrical attendance app"

# در GitHub یک repository جدید بسازید (public برای رایگان ماندن)
# بعد:
git branch -M main
git remote add origin https://github.com/USERNAME/REPO_NAME.git
git push -u origin main
```

## ۲. اولین بیلد را ببینید

1. به **GitHub Repository** بروید
2. تب **Actions** را بزنید
3. workflow "Build Android APK" در حال اجرا است
4. پس از کامل شدن (۳-۵ دقیقه):
   - **Artifacts** → `release-apks` را دانلود کنید
   - یا اگر tag زده‌اید، در **Releases** فایل APK هست

## ۳. برای هر آپدیت خودکار APK بگیرید

```bash
# تغییرات را commit و push کنید
git add .
git commit -m "توضیح تغییرات"
git push
```

هر push به `main` → APK جدید در Actions/Artifacts

## ۴. برای انتشار رسمی (Release) با نسخه

```bash
# نسخه بزنید (مثال v1.0.0)
git tag v1.0.0
git push origin v1.0.0
```

این یک **GitHub Release** با APK می‌سازد که کاربران می‌توانند از صفحه Releases دانلود کنند.

## ۵. بیلد دستی (بدون کد جدید)

در تب Actions → "Build Android APK" → **Run workflow** → Run workflow

---

## نکات مهم

| مورد | توضیح |
|------|-------|
| **محدودیت رایگان** | ۲۰۰۰ دقیقه/ماه برای public repo |
| **حجم APK** | ~۱۵-۲۵ مگابایت (split-per-abi = ۴ فایل برای معماری‌های مختلف) |
| **معماری‌ها** | arm64-v8a, armeabi-v7a, x86_64, x86 |
| **زمان بیلد** | ۳-۵ دقیقه |
| **حفظ Artifacts** | ۳۰ روز |

## عیب‌یابی

### بیلد Fail شد؟
- لاگ‌های Actions را ببینید
- مطمئن شوید `flutter_version` در workflow با پروژه совпадаت دارد
- `pubspec.yaml` dependency‌ها در pub.dev موجود باشند

### APK نصب نمی‌شود؟
- `flutter build apk --release --split-per-abi` ۴ فایل می‌سازد
- برای گوشی‌های معمول: `app-arm64-v8a-release.apk` (۶۴ بیت ARM)
- گوشی‌های قدیمی: `app-armeabi-v7a-release.apk`

### کلید امضا (Keystore) برای Release رسمی
در GitHub Repository → Settings → Secrets and variables → Actions → New repository secret:
- `KEYSTORE_BASE64`: خروجی `base64 -w0 upload-keystore.jks`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`

سپس در workflow مرحله `sign` اضافه کنید (فایل workflow کامل‌تر در صورت نیاز).