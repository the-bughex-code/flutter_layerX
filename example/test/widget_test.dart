import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:example/app/app_widget.dart';
import 'package:example/app/mvvm/view/login/login_view.dart';
import 'package:example/app/mvvm/view/splash/splash_view.dart';

void main() {
  // Avoid network font fetches during tests.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('LayerXApp boots to splash then routes to login', (tester) async {
    await tester.pumpWidget(const LayerXApp());
    await tester.pump();
    expect(find.byType(SplashView), findsOneWidget);

    // Fire the splash delay, then let the login screen settle in.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });
}
