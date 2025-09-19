import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'test_util.dart';

void main() {
  group('StandardMarketplace tests', () {
    test('Initial marketplace is not full', () {
      Marketplace marketplace = StandardMarketplace();
      expect(marketplace.isFull, isFalse);
    });

    MarketplaceCard withKeyword(String keyword) {
      var cardBuilder = MarketplaceCardBuilder();
      cardBuilder.keywords = [keyword];
      cardBuilder.quest = Quest("Test");
      cardBuilder.name = "Test";
      return cardBuilder.build();
    }

    MarketplaceCard spell() => withKeyword("Spell");
    MarketplaceCard item() => withKeyword("Item");
    MarketplaceCard weapon() => withKeyword("Weapon");
    MarketplaceCard ally() => withKeyword("Ally");

    test('Full marketplace is full', () {
      StandardMarketplace marketplace = StandardMarketplace();
      for (var element in [spell(), spell()]) {
        marketplace.spells.add(element);
      }
      for (var element in [item(), item()]) {
        marketplace.items.add(element);
      }
      for (var element in [weapon(), weapon()]) {
        marketplace.weapons.add(element);
      }
      for (var element in [ally(), ally()]) {
        marketplace.anys.add(element);
      }
      expect(marketplace.isFull, isTrue);
    });

    test('Initial marketplace row is not full', () {
      MarketplaceRow row = MarketplaceRow();
      expect(row.isFull, isFalse);
    });

    test('Marketplace row with one element is not full', () {
      MarketplaceRow row = MarketplaceRow();
      row.add(makeMarketplaceCard());
      expect(row.isFull, isFalse);
    });

    test('Marketplace row with two elements is full', () {
      MarketplaceRow row = MarketplaceRow();
      row.add(makeMarketplaceCard());
      row.add(makeMarketplaceCard());
      expect(row.isFull, isTrue);
    });

    test('Marketplace with a spell in any slot will return it as a spell', () {
      StandardMarketplace marketplace = StandardMarketplace();
      marketplace.anys.add(spell());
      expect(marketplace.allSpells.length, 1);
    });
  });

  group('Solo Marketplace Tests', () {
    test('Starts empty', () {
      SoloModeMarketplace marketplace = SoloModeMarketplace();
      expect(marketplace.isFull, isFalse);
    });

    test('Is full with four cards', () {
      SoloModeMarketplace marketplace = SoloModeMarketplace();
      for (var i = 0; i < 4; i++) {
        var card = makeMarketplaceCard();
        marketplace.add(card);
      }
      expect(marketplace.isFull, isTrue);
    });
  });

  group('Tableau Tests', () {
    test('No combo without matching keyword', () {
      Tableau tableau = Tableau();
      tableau.heroes = [makeHero()];
      Monster monster = makeMonster();
      expect(tableau.hasCombo(monster), isFalse);
    });

    test('Combo with keyword on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        makeHero(keywords: ['X']),
      ];
      Monster monster = makeMonster(combo: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with combo on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        makeHero(combo: ['X']),
      ];
      Monster monster = makeMonster(keywords: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with meta on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        makeHero(meta: ['X']),
      ];
      Monster monster = makeMonster(combo: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });
  });
}
