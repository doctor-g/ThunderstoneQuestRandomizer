import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/models/database.dart';

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

  test(
      "Getting the localized name of a localized quest returns the localized name",
      () {
    Quest quest = Quest("Test Quest");
    quest.localizedNames["es"] = "Spanish Version";
    expect(quest.getLocalizedName("es"), "Spanish Version");
  });

  test(
      "Getting the localized name of a non-localized quest returns the canonical name",
      () {
    Quest quest = Quest("Test Quest");
    expect(quest.getLocalizedName("es"), "Test Quest");
  });

  test(
      "Getting the localized name of a localized card returns the localized name",
      () {
    Hero hero = makeHero(name: 'Steve', localizedNames: {"es": "Esteban"});
    expect(hero.getLocalizedName("es"), equals("Esteban"));
  });

  test(
      "Getting the localized name of a nonlocalized card returns the canonical name",
      () {
    Hero hero = makeHero(name: 'Steve');
    expect(hero.getLocalizedName("es"), equals("Steve"));
  });

  test("Get the localized memo of a localized card", () {
    Hero hero = makeHero(name: 'Steve', localizedMemos: {'es': 'Spanish'});
    expect(hero.getLocalizedMemo('es'), equals('Spanish'));
  });
}
