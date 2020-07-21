import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/domain_model.dart';
import 'package:flutter_tqr/parser.dart';

void main() {
  CardDatabase database;

  setUp(() async {
    // Ensure the asset can be loaded  via the rootbundle
    TestWidgetsFlutterBinding.ensureInitialized();

    // Parse the data
    ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
    String string = await rootBundle.loadString('assets/cards.yaml');
    database = parser.parse(string);
  });

  test('Cards asset is parseable', () {
    expect(database, isNotNull);
  });
}
