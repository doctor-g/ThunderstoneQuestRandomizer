class CardDatabase {
  List<Quest> quests;

  CardDatabase(List<Quest> quests) {
    this.quests = quests;
  }
}

class Quest {
  String name;
  String code;
  List<Hero> heroes = new List();
}

class Hero {
  String name;
  List<String> keywords = new List();
}
