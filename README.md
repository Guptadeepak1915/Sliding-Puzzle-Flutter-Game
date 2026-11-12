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

## AdMob configuration

The project currently uses Google's sample **test** App IDs and ad unit IDs.
Keep test IDs during development; replace them with your own IDs before
publishing:

- Android App ID: `android/app/src/main/AndroidManifest.xml`, in the
  `com.google.android.gms.ads.APPLICATION_ID` value.
- iOS App ID: `ios/Runner/Info.plist`, in the `GADApplicationIdentifier` value.
- Android and iOS banner, interstitial, and rewarded ad unit IDs:
  `lib/services/ad_service.dart` (`bannerId`, `interstitialId`, and
  `rewardedId`).

App IDs contain `~`; ad unit IDs contain `/`. Use the IDs for the matching
platform and ad format.

## Project structure

- `lib/main.dart` — app entry point and AdMob initialization.
- `lib/screens/` — home, game, settings, and result screens.
- `lib/models/` — puzzle state and game settings.
- `lib/services/` — puzzle generation, local storage, sound, haptics, and ads.
- `lib/widgets/` — reusable wooden-themed game controls and board widgets.
- `assets/audio/` — bundled WAV sound effects.
- `android/` and `ios/` — native platform configuration, including AdMob App IDs.

## Validate and build

```shell
flutter analyze
flutter test
flutter build apk --release
```


for admob replacement 
Android

App ID: AndroidManifest.xml:8
Banner Ad Unit ID: ad_service.dart:15
Interstitial Ad Unit ID: ad_service.dart:21
Rewarded Ad Unit ID: ad_service.dart:27

iOS

App ID: Info.plist:20
Banner Ad Unit ID: ad_service.dart:16
Interstitial Ad Unit ID: ad_service.dart:22
Rewarded Ad Unit ID: ad_service.dart:28