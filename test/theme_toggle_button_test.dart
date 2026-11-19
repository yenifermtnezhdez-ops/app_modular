import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_modular/app/theme_toggle_button.dart';
import 'package:app_modular/modules/news/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el botón alterna el tema y persiste la selección', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = AppProvider();
    await themeProvider.loadTheme();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: themeProvider,
        child: Consumer<AppProvider>(
          builder: (context, provider, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: provider.themeMode,
            home: Scaffold(
              appBar: AppBar(actions: [const ThemeToggleButton()]),
              body: Builder(
                builder: (context) => Text(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'Tema oscuro'
                      : 'Tema claro',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(find.text('Tema claro'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(themeProvider.themeMode, ThemeMode.dark);
    expect(find.text('Tema oscuro'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_theme_mode'), 'dark');

    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(find.text('Tema claro'), findsOneWidget);
    expect(themeProvider.themeMode, ThemeMode.light);
    expect(preferences.getString('app_theme_mode'), 'light');

    themeProvider.dispose();
  });
}
