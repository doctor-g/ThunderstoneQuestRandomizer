import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/parser.dart';

void main() {
  setUp(() {
    // Ensure the asset can be loaded  via the rootbundle
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('Cards asset is parseable', () async {
    ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
    String string = await rootBundle.loadString('assets/cards.yaml');
    var result = parser.parse(string);
    expect(result, isNotNull);
  });
}
