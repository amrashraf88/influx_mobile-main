# تشغيل التطبيق وربط الـ APIs / Running & API wiring

## الخلاصة (Summary)
- الـ API الافتراضي متظبط على الـ **Production**: `https://adzmavall.com` (نسخة `v1`).
- التطبيق بيكلّم الـ mobile REST API على المسار `/api/v1/...` (راجع `lib/core/config/api_endpoints.dart`).
- لما الـ base URL متظبط (وهو كده افتراضيًا)، كل feature بيستخدم الـ API الحقيقي. لو الـ base URL فاضي بيرجع لبيانات احتياطية/mock.
- مفيش حاجة لازم تتغير عشان يشتغل على الـ production — كفاية تعمل Run.

## التشغيل (How to run)

### الافتراضي = Production
```bash
flutter pub get
flutter run            # يكلّم https://adzmavall.com تلقائيًا
```

### تحديد البيئة صراحةً (explicit)
```bash
# Production
flutter run --dart-define=API_BASE_URL=https://adzmavall.com --dart-define=API_VERSION=v1

# Test / staging
flutter run --dart-define=API_BASE_URL=https://test.api.adzmavall.com --dart-define=API_VERSION=v1
```

### Release build (production)
```bash
flutter build apk   --dart-define=API_BASE_URL=https://adzmavall.com
flutter build ipa   --dart-define=API_BASE_URL=https://adzmavall.com
```

## من الـ IDE
- **Android Studio / IntelliJ:** فيه run configs جاهزة من القايمة فوق: `adzmavall (Production)` و `adzmavall (Test)`.
- **VS Code:** افتح Run and Debug واختار `adzmavall — Production` أو `Test` (متعرّفين في `.vscode/launch.json`).

> ملاحظة: مجلدات `.idea/` و `.vscode/launch.json` معمولها ignore في git (إعدادات محلية)، فمش هتتزامن مع باقي الفريق — لكنها تشتغل على جهازك عادي.

## تأكيد إن الـ API شغّال (health check)
```bash
curl https://adzmavall.com/api/v1/health      # -> {"status":"ok"}
curl https://adzmavall.com/api/v1/home/welcome # -> {"data":{...}}
```

## ملاحظة عن الـ Postman collection
ملف `Adzmavall-Production.postman_collection.json` هو الـ **legacy web app** (مسارات صفحات/جلسات على `adzmavall.com`)، مش الموبايل API.
الموبايل API الفعلي هو مسارات `/api/v1/...` المعرّفة في `lib/core/config/api_endpoints.dart` (مجموعة "Influx").
