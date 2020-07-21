import 'package:yaml/yaml.dart';
import 'package:flutter_tqr/domain_model.dart';

class ThunderstoneYamlCardParser {
  CardDatabase parse(String yaml) {
    List<Quest> quests = new List();
    var document = loadYaml(yaml);
    for (var questNode in document) {
      Quest quest = _parseQuest(questNode);
      quests.add(quest);
    }
    return CardDatabase(quests);
  }

  Quest _parseQuest(var node) {
    Quest quest = new Quest();
    quest.name = node['Quest'];
    quest.code = node['Code'];
    for (var entry in node['Heroes']) {
      Hero hero = new Hero();
      hero.name = entry['Name'];
      if (entry['Keywords'] != null) {
        for (var keyword in entry['Keywords']) {
          hero.keywords.add(keyword);
        }
      }
      quest.heroes.add(hero);
    }
    return quest;
  }
}
