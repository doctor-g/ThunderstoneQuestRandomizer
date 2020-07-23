import 'database.dart';

class Tableau {
  List<Hero> heroes;
  Marketplace marketplace;
  Guardian guardian;
  Dungeon dungeon;
  List<Monster> monsters; // in order of level
}

class Marketplace {
  final MarketplaceRow<Spell> spells = MarketplaceRow();
  final MarketplaceRow<Item> items = MarketplaceRow();
  final MarketplaceRow<Weapon> weapons = MarketplaceRow();
  final AnyMarketplaceRow anys = AnyMarketplaceRow();

  List<Card> get cards =>
      anys.cards + spells.cards + items.cards + weapons.cards;

  bool contains(Card card) => cards.contains(card);

  bool get isFull =>
      spells.isFull && items.isFull && weapons.isFull && anys.isFull;

  List<Spell> get allSpells =>
      spells.cards + List<Spell>.of(anys.cards.whereType<Spell>());
  List<Item> get allItems =>
      items.cards + List<Item>.of(anys.cards.whereType<Item>());
  List<Weapon> get allWeapons =>
      weapons.cards + List<Weapon>.of(anys.cards.whereType<Weapon>());
  List<Card> get allAllies =>
      anys.cards.where((card) => card.runtimeType == Ally).toList();
}

class MarketplaceRow<T extends Card> {
  List<T> _slots = List();

  void add(T card) {
    assert(!isFull);
    _slots.add(card);
  }

  bool get isFull => _slots.length == 2;

  List<T> get cards => List.of(_slots);
}

// The special case of the "Any" row
class AnyMarketplaceRow<Card> extends MarketplaceRow {
  // As long as there
  bool canTake(Card card) {
    if (isFull) return false;
    if (_slots.length == 1 && _slots[0].runtimeType == card.runtimeType)
      return false;
    else
      return true;
  }
}

class Dungeon {
  // Map level to the pair of rooms
  Map<int, List<Room>> roomsMap = {1: List(), 2: List(), 3: List()};
}
