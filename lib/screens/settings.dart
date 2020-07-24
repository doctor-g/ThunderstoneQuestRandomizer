import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final CardDatabase database;

  SettingsPage(this.database);

  @override
  Widget build(BuildContext context) {
    final TextStyle checkboxTextStyle = Theme.of(context).textTheme.bodyText1;
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
                    _heading(context, 'Appearance'),
                    Consumer<SettingsModel>(
                        builder: (context, settings, child) => Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: settings.showKeywords,
                                      onChanged: (value) =>
                                          settings.showKeywords = value,
                                    ),
                                    FlatButton(
                                      child: Text('Show keyword traits',
                                          style: checkboxTextStyle),
                                      onPressed: () => settings.showKeywords =
                                          !settings.showKeywords,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: settings.showMemo,
                                      onChanged: (value) =>
                                          settings.showMemo = value,
                                    ),
                                    FlatButton(
                                      child: Text('Show card memo',
                                          style: checkboxTextStyle),
                                      onPressed: () => settings.showMemo =
                                          !settings.showMemo,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                    _heading(context, 'Quests'),
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
                                          style: checkboxTextStyle),
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
                    _heading(context, 'Combo Bias'),
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
                          Text(
                              'The probability that, for a given card, it is accepted only if it combos with cards already selected.',
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    ),
                    Divider(),
                    _heading(context, 'Hero Selection'),
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
                            style: Theme.of(context).textTheme.bodyText2,
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

  Widget _heading(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.subtitle1);
}
