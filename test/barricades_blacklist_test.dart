import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/util/barricades_blacklist.dart';
import 'package:flutter_tqr/util/parser.dart';

void main() {
  late CardDatabase database;

  setUp(() async {
    // Ensure the asset can be loaded  via the rootbundle
    TestWidgetsFlutterBinding.ensureInitialized();

    // Parse the data
    ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
    String string = await rootBundle.loadString('assets/cards.yaml');
    database = parser.parse(string);
  });

  test('All barricades blacklist cards are in the cards database', () {
    var cards = Set<Card>();
    database.quests.forEach((quest) {
      quest.cards.forEach((card) {
        cards.add(card);
      });
    });
    var filteredCards =
        cards.where((card) => barricadesBlacklist.contains(card.canonicalName));
    expect(filteredCards.length == barricadesBlacklist.length, isTrue);
  });
}
