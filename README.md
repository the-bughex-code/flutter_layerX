# LayerX Generator

Bootstrap a **production-ready Flutter architecture** in seconds.

`layerx_generator` scaffolds a clean, opinionated `lib/app/` structure — MVVM +
GetX, a resilient networking layer, reusable services, a polished design system
and a working Splash → Login → Home demo — and installs every dependency it
needs. A freshly enabled project passes `flutter pub get`, `flutter analyze` and
`flutter test` with **zero errors or warnings**, out of the box.

---

## Highlights

- **One command setup** — `layerx enable` installs dependencies and generates
  everything. No manual fixes, no missing packages, no analyzer errors.
- **Automatic dependencies** — GetX, ScreenUtil, `flutter_animate`, Google
  Fonts, `logger`, `intl`, `http`, `shared_preferences`, `permission_handler`
  and the notification/location stack are added at their latest compatible
  versions.
- **MVVM + GetX** — views, controllers, models and repositories, with routing
  and dependency injection wired in.
- **Design system** — `AppButton`, `AppTextField`, extension snackbars, haptics,
  animation wrappers and a responsive `AppTextStyles` typography scale.
- **Polished demo** — Splash → Login → Home, with a constructor-injected
  `AuthRepository` you can wire to a real backend.
- **Modern logger console** — colored, emoji-tagged logs with request/response,
  JSON and execution-time helpers.

---

## Installation

Activate the CLI once:

```sh
dart pub global activate layerx_generator
```

Then, from your Flutter project root:

```sh
layerx enable
```

That installs all required dependencies and generates the LayerX structure.
Run your app:

```sh
flutter run
```

> Prefer not to install globally? The classic invocation still works:
> `dart run layerx_generator --path .`

### Options

```sh
layerx enable --path .     # target a specific project directory
layerx enable --no-deps    # generate files without installing dependencies
```

---

## Programmatic usage

```dart
import 'package:layerx_generator/layerx_generator.dart';
import 'dart:io';

Future<void> main() async {
  final generator = LayerXGenerator(Directory.current.path);
  await generator.generate();
}
```

---

## What you get

```text
lib/app/
├── app_widget.dart              # ScreenUtil + GetMaterialApp
├── config/                      # colors, strings, routes, text styles, urls, utils
├── mvvm/
│   ├── model/                   # api_response, login_request/response models
│   ├── view/                    # splash, login, home
│   └── view_model/              # splash, login, home controllers
├── repository/
│   ├── auth_repository.dart
│   ├── apis/                    # data_repository.dart
│   ├── firebase/
│   └── localdb/
├── services/                    # logger, haptics, prefs, http, json, location
│   └── notifications/           # FCM + local notifications
├── custom_widgets/
│   ├── buttons/                 # AppButton
│   ├── inputs/                  # AppTextField
│   ├── snackbars/               # 'msg'.showSuccess()
│   ├── animations/              # FadeSlideIn, SpringIn, …
│   └── dialogs/                 # NoInternetDialog
└── ...
```

`main.dart` is updated to boot the app and `test/widget_test.dart` is regenerated
for the new entry point.

---

## Design system at a glance

```dart
// Buttons
AppButton(label: 'Sign In', onPressed: controller.login, isLoading: true);

// Inputs
AppTextField(label: 'Email', isRequired: true, validator: controller.validateEmail);

// Snackbars (extension on String)
'Login successful'.showSuccess();
'Please try again'.showError();

// Haptics
HapticService.success();

// Typography — never write a raw TextStyle in a view
Text('Welcome', style: AppTextStyles.displayLarge);

// Animations
FadeSlideIn(child: myWidget);
```

---

## Routing

Routes and inline bindings live in `config/app_routes.dart` — no separate binding
files:

```dart
GetPage(
  name: AppRoutes.loginView,
  page: () => const LoginView(),
  binding: BindingsBuilder(() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<LoginController>(() => LoginController(Get.find<AuthRepository>()));
  }),
);
```

---

## Verified error-free

Every generated project is validated to pass:

```sh
flutter pub get
flutter analyze   # No issues found!
flutter test      # All tests passed!
```

---

## Example

A complete working example lives in the [`example/`](example) directory.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

Issues and pull requests are welcome at
[the-bughex-code/flutter_layerX](https://github.com/the-bughex-code/flutter_layerX).
