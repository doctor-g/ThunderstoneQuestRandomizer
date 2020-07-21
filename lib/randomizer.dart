import 'dart:math';
import 'domain_model.dart';

class Randomizer {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];

  Random _random = new Random();

  List<Hero> chooseHeroes(CardDatabase db) {
    // Make a master list of all the heroes
    List<Hero> allHeroes = new List();
    for (Quest quest in db.quests) {
      allHeroes += quest.heroes;
    }

    // Try a random set of four
    List<Hero> result = new List();
    for (var i = 0; i < 4; i++) {
      int index = _random.nextInt(allHeroes.length);
      Hero hero = allHeroes.removeAt(index);
      result.add(hero);
    }

    // If we have all the classes, we're done.
    // If not, recursively try again.
    if (result
        .map((hero) => hero.keywords)
        .expand((element) => element)
        .toSet()
        .containsAll(classes)) {
      return result..sort((hero1, hero2) => hero1.name.compareTo(hero2.name));
    } else {
      return chooseHeroes(db);
    }
  }
}
