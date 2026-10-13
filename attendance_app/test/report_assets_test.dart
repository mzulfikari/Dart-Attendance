import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Persian PDF fonts are bundled as app assets', () async {
    final regularFont = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldFont = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');

    expect(regularFont.lengthInBytes, greaterThan(100000));
    expect(boldFont.lengthInBytes, greaterThan(100000));
  });
}
