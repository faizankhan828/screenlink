import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/local_preferences_service.dart';
import 'core/routing/scene_link_router.dart';
import 'core/theme/scene_link_theme.dart';
import 'repositories/firebase_app_repository.dart';
import 'repositories/mock_app_repository.dart';
import 'state/app_controller.dart';

class SceneLinkApp extends StatelessWidget {
  const SceneLinkApp({super.key, required this.firebaseEnabled});

  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) {
    final appRepository = firebaseEnabled ? FirebaseAppRepository() : MockAppRepository();

    return ChangeNotifierProvider(
      create: (_) {
        final controller = AppController(
          repository: appRepository,
          preferences: LocalPreferencesService(),
        );
        controller.bootstrap();
        return controller;
      },
      child: Consumer<AppController>(
        builder: (context, controller, _) {
          final theme = controller.themeMode == ThemeMode.dark
              ? SceneLinkTheme.dark(
                  highContrast: controller.accessibility.highContrast,
                  reducedMotion: controller.accessibility.reducedMotion,
                )
              : SceneLinkTheme.light(
                  highContrast: controller.accessibility.highContrast,
                  reducedMotion: controller.accessibility.reducedMotion,
                );
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'SceneLink',
            theme: theme,
            darkTheme: SceneLinkTheme.dark(
              highContrast: controller.accessibility.highContrast,
              reducedMotion: controller.accessibility.reducedMotion,
            ),
            themeMode: controller.themeMode,
            routerConfig: controller.router,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              final scaled = mediaQuery.copyWith(
                textScaler: TextScaler.linear(controller.accessibility.textScaleFactor),
                accessibleNavigation: controller.accessibility.screenReaderFriendly,
                disableAnimations: controller.accessibility.reducedMotion,
              );
              return MediaQuery(data: scaled, child: child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}