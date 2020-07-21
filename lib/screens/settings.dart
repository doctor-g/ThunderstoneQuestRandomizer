import 'package:flutter/material.dart';
import 'package:flutter_tqr/domain_model.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Consumer<CardDatabaseModel>(
          builder: (context, value, child) => value.database == null
              ? Text('No data!')
              : Column(
                  children: <Widget>[
                    Text('Quests',
                        style: Theme.of(context).textTheme.headline4),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                          children: value.database.quests
                              .map((quest) => Row(
                                    children: [
                                      Checkbox(
                                        value: settings.includes(quest.name),
                                        onChanged: (value) {
                                          if (value) {
                                            settings.include(quest.name);
                                          } else {
                                            settings.exclude(quest.name);
                                          }
                                        },
                                      ),
                                      QuestIdentifier(quest)
                                    ],
                                  ))
                              .toList()),
                    ),
                    Row(
                      children: <Widget>[
                        Text('Hero selection strategy:'),
                        Consumer<SettingsModel>(
                          builder: (context, settings, child) => DropdownButton(
                              items: SettingsModel.heroStrategies
                                  .map((strategy) => DropdownMenuItem(
                                      child: Text(strategy.name),
                                      value: strategy))
                                  .toList(),
                              onChanged: (value) {
                                settings.heroSelectionStrategy = value;
                              },
                              value: settings.heroSelectionStrategy),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class QuestIdentifier extends StatelessWidget {
  final Quest quest;

  QuestIdentifier(Quest quest) : quest = quest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        quest.code == null ? Container() : Text('${quest.code}: '),
        Text(quest.name)
      ],
    );
  }
}
