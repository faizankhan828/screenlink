import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/font_preload_service.dart';
import 'core/theme/scene_link_theme.dart';
import '../firebase_options.dart';

class SceneLinkBootstrap extends StatefulWidget {
  const SceneLinkBootstrap({super.key});

  @override
  State<SceneLinkBootstrap> createState() => _SceneLinkBootstrapState();
}

class _SceneLinkBootstrapState extends State<SceneLinkBootstrap> {
  late final Future<bool> _firebaseReady = _bootstrapFirebase();

  Future<bool> _bootstrapFirebase() async {
    try {
      final results = await Future.wait([
        _initializeFirebase(),
        preloadSceneLinkFonts(),
      ]);
      return results.first as bool;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } on UnsupportedError {
      await Firebase.initializeApp();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _firebaseReady,
      builder: (context, snapshot) {
        final firebaseEnabled = snapshot.data ?? false;
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: SceneLinkTheme.light(highContrast: false, reducedMotion: true),
            home: const _SplashLoader(),
          );
        }

        return SceneLinkApp(firebaseEnabled: firebaseEnabled);
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E5AE0), Color(0xFF5D2F99)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(Icons.movie_filter_rounded, size: 34, color: Color(0xFF7C3AED)),
              ),
              SizedBox(height: 16),
              Text(
                'SceneLink',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connecting creatives across the West Midlands',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}