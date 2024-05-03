import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  static final double _maxComboBias = 0.95;
  static final Map<String, String> _supportedLanguages = {
    "en": "English",
    // "fr": "French"
  };
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
                                _supportedLanguages.length > 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .settings_language,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                          SizedBox(width: 8),
                                          _makeLanguageSelectionSetting(
                                              context),
                                        ],
                                      )
                                    : SizedBox(width: 0)
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
                                          ? quest.getLocalizedName(
                                              settings.language)
                                          : AppLocalizations.of(context)!
                                              .settings_quest(
                                                  quest.number!,
                                                  quest.getLocalizedName(
                                                      settings.language))),
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
                                  .settings_wilderness_monster,
                              settings.randomizeWildernessMonster,
                              (value) => settings.randomizeWildernessMonster =
                                  !settings.randomizeWildernessMonster),
                          Text(
                              AppLocalizations.of(context)!.settings_ratChance(
                                  _formatPercent(settings.ratChance)),
                              style: Theme.of(context).textTheme.bodyLarge),
                          Slider(
                            min: 0,
                            max: 1,
                            value: settings.ratChance,
                            onChanged: settings.randomizeWildernessMonster
                                ? (value) => settings.ratChance = value
                                : null,
                          ),
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_ratChance_hint),
                          _makeVerticalSpace(),
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
                          _makeVerticalSpace(),
                          _makeCheckbox(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_smallTableau,
                              settings.smallTableau,
                              (value) => settings.smallTableau =
                                  !settings.smallTableau),
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_smallTableau_hint),
                          _makeCheckbox(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_useCorruption,
                              settings.useCorruption,
                              (value) => settings.useCorruption =
                                  !settings.useCorruption),
                          _makeDescription(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_useCorruption_hint),
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
                          _makeCheckbox(
                              context,
                              AppLocalizations.of(context)!
                                  .settings_useComboBias,
                              settings.useComboBias,
                              (value) => settings.useComboBias =
                                  !settings.useComboBias),
                          _makeDescription(
                            context,
                            AppLocalizations.of(context)!
                                .settings_useComboBias_hint,
                          ),
                          Slider(
                            min: 0,
                            max: _maxComboBias,
                            value: settings.comboBias,
                            onChanged: settings.useComboBias
                                ? (value) => settings.comboBias = value
                                : null,
                          ),
                          Text(
                            '${(settings.comboBias * 100).truncate()}%',
                            style:
                                _createComboBiasLabelTheme(context, settings),
                          ),
                          _makeDescription(
                            context,
                            AppLocalizations.of(context)!
                                .settings_comboBias_hint,
                          ),
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
                                              .bodyLarge),
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
                        style: Theme.of(context).textTheme.titleMedium),
                    Consumer<SettingsModel>(
                      builder: (context, settings, child) => OutlinedButton(
                        child: Text(
                            AppLocalizations.of(context)!.settings_reset,
                            style: Theme.of(context).textTheme.bodyLarge),
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
        Theme.of(context).textTheme.bodyLarge as TextStyle;
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
      Text(text, style: Theme.of(context).textTheme.titleMedium);

  Widget _makeDescription(BuildContext context, String text) => Text(text,
      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _makeLanguageSelectionSetting(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) => DropdownButton(
        items: _supportedLanguages.entries
            .map((entry) => DropdownMenuItem(
                  child: Text(entry.value,
                      style: Theme.of(context).textTheme.bodyLarge),
                  value: entry.key,
                ))
            .toList(),
        onChanged: (String? code) {
          print(
              'You selected ${code == null ? "Nothing" : _supportedLanguages[code]}');
          if (code != null) {
            settings.language = code;
          }
        },
        value: settings.language,
      ),
    );
  }

  String _formatPercent(double percent) => '${(percent * 100).truncate()}%';

  _createComboBiasLabelTheme(BuildContext context, SettingsModel settings) {
    final theme = Theme.of(context).textTheme.titleSmall!;
    return settings.useComboBias
        ? theme
        : theme.copyWith(color: Theme.of(context).disabledColor);
  }
}
