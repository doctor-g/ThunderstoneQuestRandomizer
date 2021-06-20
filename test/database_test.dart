import 'package:flutter_tqr/models/database.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() {
  test("Filter removes hero cards", () {
    const heroName = "Test Guy";
    Quest quest = Quest("Test Quest");
    quest.add(makeHero(name: heroName));
    CardDatabase database = CardDatabase([quest]);
    database = database.where((card) => card.name != heroName);
    expect(database.quests[0].heroes, isEmpty);
  });

  test("Filter removes item cards", () {
    const itemName = "Test Item";
    Quest quest = Quest("Test Quest");
    quest.add(makeMarketplaceCard(name: itemName, keywords: ["Item"]));
    CardDatabase database = CardDatabase([quest]);
    database = database.where((card) => card.name != itemName);
    expect(database.quests[0].items, isEmpty);
  });
}
