# Usta Admin Panel

A Flutter admin dashboard for managing Usta platform workflows, analytics, operational data, and API-backed admin screens.

## Status

Public pinned candidate.

## Key Features

- Admin dashboard UI foundation
- GetX state management and local storage
- Dio API communication
- Connectivity-aware app flow
- File picker support for uploads/import workflows
- Charts and analytics with fl_chart
- Arabic/RTL-ready localization support
- Cairo font and custom icon font setup

## Tech Stack

- Flutter
- Dart
- GetX
- Dio
- Get Storage
- Connectivity Plus
- File Picker
- fl_chart
- Intl / Flutter Localizations

## Getting Started

```bash
git clone https://github.com/yousefm2311/usta_admin_panal.git
cd usta_admin_panal
flutter pub get
flutter run
```

## Environment Variables

Create local configuration only when connecting to backend services.

```env
API_BASE_URL=
AUTH_TOKEN=
```

Never commit real admin credentials, auth tokens, API keys, or production secrets.

## Screenshots

Add dashboard, charts, users, services, and admin workflow screenshots before pinning publicly.

```md
![Admin dashboard](docs/screenshots/dashboard.png)
```

## Roadmap

- Add screenshots and demo flow
- Document API modules
- Add authentication notes
- Add build/release instructions

## Author

Yousef Mohamed

- GitHub: https://github.com/yousefm2311
