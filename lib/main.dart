import 'package:flutter/material.dart';

import 'models/game_settings.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';
import 'theme/wooden_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<_AppServices> _services = _loadServices();

  Future<_AppServices> _loadServices() async {
    final storage = await StorageService.create();
    final sound = SoundService();
    await sound.initialize();
    await sound.setVolume(storage.loadSettings().masterVolume);
    return _AppServices(storage, sound);
  }

  @override
  void dispose() {
    _services.then((services) => services.sound.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Wooden Puzzle',
      debugShowCheckedModeBanner: false,
      theme: buildWoodenTheme(),
      home: FutureBuilder<_AppServices>(
        future: _services,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StartupError(error: snapshot.error!);
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFD6A65C)),
              ),
            );
          }
          final services = snapshot.data!;
          return HomeScreen(
            storage: services.storage,
            sound: services.sound,
            initialSettings: services.storage.loadSettings(),
          );
        },
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          'The game could not start.\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

class _AppServices {
  const _AppServices(this.storage, this.sound);
  final StorageService storage;
  final SoundService sound;
}

// Keep the model type available for clients that restore their own sessions.
typedef WoodenGameSettings = GameSettings;
