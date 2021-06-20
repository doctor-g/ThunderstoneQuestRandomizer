import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static final double _maxComboBias = 0.95;
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
                    _heading(context, 'Appearance'),
                    Consumer<SettingsModel>(
                        builder: (context, settings, child) => Column(
                              children: <Widget>[
                                _makeCheckbox(
                                    context,
                                    'Light Mode',
                                    settings.brightness == Brightness.light,
                                    (value) => settings.brightness = value
                                        ? Brightness.light
                                        : Brightness.dark),
                                _makeCheckbox(
                                    context,
                                    'Show card keyword traits',
                                    settings.showKeywords,
                                    (value) => settings.showKeywords =
                                        !settings.showKeywords),
                                _makeCheckbox(
                                    context,
                                    'Show card memo',
                                    settings.showMemo,
                                    (value) =>
                                        settings.showMemo = !settings.showMemo),
                                _makeCheckbox(
                                    context,
                                    'Show card quest',
                                    settings.showQuest,
                                    (value) => settings.showQuest =
                                        !settings.showQuest),
                              ],
                            )),
                    Divider(),
                    _heading(context, 'Quests'),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: database.quests
                              .map((quest) => _makeCheckbox(
                                      context,
                                      (quest.number == null
                                              ? ''
                                              : 'Quest ${quest.number}: ') +
                                          quest.name,
                                      settings.includes(quest.name), (value) {
                                    if (settings.includes(quest.name)) {
                                      settings.exclude(quest.name);
                                    } else {
                                      settings.include(quest.name);
                                    }
                                  }))
                              .toList()),
                    ),
                    Divider(),
                    _heading(context, 'Mode'),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                        children: [
                          _makeCheckbox(
                              context,
                              'Barricades Mode',
                              settings.barricadesMode,
                              (value) => settings.barricadesMode =
                                  !settings.barricadesMode),
                          _makeDescription(context,
                              'Use Level VII Enemies. Filter out cards unfit for Barricades play.'),
                        ],
                      ),
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
                            max: _maxComboBias,
                            value: settings.comboBias,
                            onChanged: (value) => settings.comboBias = value,
                          ),
                          _makeDescription(context,
                              'The probability that, for a given card, it is accepted only if it combos with cards already selected.'),
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
                                settings.heroSelectionStrategy =
                                    value as HeroSelectionStrategy;
                              },
                              value: settings.heroSelectionStrategy),
                          _makeDescription(context,
                              settings.heroSelectionStrategy.description),
                        ],
                      ),
                    ),
                    Divider(),
                    Text('Miscellaneous',
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => OutlinedButton(
                        child: Text('Reset Settings to Defaults',
                            style: Theme.of(context).textTheme.bodyText1),
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

  // See https://github.com/flutter/flutter/issues/39731 to explain
  // why a StatefulBuilder is needed here and not just a list tile.
  Widget _makeCheckbox(BuildContext context, String title, bool value,
      void onChanged(bool value)) {
    final TextStyle checkboxTextStyle =
        Theme.of(context).textTheme.bodyText1 as TextStyle;
    return StatefulBuilder(
      builder: (context, _setState) => CheckboxListTile(
        title: Text(
          title,
          style: checkboxTextStyle,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: (value) {
          _setState(() => onChanged(value!));
        },
      ),
    );
  }

  Widget _heading(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.subtitle1);

  Widget _makeDescription(BuildContext context, String text) => Text(text,
      style: Theme.of(context).textTheme.bodyText2,
      textAlign: TextAlign.center);
}
