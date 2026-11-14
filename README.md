# The Wooden Puzzle

A wooden-themed number-sliding puzzle built with Flutter. Choose a 3×3, 4×4,
or 5×5 board and slide the numbered tiles into order. Puzzles are scrambled
using legal moves, so every generated puzzle is solvable.

## Features

- Classic puzzle gameplay with shuffle, restart, hint, undo, and pause controls.
- Daily Challenge with a repeatable puzzle for the current date and board size.
- Locally saved settings, best scores, and in-progress games.
- Optional sound effects, haptics, and tile animations.
- Result sharing and locally bundled WAV sound effects.
- Google AdMob test ads on Android and iOS: a banner in the game screen, a
  rewarded ad for hints, and an interstitial after every second completed
  puzzle. Gameplay and saved data are local; loading ads requires a network
  connection.

## Requirements

- Flutter SDK with Dart SDK `^3.12.1`.
- Android or iOS for AdMob. Other Flutter targets do not initialize or show ads.

## Run locally

```shell
flutter pub get
flutter run
```



## Project structure

- `lib/main.dart` — app entry point.
- `lib/screens/` — home, game, settings, and result screens.
- `lib/models/` — puzzle state and game settings.
- `lib/services/` — puzzle generation, local storage, sound, haptics.
- `lib/widgets/` — reusable wooden-themed game controls and board widgets.
- `assets/audio/` — bundled WAV sound effects.
- `android/` and `ios/` — native platform configuration

## Validate and build

```shell
flutter analyze
flutter test
flutter build apk --release
```


