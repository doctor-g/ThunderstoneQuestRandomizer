# Thunderstone Quest Randomizer

This application is a randomizer for [_Thunderstone Quest_](https://alederac.com/thunderstone). You can use it to generate randomized tableaus for playing the game in competitive mode. 

[Use the Web app now!](https://doctor-g.github.io/ThunderstoneQuestRandomizer)

## Building

This app uses [`source_gen`](https://pub.dev/packages/source_gen) to process
the `SettingsModel` implementation. Before the rest of the application can
be built, `build_runner` has to be invoked. This is done with the command:
```
dart run build_runner build
```
That can be invoked in VSCode via Ctrl-Shift-B.

Using the `watch` command instead will start a process that rebuilds on
changes, as in:
```
dart run build_runner watch
```

### Automatic building in Visual Studio Code

[`.vscode/tasks.json`](.vscode/tasks.json) is configured so that the build_runner
watcher will start when the folder opens. However, each VSCode instance needs
to be configured to allow this to happen. Do this through the command palette
(Ctrl-Shift-P) and running "Tasks: Configure Automatic Tasks in Folder",
which will give an option to enable to tasks.

## Localization

The [`cards.yml`](assets/cards.yaml) file can be localized into different languages.
See that files for translation instructions. To enable a language in the settings
page, add (or uncomment) an appropriate line in the definition of `_supportedLanguages`
in [settings.dart](lib/screens/settings.dart) 

The rest of the app also supports localization using the Intl package
[as described in the docs](https://flutter.dev/docs/development/accessibility-and-localization/internationalization). A new language could
be added by creating a new `.arb` for the given language (e.g. `app_fr.erb` for 
French).

## Background

In 2019, I created [_TSQR_](https://doctor-g.github.io/tsqr/), which is another randomizer for _Thunderstone Quest_. It was created using a different technology stack I was investigating at the time.
The original _TSQR_ is still [available online](https://doctor-g.github.io/tsqr/), if you prefer to use it.

In Summer 2020, I decided to learn [Flutter](https://flutter.dev) with an eye toward using it in [a Fall 2020 course](https://www.cs.bsu.edu/~pvgestwicki/courses/cs445Fa20).
I was inspired by the release of the [New Horizons set](https://www.kickstarter.com/projects/alderac/thunderstone-quest-new-horizons-from-aeg) to revisit the problem domain with a new technology stack. 
I was able to add Quests 8&ndash;9 to _TSQR_ without too much difficulty except that my original randomizer contained assumptions that prevented the inclusion of the new Ally cards&mdash;at least, without requiring a significant reimplementation effort. 
Hence, I decided to spend some time getting deeper into Flutter, and the result is this application.

## Third-party assets

- [Multiple Dice Icon](https://materialdesignicons.com/icon/dice-multiple-outline)
- [Cormorant](https://fonts.google.com/specimen/Cormorant) and [CormorantSC](https://fonts.google.com/specimen/Cormorant+SC), used under [OFL](assets/fonts/OFL.txt)

## Acknowledgements

[_Thunderstone Quest_](https://alederac.com/thunderstone) is a property of [Alderac Entertainment Group](https://alderac.com).

Thanks to Alex for his invaluable assistance with encoding the card data.

## Legal

&copy;2020&ndash;2024 Paul Gestwicki

This application is licensed under [GNU GPL v3](LICENSE).