# SSST Mobile — Smart Student Success Tracker

Native Flutter application for **Android** and **iOS**. It is a client of the existing Flask REST API and SQLite/MySQL database. It is not a WebView wrapper.

## Requirements

- Flutter 3.24+ / Dart 3.13+
- Android Studio (Android SDK) or Xcode (iOS)
- Running SSST Flask backend (`backend/`)

## 1. Start the backend

From the repository root (`d:\SSST`):

```bash
python -m pip install -r backend/requirements.txt
python -m backend.seed
python -m backend.app
```

The API listens on `0.0.0.0:5000` so emulators and phones on the same Wi-Fi can connect.

Optional: configure SMTP in `backend/.env` (`MAIL_USERNAME`, `MAIL_PASSWORD`) so forgot-password OTPs are emailed. If SMTP is empty, the OTP is printed in the Flask console for local testing.

## 2. Configure the API URL

Default:

| Device | Base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:5000/api` |
| iOS simulator | `http://127.0.0.1:5000/api` |
| Physical phone | `http://YOUR_PC_LAN_IP:5000/api` |

Ways to set it:

1. **In the app:** Settings → Server Connection (saved on the device).
2. **Compile-time:**  
   `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/api`
3. Phone and PC must be on the same Wi-Fi. `localhost` on the phone is the phone itself, not your computer.

Find your PC IP (Windows): `ipconfig` → IPv4 address.

## 3. Run the app

```bash
cd mobile
flutter pub get
flutter run
```

Open in Android Studio: **File → Open** the `mobile/` folder (not the repo root unless you use a Flutter module).

Build a debug APK:

```bash
cd mobile
flutter build apk --debug
```

Release APK (after signing is configured):

```bash
flutter build apk --release
```

iOS:

```bash
cd mobile
flutter create . --platforms=ios
flutter run -d ios
```

## 4. Login and roles

Public self-registration is disabled. **Administrators create Student IDs / Teacher emails and passwords.**

| Role | Login identifier |
| --- | --- |
| Student | Student ID issued by admin |
| Teacher | Registered email |
| Admin | Registered email |

Forgot password: Login → Forgot password → OTP is sent to the **registered email**. Enter OTP → set a new password.

After a local seed (`python -m backend.seed`), the bootstrap admin account is created only for first-time setup. Do not put those credentials on the login screen. Change the admin password after first login.

## 5. What each role can do

**Student:** dashboard, performance, planner, quiz, assignments, notes, prediction, parent report (share), AI chat, notifications, settings.

**Teacher:** class dashboard, student roster, alerts, settings.

**Admin:** dashboard, create/search students and faculty (ID + password), subjects, settings.

## 6. Troubleshooting

- **Cannot reach server:** backend not running, wrong URL, or Flask bound only to localhost. Use `0.0.0.0:5000`.
- **Cleartext HTTP blocked:** Android already allows cleartext for development (`usesCleartextTraffic`). iOS needs `NSAllowsArbitraryLoads` for local HTTP.
- **401 after login:** token expired; log in again.
- **OTP not in inbox:** check Flask console if SMTP is not configured.
