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
  late String canonicalName;
  int? number;
  final List<Hero> _heroes = [];
  final List<MarketplaceCard> _marketplaceCards = [];
  final List<Guardian> _guardians = [];
  final List<Room> _rooms = [];
  final List<Monster> _monsters = [];

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
}

class CannotBuildException implements Exception {
  String cause;
  CannotBuildException(this.cause);
}

abstract class Card {
  late Quest quest;

  /// The localized name of a card, appropriate for showing users.
  late String name;

  /// The canonical name, appropriate for filters, blacklists, processing, etc.
  late String canonicalName;
  List<String> keywords = [];
  String? memo;
  Set<String> combo = Set();
  Set<String> meta = Set();

  Card(CardBuilder builder)
      : memo = builder.memo,
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
    if (builder.canonicalName == null) {
      throw CannotBuildException("Card has no canonical name");
    }
    this.quest = builder.quest!;
    this.name = builder.name!;
    this.canonicalName = builder.canonicalName!;
  }

  @override
  String toString() {
    return name;
  }
}

abstract class CardBuilder {
  Quest? quest;
  String? name;
  String? canonicalName;
  List<String> keywords = [];
  String? memo;
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
