import 'database.dart';

abstract class ComboFinder {
  bool hasCombo(Card card);
}

class Tableau implements ComboFinder {
  List<Hero> heroes;
  Marketplace marketplace;
  Guardian guardian;
  Dungeon dungeon;
  List<Monster> monsters; // in order of level

  // Get the set of all cards currently in play
  Set<Card> get allCards {
    Set<Card> result = Set();
    if (heroes != null) result.addAll(heroes);
    if (marketplace != null) result.addAll(marketplace.cards);
    if (guardian != null) result.add(guardian);
    if (dungeon != null) result.addAll(dungeon.cards);
    if (monsters != null) result.addAll(monsters);
    return result;
  }

  // Get all the keywords of cards currently in play
  Set<String> get _keywords {
    Set<String> result = Set();
    allCards.forEach((card) => result.addAll(card.keywords));
    return result;
  }

  // Get all the combos of the cards currently in play
  Set<String> get _combos {
    Set<String> result = Set();
    allCards.forEach((card) => result.addAll(card.combo));
    return result;
  }

  // Get all the meta on all the cards in play
  Set<String> get _meta {
    Set<String> result = Set();
    allCards.forEach((card) => result.addAll(card.meta));
    return result;
  }

  // Given a card, see if it comboes with anything currently on the tableau.
  bool hasCombo(Card card) {
    // First, check if any of the tableau's combo words
    // match keywords or meta on the card.
    Set<String> comboSet = _combos;
    for (var keyword in List.of(card.keywords)..addAll(card.meta)) {
      if (comboSet.contains(keyword)) {
        return true;
      }
    }

    // Then, check if any of the card's combo words
    // match keywords on the tableau.
    Set<String> keywordSet = _keywords;
    for (var combo in card.combo) {
      if (keywordSet.contains(combo)) {
        return true;
      }
    }

    // Finally, check if any of the card's combo words
    // match the meta on the tableau
    Set<String> metaSet = _meta;
    for (var combo in card.combo) {
      if (metaSet.contains(combo)) {
        return true;
      }
    }

    // Otherwise, no combos were found.
    return false;
  }
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

  List<Card> get cards => List.of(roomsMap[1] + roomsMap[2] + roomsMap[3]);
}
