import 'package:yaml/yaml.dart';
import 'package:flutter_tqr/quest.dart';

class QuestParser {
  Quest parse(String yaml) {
    var document = loadYaml(yaml);
    Quest quest = new Quest();
    for (var entry in document['Heroes']) {
      Hero hero = new Hero();
      hero.name = entry['Name'];
      quest.heroes.add(hero);
    }
    return quest;
  }
}
