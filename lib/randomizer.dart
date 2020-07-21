import 'package:flutter_tqr/models/settings.dart';

import 'domain_model.dart';

class Randomizer {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];

  List<Hero> chooseHeroes(CardDatabase db, SettingsModel settings) {
    // Make a master list of all the heroes
    List<Hero> allHeroes = new List();
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        allHeroes += quest.heroes;
      }
    }

    return settings.heroSelectionStrategy.selectHeroesFrom(allHeroes);
  }
}
