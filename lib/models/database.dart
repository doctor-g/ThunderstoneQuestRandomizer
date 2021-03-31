class CardDatabase {
  List<Quest> quests;

  CardDatabase(List<Quest> quests) {
    this.quests = quests;
  }
}

class Quest {
  String name;
  int number;
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

  void add(Card card) {
    switch (card.runtimeType) {
      case Hero:
        {
          _heroes.add(card);
        }
        break;
      case MarketplaceCard:
        {
          _marketplaceCards.add(card);
        }
        break;
      case Guardian:
        {
          _guardians.add(card);
        }
        break;
      case Room:
        {
          _rooms.add(card);
        }
        break;
      case Monster:
        {
          _monsters.add(card);
        }
        break;
      default:
        {
          throw new Exception("Illegal State");
        }
        break;
    }
  }
}

class Card {
  Quest quest;
  String name;
  List<String> keywords = [];
  String memo;
  Set<String> combo = Set();
  Set<String> meta = Set();

  @override
  String toString() {
    return name;
  }
}

class Hero extends Card {}

class MarketplaceCard extends Card {}

class Guardian extends Card {
  int level;
}

class Room extends Card {
  int level;
}

class Monster extends Card {
  int level;
}
