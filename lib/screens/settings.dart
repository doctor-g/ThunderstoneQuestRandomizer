import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  children: <Widget>[
                    Text('Quests',
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child: Text(
                                          (quest.code == null
                                                  ? ''
                                                  : '${quest.code}: ') +
                                              quest.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
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
                    Divider(),
                    Text('Combo Bias',
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                        children: <Widget>[
                          Text('${(settings.comboBias * 100).truncate()}%',
                              style: Theme.of(context).textTheme.subtitle2),
                          Slider(
                            min: 0,
                            max: 0.8,
                            value: settings.comboBias,
                            onChanged: (value) => settings.comboBias = value,
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Text('Hero Selection',
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                        children: <Widget>[
                          DropdownButton(
                              items: SettingsModel.heroStrategies
                                  .map((strategy) => DropdownMenuItem(
                                      child: Text(strategy.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                      value: strategy))
                                  .toList(),
                              onChanged: (value) {
                                settings.heroSelectionStrategy = value;
                              },
                              value: settings.heroSelectionStrategy),
                          Text(
                            settings.heroSelectionStrategy.description,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    Text('Miscellaneous',
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => OutlineButton(
                        child: Text('Reset Settings to Defaults'),
                        onPressed: () => settings.clear(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
