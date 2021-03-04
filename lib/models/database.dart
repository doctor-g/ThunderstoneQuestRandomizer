class CardDatabase {
  List<Quest> quests;

  CardDatabase(List<Quest> quests) {
    this.quests = quests;
  }
}

class Quest {
  String name;
  int number;
  final List<Hero> heroes = [];
  final List<Item> items = [];
  final List<Spell> spells = [];
  final List<Weapon> weapons = [];
  final List<Ally> allies = [];
  final List<Guardian> guardians = [];
  final List<Room> rooms = [];
  final List<Monster> monsters = [];

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
