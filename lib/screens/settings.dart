import 'package:flutter/material.dart';
import 'package:flutter_tqr/domain_model.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final CardDatabase database;

  SettingsPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Quests', style: Theme.of(context).textTheme.headline4),
              Consumer<SettingsModel>(
                builder: (context, settings, child) => Column(
                    children: database.quests
                        .map(
                          (quest) => Row(
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
                              FlatButton(
                                child: Text((quest.code == null
                                        ? ''
                                        : '${quest.code}: ') +
                                    quest.name),
                                onPressed: () {
                                  if (settings.includes(quest.name)) {
                                    settings.exclude(quest.name);
                                  } else {
                                    settings.include(quest.name);
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                        .toList()),
              ),
              Row(
                children: <Widget>[
                  Text('Hero selection strategy:'),
                  Consumer<SettingsModel>(
                    builder: (context, settings, child) => DropdownButton(
                        items: SettingsModel.heroStrategies
                            .map((strategy) => DropdownMenuItem(
                                child: Text(strategy.name), value: strategy))
                            .toList(),
                        onChanged: (value) {
                          settings.heroSelectionStrategy = value;
                        },
                        value: settings.heroSelectionStrategy),
                  ),
                ],
              ),
              Consumer<SettingsModel>(
                  builder: (context, settings, child) => OutlineButton(
                      child: Text('Reset Settings to Defaults'),
                      onPressed: () => settings.clear())),
            ],
          ),
        ),
      ),
    );
  }
}
