import 'dart:collection';

import 'database.dart';

abstract class ComboFinder {
  bool hasCombo(Card card);
}

enum GameMode { solo, barricades, smallTableau }

class Tableau implements ComboFinder {
  String? wildernessMonster;
  List<Hero>? heroes;
  Marketplace? marketplace;
  Guardian? guardian;
  Dungeon? dungeon;
  List<Monster>? monsters; // in order of level

  // Tracks whether this tableau was created in barricades mode.
  // This is needed to show in the UI a hint about this, independently of
  // the current state of the settings model.
  Set<GameMode> modes = {};

  // Get the set of all cards currently in play
  Set<Card> get allCards {
    Set<Card> result = {};
    if (heroes != null) result.addAll(heroes!);
    if (marketplace != null) result.addAll(marketplace!.cards);
    if (guardian != null) result.add(guardian!);
    if (dungeon != null) result.addAll(dungeon!.cards);
    if (monsters != null) result.addAll(monsters!);
    return result;
  }

  // Get all the keywords of cards currently in play
  Set<String> get _keywords {
    Set<String> result = {};
    for (var card in allCards) {
      result.addAll(card.keywords);
    }
    return result;
  }

  // Get all the combos of the cards currently in play
  Set<String> get _combos {
    Set<String> result = {};
    for (var card in allCards) {
      result.addAll(card.combo);
    }
    return result;
  }

  // Get all the meta on all the cards in play
  Set<String> get _meta {
    Set<String> result = {};
    for (var card in allCards) {
      result.addAll(card.meta);
    }
    return result;
  }

  // Given a card, see if it comboes with anything currently on the tableau.
  @override
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

abstract class Marketplace {
  List<MarketplaceCard> get cards;

  bool contains(Card card) => cards.contains(card);

  bool get isFull;

  List<MarketplaceCard> get allSpells;
  List<MarketplaceCard> get allItems;
  List<MarketplaceCard> get allWeapons;
  List<MarketplaceCard> get allAllies;
}

/// Marketplace for use in Barricades Solo mode.
///
/// In this mode, the marketplace contains four cards of arbitrary type.
class SoloModeMarketplace extends Marketplace {
  final List<MarketplaceCard> _cards = [];

  @override
  List<MarketplaceCard> get cards => UnmodifiableListView(_cards);

  @override
  bool get isFull => cards.length == 4;

  void add(MarketplaceCard card) {
    _cards.add(card);
  }

  @override
  List<MarketplaceCard> get allAllies =>
      cards.where((card) => card.keywords.contains("Ally")).toList();

  @override
  List<MarketplaceCard> get allItems =>
      cards.where((card) => card.keywords.contains("Item")).toList();

  @override
  List<MarketplaceCard> get allSpells =>
      cards.where((card) => card.keywords.contains("Spell")).toList();

  @override
  List<MarketplaceCard> get allWeapons =>
      cards.where((card) => card.keywords.contains("Weapon")).toList();
}

/// Standard marketplace
///
/// This marketplace is full when all its rows are full.
class StandardMarketplace extends Marketplace {
  final MarketplaceRow spells = MarketplaceRow();
  final MarketplaceRow items = MarketplaceRow();
  final MarketplaceRow weapons = MarketplaceRow();
  final AnyMarketplaceRow anys = AnyMarketplaceRow();

  @override
  bool get isFull =>
      spells.isFull && items.isFull && weapons.isFull && anys.isFull;

  @override
  List<MarketplaceCard> get cards =>
      anys.cards + spells.cards + items.cards + weapons.cards;

  @override
  List<MarketplaceCard> get allSpells =>
      spells.cards +
      anys.cards.where((card) => card.keywords.contains("Spell")).toList();
  @override
  List<MarketplaceCard> get allItems =>
      items.cards +
      anys.cards.where((card) => card.keywords.contains("Item")).toList();
  @override
  List<MarketplaceCard> get allWeapons =>
      weapons.cards +
      anys.cards.where((card) => card.keywords.contains("Weapon")).toList();
  @override
  List<MarketplaceCard> get allAllies =>
      anys.cards.where((card) => card.keywords.contains("Ally")).toList();
}

class MarketplaceRow {
  final List<MarketplaceCard> _slots = [];

  void add(MarketplaceCard card) {
    assert(!isFull);
    _slots.add(card);
  }

  bool get isFull => _slots.length == 2;

  List<MarketplaceCard> get cards => List.of(_slots);
}

// The special case of the "Any" row
class AnyMarketplaceRow extends MarketplaceRow {
  // As long as there
  bool canTake(Card card) {
    if (isFull) return false;
    if (_slots.length == 1 &&
        !_haveDifferentTypes(_slots[0], card as MarketplaceCard)) {
      return false;
    } else {
      return true;
    }
  }

  bool _haveDifferentTypes(MarketplaceCard card1, MarketplaceCard card2) {
    const List<String> types = ["Spell", "Item", "Ally", "Weapon"];
    Set<String> card1Types = Set.of(
      card1.keywords.where((keyword) => types.contains(keyword)),
    );
    Set<String> card2Types = Set.of(
      card2.keywords.where((keyword) => types.contains(keyword)),
    );
    // There are different types if the difference is nonempty.
    return (card1Types.difference(card2Types)).isNotEmpty;
  }
}

class Dungeon {
  // Map level to the pair of rooms
  Map<int, List<Room>> roomsMap = {1: [], 2: [], 3: []};

  List<Card> get cards => List.of(roomsMap[1]! + roomsMap[2]! + roomsMap[3]!);
}
