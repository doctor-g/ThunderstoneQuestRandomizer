import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  static final double _maxComboBias = 0.95;
  final CardDatabase database;

  SettingsPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings_title),
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
                    _heading(
                        context,
                        AppLocalizations.of(context)!
                            .settings_section_appearance),
                    Consumer<SettingsModel>(
                        builder: (context, settings, child) => Column(
                              children: <Widget>[
                                _makeCheckbox(
                                    context,
                                    AppLocalizations.of(context)!
                                        .settings_lightMode,
                                    settings.brightness == Brightness.light,
                                    (value) => settings.brightness = value
                                        ? Brightness.light
                                        : Brightness.dark),
                                _makeCheckbox(
                                    context,
                                    AppLocalizations.of(context)!
                                        .settings_showKeywords,
                                    settings.showKeywords,
                                    (value) => settings.showKeywords =
                                        !settings.showKeywords),
                                _makeCheckbox(
                                    context,
                                    AppLocalizations.of(context)!
                                        .settings_showMemo,
                                    settings.showMemo,
                                    (value) =>
                                        settings.showMemo = !settings.showMemo),
                                _makeCheckbox(
                                    context,
                                    AppLocalizations.of(context)!
                                        .settings_showQuest,
                                    settings.showQuest,
                                    (value) => settings.showQuest =
                                        !settings.showQuest),
                              ],
                            )),
                    Divider(),
                    _heading(context,
                        AppLocalizations.of(context)!.settings_section_quests),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: database.quests
                              .map((quest) => _makeCheckbox(
                                      context,
                                      (quest.number == null
                                          ? quest.name
                                          : AppLocalizations.of(context)!
                                              .settings_quest(
                                                  quest.number!, quest.name)),
                                      settings.includes(quest), (value) {
                                    if (settings.includes(quest)) {
                                      settings.exclude(quest);
                                    } else {
                                      settings.include(quest);
                                    }
                                  }))
                              .toList()),
                    ),
                    Divider(),
                    _heading(context,
                        AppLocalizations.of(context)!.settings_section_mode),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                        children: [
                          _makeCheckbox(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_barricadesMode,
                              settings.barricadesMode,
                              (value) => settings.barricadesMode =
                                  !settings.barricadesMode),
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_barricadesMode_hint),
                          _makeVerticalSpace(),
                          _makeCheckbox(
                              context,
                              AppLocalizations.of(context)!.settings_soloMode,
                              settings.soloMode,
                              (value) =>
                                  settings.soloMode = !settings.soloMode),
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_soloMode_hint),
                        ],
                      ),
                    ),
                    Divider(),
                    _heading(
                        context,
                        AppLocalizations.of(context)!
                            .settings_section_comboBias),
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
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_comboBias_hint),
                        ],
                      ),
                    ),
                    Divider(),
                    _heading(
                        context,
                        AppLocalizations.of(context)!
                            .settings_section_hero_selection),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => Column(
                        children: <Widget>[
                          DropdownButton(
                              items: SettingsModel.heroStrategies
                                  .map((strategy) => DropdownMenuItem(
                                      child: Text(
                                          _localizeName(context, strategy),
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
                          _makeDescription(
                              context,
                              _localizeDescription(
                                  context, settings.heroSelectionStrategy)),
                        ],
                      ),
                    ),
                    Divider(),
                    Text(AppLocalizations.of(context)!.settings_section_misc,
                        style: Theme.of(context).textTheme.subtitle1),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => OutlinedButton(
                        child: Text(
                            AppLocalizations.of(context)!.settings_reset,
                            style: Theme.of(context).textTheme.bodyText1),
                        onPressed: () => settings.clear(),
                      ),
                    ),
                    _makeVerticalSpace(),
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

  String _localizeDescription(
      BuildContext context, HeroSelectionStrategy strategy) {
    switch (strategy.runtimeType) {
      case FirstMatchHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_firstmatch_desc;
      case OnePerClassHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_traditional_desc;
      case RandomHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_unconstrained_desc;
      default:
        throw Exception(
            "Unrecognized hero selection strategy type: ${strategy.runtimeType}");
    }
  }

  String _localizeName(BuildContext context, HeroSelectionStrategy strategy) {
    switch (strategy.runtimeType) {
      case FirstMatchHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_firstmatch_name;
      case OnePerClassHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_traditional_name;
      case RandomHeroSelectionStrategy:
        return AppLocalizations.of(context)!.heroselection_unconstrained_name;
      default:
        throw Exception(
            "Unrecognized hero selection strategy type: ${strategy.runtimeType}");
    }
  }

  // This is used to add a little space between options that look too tight
  // otherwise.
  Widget _makeVerticalSpace() => SizedBox(height: 10);
}
