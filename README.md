# Thunderstone Quest Randomizer

This application is a randomizer for [_Thunderstone Quest_](https://alederac.com/thunderstone). You can use it to generate randomized tableaus for playing the game in competitive mode. 

[Use the Web app now!](https://doctor-g.github.io/ThunderstoneQuestRandomizer)

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

&copy;2020 Paul Gestwicki

This application is licensed under [GNU GPL v3](LICENSE).