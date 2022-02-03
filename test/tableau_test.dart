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

    MarketplaceCard _withKeyword(String keyword) {
      var cardBuilder = MarketplaceCardBuilder();
      cardBuilder.keywords = [keyword];
      cardBuilder.quest = Quest("Test");
      cardBuilder.name = "Test";
      return cardBuilder.build();
    }

    MarketplaceCard _spell() => _withKeyword("Spell");
    MarketplaceCard _item() => _withKeyword("Item");
    MarketplaceCard _weapon() => _withKeyword("Weapon");
    MarketplaceCard _ally() => _withKeyword("Ally");

    test('Full marketplace is full', () {
      StandardMarketplace marketplace = StandardMarketplace();
      [_spell(), _spell()]
          .forEach((element) => marketplace.spells.add(element));
      [_item(), _item()].forEach((element) => marketplace.items.add(element));
      [_weapon(), _weapon()]
          .forEach((element) => marketplace.weapons.add(element));
      [_ally(), _ally()].forEach((element) => marketplace.anys.add(element));
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
      marketplace.anys.add(_spell());
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
        makeHero(keywords: ['X'])
      ];
      Monster monster = makeMonster(combo: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with combo on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        makeHero(combo: ['X'])
      ];
      Monster monster = makeMonster(keywords: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with meta on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        makeHero(meta: ['X'])
      ];
      Monster monster = makeMonster(combo: ['X']);
      expect(tableau.hasCombo(monster), isTrue);
    });
  });
}
