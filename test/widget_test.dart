
import 'package:flutter_test/flutter_test.dart';
import 'package:app_modular/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('El tema principal utiliza Material 3', () {
    expect(AppTheme.appTheme.useMaterial3, isTrue);
  });
}
