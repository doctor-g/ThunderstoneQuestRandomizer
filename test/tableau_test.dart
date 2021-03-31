import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:test/test.dart';

void main() {
  group('Marketplace tests', () {
    test('Initial marketplace is not full', () {
      Marketplace marketplace = new Marketplace();
      expect(marketplace.isFull, isFalse);
    });

    MarketplaceCard _withKeyword(String keyword) {
      var card = MarketplaceCard();
      card.keywords = [keyword];
      return card;
    }

    MarketplaceCard _spell() => _withKeyword("Spell");
    MarketplaceCard _item() => _withKeyword("Item");
    MarketplaceCard _weapon() => _withKeyword("Weapon");
    MarketplaceCard _ally() => _withKeyword("Ally");

    test('Full marketplace is full', () {
      Marketplace marketplace = new Marketplace();
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
      row.add(MarketplaceCard());
      expect(row.isFull, isFalse);
    });

    test('Marketplace row with two elements is full', () {
      MarketplaceRow row = MarketplaceRow();
      row.add(MarketplaceCard());
      row.add(MarketplaceCard());
      expect(row.isFull, isTrue);
    });

    test('Marketplace with a spell in any slot will return it as a spell', () {
      Marketplace marketplace = Marketplace();
      marketplace.anys.add(_spell());
      expect(marketplace.allSpells.length, 1);
    });
  });

  group('Tableau Tests', () {
    test('No combo without matching keyword', () {
      Tableau tableau = Tableau();
      tableau.heroes = [Hero()];
      Monster monster = Monster();
      expect(tableau.hasCombo(monster), isFalse);
    });

    test('Combo with keyword on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        Hero()..keywords = ['X']
      ];
      Monster monster = Monster()..combo = ['X'].toSet();
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with combo on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        Hero()..combo = ['X'].toSet()
      ];
      Monster monster = Monster()..keywords = ['X'];
      expect(tableau.hasCombo(monster), isTrue);
    });

    test('Combo with meta on tableau', () {
      Tableau tableau = Tableau();
      tableau.heroes = [
        Hero()..meta = ['X'].toSet()
      ];
      Monster monster = Monster()..combo = ['X'].toSet();
      expect(tableau.hasCombo(monster), isTrue);
    });
  });
}
