# Changelog

All notable changes to the `layerx_generator` Flutter package are documented in this file.  
This project follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [2.1.0] – 2026-07-03

A major production-hardening release. A freshly enabled project now passes
`flutter pub get`, `flutter analyze` and `flutter test` with **zero** errors or
warnings, out of the box.

### Added
- **`layerx enable` command** — installs every required dependency via
  `flutter pub add` (latest compatible versions) and generates the structure in
  one step. The legacy `dart run layerx_generator --path .` still works.
- **Automatic dependency installation** — GetX, ScreenUtil, `flutter_animate`,
  Google Fonts, `logger`, `intl`, `http`, `shared_preferences`,
  `permission_handler`, notification & location packages are all added and
  resolved automatically (with a graceful fallback when Flutter isn't on `PATH`).
- **Design system** under `custom_widgets/`: `AppButton` (press animation,
  gradient, icons, loading, haptics), `AppTextField` (validation, label,
  required marker, prefix/suffix, focus & error styling, shadow), extension-based
  snackbars (`'msg'.showSuccess()`), and animation wrappers (`FadeSlideIn`,
  `SpringIn`, `PressableScale`, `FloatingEffect`, `StaggeredColumn`).
- **`AppTextStyles`** premium typography (Inter/Rubik/Sarabun via Google Fonts,
  SF Pro on Apple platforms).
- **`HapticService`** — centralized light/medium/heavy/selection/success/error.
- **Polished demo** — Splash → Login → Home, with repository-injected
  controllers and `LoginRequestModel` / `LoginResponseModel`.
- **Modern logger console** — colored, emoji-tagged output with
  request/response/JSON/divider helpers and execution timing.
- **Native permission patching** — `layerx enable` injects only the Android
  (`AndroidManifest.xml`) and iOS (`Info.plist`) entries the generated
  notification/location features actually use, each justified inline and safe
  to prune. Idempotent.

### Changed
- Routing now declares bindings inline via `BindingsBuilder` — no separate
  binding files.
- Repository layout refined to `repository/{apis,firebase,localdb}` plus a
  top-level `auth_repository.dart`.
- Controllers consume repositories through their constructors.
- `analysis_options.yaml` now excludes `build/**` so SPM-resolved plugins don't
  pollute `flutter analyze`.

### Fixed
- Dependencies are actually resolved (previously written to `pubspec.yaml` but
  never fetched), plus the previously-missing `firebase_messaging`, `geolocator`
  and `googleapis_auth`.
- API drift against current package versions (`flutter_timezone` `TimezoneInfo`,
  `flutter_local_notifications` scheduling, `geolocator` `LocationSettings`).
- Generated `test/widget_test.dart` no longer references the removed `MyApp`.
- Removed stale placeholder repositories and the unused `AppTheme`.

### Removed
- `AppTheme` is no longer generated (styling is kept lightweight).

---
## [2.0.2] – 2025-08-24

- Added **Notification Services module** under `services/notifications`.
- Firebase Cloud Messaging (FCM) permission handling with proper authorization states.
- Local notification support using `flutter_local_notifications`.
- Foreground, background, and notification-tap handling hooks.
- Timezone-aware scheduled notifications using `timezone` + `flutter_timezone`.
- Device token retrieval utility for backend registration.
- Secure server key helper for FCM HTTP v1 (OAuth access token based).
- Generator now produces **notification-ready infrastructure** without forcing Firebase
  initialization, keeping projects compile-safe by default.

---


## [2.0.1] - 2025-06-03
### Added

- Connection pooling with HTTP/2 multiplexing, TLS resumption, and gzip/deflate for faster handshakes and reduced CPU/RAM usage.
- Concurrency limiter using token-bucket and isolates for JSON parsing, with adaptive concurrency to device cores to prevent socket exhaustion and maintain UI at 60FPS.
- Multi-thread offloading for heavy JSON/XML parsing, compression, and encryption in isolates for smoother main thread and no frame drops.
- Smarter retries with exponential backoff and jitter, tuned for flaky networks to improve recovery and user experience.
- CancelToken for each request, enabling socket abort to save sockets, avoid leaks, and support instant cancellation.
- Timeout control with per-call and global deadlines, auto-closing sockets to prevent hangs and ensure the app never freezes.
- Request deduplication with in-flight cache keyed by URL and params to remove duplicate API hits and save bandwidth.
- Multipart uploads using streams with chunked encoding in background isolate for faster uploads and lower memory usage.
- Centralized headers to auto-attach JWT, device info, and tracing headers for consistent authentication across endpoints.
- Categorized error domains (Timeout, Network, Server, Cancel) with structured logging for improved error handling.
- TLS optimization enforcing modern ciphers and enabling HTTP/2 by default for stronger security and faster requests.
- Adaptive caching supporting ETag, Last-Modified, conditional requests, and in-memory/disk cache for bandwidth savings and instant reloads.
- Monitoring hooks with built-in interceptors for latency, retries, payload size, and socket reuse for easy profiling and SLA tracking.



## [2.0.0] - 2025-05-27

### Added
- New modular architecture for enhanced customization of generated structures.
- Support for generating unit test templates for services and repositories.
- Added `ThemeGenerator` for customizable theme configurations.

### Changed
- **Breaking**: Refactored core generator logic to support plugin-based extensions, requiring updates to existing usage.
- Upgraded dependencies to latest versions for improved performance and compatibility:
    - `get: ^4.6.6`
    - `flutter_screenutil: ^5.9.0`
    - `http: ^1.1.0`
    - `logger: ^2.0.0`
- Improved error reporting with detailed diagnostics in `LoggerService`.

### Removed
- Deprecated `directory_generator` logic in favor of new modular approach.

---

## [1.1.12] - 2025-05-27

### Changed
- Removed automatic `pubspec.yaml` modification to prevent overwriting project configurations.
- Users must now manually add required dependencies to `pubspec.yaml`.

---

## [1.1.6] - 2025-04-29

### Added
- `LocationService` for user location retrieval using `geolocator` and `permission_handler`.
- `ApiResponseHandler` for unified API response processing with `GetX` support.
- `LoggerService` for consistent and clean log management across all services.
- New body models:
    - `DriverSignupBodyModel`
    - `GarageSignupBodyModel`
    - `AddCarBodyModel`
    - `BuyCarRequestModel`
- Generic `ApiResponse<T>` model for flexible and type-safe API data handling.

### Changed
- Enhanced `HttpsCalls` for advanced `MultipartRequest` handling across:
    - Driver/Garage profile uploads
    - Car create/update/delete operations
    - Car buying requests
- Standardized repository implementation via `AuthRepository` and `DataRepository` using `ApiResponseHandler`.
- Renamed `ApiUrls` to `AppUrls` for naming consistency.
- Upgraded dependencies:
    - `geolocator: ^10.0.0`
    - `permission_handler: ^10.0.0`
- Improved generator logic with better documentation and scalability.

---

## [1.0.4] - 2025-03-15

### Changed
- Optimized retry logic in `HttpsCalls` for improved performance.
- Enhanced error handling in `SharedPreferencesService`.
- Improved documentation clarity with practical usage examples.
- Minor fixes in `directory_generator` logic.

---

## [1.0.3] - 2025-02-20

### Added
- Support for custom widget generation in the `widgets/` directory.
- Basic unit tests for `HttpsCalls` and `SharedPreferencesService`.

### Changed
- Enhanced `MessageExtractor` for robust JSON message parsing.
- Updated `pubspec.yaml` with stricter dependency constraints.

---

## [1.0.2] - 2025-01-10

### Fixed
- Path handling issues on Windows during directory generation.
- Resolved null-safety warnings in generated code.

### Changed
- Enriched `README.md` with detailed setup and usage instructions.
- Updated `flutter_screenutil` to `^5.0.0`.

---

## [1.0.1] - 2024-12-01

### Added
- `MessageExtractor` for parsing API response messages.
- Initial repository generation example: `example_repo.dart`.

### Fixed
- Minor bug in `AppRoutes` configuration generation.

---

## [1.0.0] - 2024-11-15

### Added
- Stable release: Full MVVM-based directory structure generator for Flutter.
- `HttpsCalls` for handling API requests with retry and timeout support.
- `SharedPreferencesService` for local storage handling.
- Integrated `GetX` for navigation and state management.
- `flutter_screenutil` for adaptive screen responsiveness.
- Core configuration files: `AppColors`, `AppRoutes`, `AppUrls`, etc.

### Changed
- Refactored generator logic for improved modularity and code reuse.
- Enhanced error handling during directory and file creation.

---

## [0.0.3] - 2024-10-20

### Added
- Basic configuration files: `app_colors.dart`, `app_routes.dart`.
- Support for generating `AppWidget` and `main.dart`.

### Fixed
- Cross-platform directory path resolution issues.

---

## [0.0.2] - 2024-10-05

### Added
- Initial `pubspec.yaml` generator with essential Flutter dependencies.
- Basic `README.md` with setup guidance.

### Fixed
- Resolved recursion issues during nested directory generation.

---

## [0.0.1] - 2024-09-15

### Added
- Initial release.
- Base MVVM directory structure under `lib/app/`.
- Generator support for `config/`, `mvvm/`, and `services/` folders.