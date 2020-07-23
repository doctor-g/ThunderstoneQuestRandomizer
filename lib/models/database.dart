class CardDatabase {
  List<Quest> quests;

  CardDatabase(List<Quest> quests) {
    this.quests = quests;
  }
}

class Quest {
  String name;
  String code;
  final List<Hero> heroes = new List();
  final List<Item> items = new List();
  final List<Spell> spells = new List();
  final List<Weapon> weapons = new List();
  final List<Ally> allies = new List();
  final List<Guardian> guardians = new List();
  final List<Room> rooms = new List();
  final List<Monster> monsters = new List();

  List<Card> get cards => <Card>[
        ...heroes,
        ...items,
        ...spells,
        ...weapons,
        ...allies,
        ...guardians,
        ...rooms,
        ...monsters,
      ];
}

class Card {
  String name;
  List<String> keywords = List();
  String memo;
  Set<String> combo = Set();
  Set<String> meta = Set();

  @override
  String toString() {
    return name;
  }
}

class Hero extends Card {}

class Item extends Card {}

class Spell extends Card {}

class Weapon extends Card {}

class Ally extends Card {}

class Guardian extends Card {
  int level;
}

class Room extends Card {
  int level;
}

class Monster extends Card {
  int level;
}
