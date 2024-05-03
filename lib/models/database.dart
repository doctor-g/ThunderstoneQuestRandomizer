import 'package:flutter/foundation.dart';

class CardDatabaseModel extends ChangeNotifier {
  CardDatabase? _database;

  CardDatabase? get database => _database;

  set database(CardDatabase? db) {
    _database = db;
    notifyListeners();
  }
}

class CardDatabase {
  late List<Quest> quests;

  CardDatabase(this.quests);

  CardDatabase where(bool Function(Card card) filter) {
    return CardDatabase(quests.map((quest) {
      Quest newQuest = Quest(quest.name);
      quest.cards.forEach((element) {
        if (filter.call(element)) {
          newQuest.add(element);
        }
      });
      return newQuest;
    }).toList());
  }
}

class Quest {
  late String name;

  /// Maps language codes (such as "es") to localized names for the card.
  final Map<String, String> localizedNames = {};

  int? number;
  final List<Hero> _heroes = [];
  final List<MarketplaceCard> _marketplaceCards = [];
  final List<Guardian> _guardians = [];
  final List<Room> _rooms = [];
  final List<Monster> _monsters = [];
  String? wildernessMonster;

  List<Hero> get heroes => _heroes;
  List<MarketplaceCard> get marketplaceCards => _marketplaceCards;
  List<MarketplaceCard> get spells => _marketplaceCards
      .where((card) => card.keywords.contains("Spell"))
      .toList();
  List<MarketplaceCard> get items => _marketplaceCards
      .where((card) => card.keywords.contains("Item"))
      .toList();
  List<MarketplaceCard> get weapons => _marketplaceCards
      .where((card) => card.keywords.contains("Weapon"))
      .toList();
  List<MarketplaceCard> get allies => _marketplaceCards
      .where((card) => card.keywords.contains("Ally"))
      .toList();
  List<Guardian> get guardians => _guardians;
  List<Room> get rooms => _rooms;
  List<Monster> get monsters => _monsters;

  List<Card> get cards => <Card>[
        ..._heroes,
        ..._marketplaceCards,
        ..._guardians,
        ..._rooms,
        ..._monsters,
      ];

  Quest(this.name);

  void add(Card card) {
    switch (card.runtimeType) {
      case Hero:
        {
          _heroes.add(card as Hero);
        }
        break;
      case MarketplaceCard:
        {
          _marketplaceCards.add(card as MarketplaceCard);
        }
        break;
      case Guardian:
        {
          _guardians.add(card as Guardian);
        }
        break;
      case Room:
        {
          _rooms.add(card as Room);
        }
        break;
      case Monster:
        {
          _monsters.add(card as Monster);
        }
        break;
      default:
        {
          throw new Exception("Illegal State");
        }
    }
  }

  /// Get the quest's name in the given localized code, or the canonical name if
  /// it is not localized
  String getLocalizedName(String languageCode) =>
      localizedNames[languageCode] ?? name;
}

class CannotBuildException implements Exception {
  String cause;
  CannotBuildException(this.cause);
}

abstract class Card {
  late Quest quest;

  /// The canonical (English) name of the card.
  ///
  /// This is appropriate to use for filtering the collection. Use
  /// [getLocalizedName] for localized, user-friendly names.
  late String name;

  /// Maps language codes (e.g. "es") to the localized name of the card
  late final Map<String, String> localizedNames;

  List<String> keywords = [];
  String? memo;
  late final Map<String, String> localizedMemos;
  Set<String> combo = Set();
  Set<String> meta = Set();

  Card(CardBuilder builder)
      : localizedNames = builder.localizedNames,
        memo = builder.memo,
        localizedMemos = builder.localizedMemos,
        keywords = builder.keywords,
        combo = builder.combo,
        meta = builder.meta {
    // Process the required elements, without which we cannot build a card.
    if (builder.quest == null) {
      throw CannotBuildException("Card has no quest");
    }
    if (builder.name == null) {
      throw CannotBuildException("Card has no name");
    }
    this.quest = builder.quest!;
    this.name = builder.name!;
  }

  /// Get the name of this card, localized to the given language code.
  /// If that language code has no localization, return the canonical name.
  String getLocalizedName(String languageCode) =>
      localizedNames[languageCode] ?? name;

  /// Get the memo for this card, localized to the given language code.
  ///
  /// If there is no such localization, the canonical memo is returned instead,
  /// if any.
  String? getLocalizedMemo(String languageCode) =>
      localizedMemos[languageCode] ?? memo;

  @override
  String toString() {
    return name;
  }
}

abstract class CardBuilder {
  Quest? quest;
  String? name;
  final Map<String, String> localizedNames = {};
  List<String> keywords = [];
  String? memo;
  final Map<String, String> localizedMemos = {};
  Set<String> combo = Set();
  Set<String> meta = Set();
}

class Hero extends Card {
  Hero(HeroBuilder builder) : super(builder);
}

class HeroBuilder extends CardBuilder {
  Hero build() {
    return Hero(this);
  }
}

class MarketplaceCard extends Card {
  MarketplaceCard(MarketplaceCardBuilder builder) : super(builder);
}

class MarketplaceCardBuilder extends CardBuilder {
  MarketplaceCard build() {
    return MarketplaceCard(this);
  }
}

class Guardian extends Card {
  int? level;

  Guardian(GuardianBuilder builder)
      : level = builder.level,
        super(builder);
}

class GuardianBuilder extends CardBuilder {
  int? level;
  Guardian build() {
    return new Guardian(this);
  }
}

class Room extends Card {
  int? level;

  Room(RoomBuilder builder)
      : this.level = builder.level,
        super(builder);
}

class RoomBuilder extends CardBuilder {
  int? level;
  Room build() {
    return new Room(this);
  }
}

class Monster extends Card {
  int? level;
  bool soloRestriction;
  Monster(MonsterBuilder builder)
      : this.level = builder.level,
        this.soloRestriction = builder.soloRestriction ?? false,
        super(builder);
}

class MonsterBuilder extends CardBuilder {
  int? level;

  bool? soloRestriction;

  Monster build() {
    return new Monster(this);
  }
}
