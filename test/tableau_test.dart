import 'package:flutter_tqr/domain_model.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:test/test.dart';

void main() {
  group('Tableau tests', () {
    test('Initial marketplace is not full', () {
      Marketplace marketplace = new Marketplace();
      expect(marketplace.isFull, isFalse);
    });

    test('Full marketplace is full', () {
      Marketplace marketplace = new Marketplace();
      [Spell(), Spell()].forEach((element) => marketplace.spells.add(element));
      [Item(), Item()].forEach((element) => marketplace.items.add(element));
      [Weapon(), Weapon()]
          .forEach((element) => marketplace.weapons.add(element));
      [Ally(), Ally()].forEach((element) => marketplace.anys.add(element));
      expect(marketplace.isFull, isTrue);
    });

    test('Initial marketplace row is not full', () {
      MarketplaceRow row = MarketplaceRow();
      expect(row.isFull, isFalse);
    });

    test('Marketplace row with one element is not full', () {
      MarketplaceRow row = MarketplaceRow();
      row.add(Card());
      expect(row.isFull, isFalse);
    });

    test('Marketplace row with two elements is full', () {
      MarketplaceRow row = MarketplaceRow();
      row.add(Card());
      row.add(Card());
      expect(row.isFull, isTrue);
    });

    test('Marketplace with a spell in any slot will return it as a spell', () {
      Marketplace marketplace = Marketplace();
      marketplace.anys.add(Spell());
      expect(marketplace.allSpells.length, 1);
    });
  });
}
