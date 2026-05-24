import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_router_keys.dart';
import '../../state/app_controller.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/maps/maps_screen.dart';
import '../../screens/social/friends_screen.dart';
import '../../screens/messages/messages_screen.dart';
import '../../screens/messages/chat_detail_screen.dart';
import '../../screens/premium/payment_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/projects/projects_screen.dart';
import '../../screens/projects/create_project_screen.dart';
import '../../screens/projects/project_detail_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/settings/accessibility_screen.dart';
import '../../screens/settings/premium_dashboard_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/splash_screen.dart';

bool _isProtectedRoute(String location) {
  const roots = {
    '/app',
    '/home',
    '/search',
    '/projects',
    '/maps',
    '/messages',
    '/settings',
    '/accessibility',
    '/premium',
    '/premium-dashboard',
    '/friends',
    '/profile',
  };
  if (roots.contains(location)) return true;
  const prefixes = [
    '/projects/',
    '/messages/',
    '/profile/',
    '/settings/',
    '/accessibility/',
    '/premium/',
  ];
  return prefixes.any(location.startsWith);
}

/// No animation — splash → login/signup should feel instant.
CustomTransitionPage<void> _instantPage({required Widget child, required GoRouterState state}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

GoRouter buildSceneLinkRouter(AppController controller) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/loading',
    refreshListenable: controller,
    redirect: (context, state) {
      final location = state.uri.path;
      final isLoading = location == '/loading';
      final isAuthRoute = location == '/login' || location == '/signup';

      if (!controller.isReady) {
        return isLoading ? null : '/loading';
      }

      if (controller.currentUser == null) {
        if (isAuthRoute || isLoading) {
          return null;
        }
        return '/login';
      }

      if (isAuthRoute || isLoading || location == '/') {
        return '/app';
      }

      if (!_isProtectedRoute(location)) {
        return '/app';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => _instantPage(child: const SplashScreen(), state: state),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _instantPage(child: const LoginScreen(), state: state),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _instantPage(child: const SignupScreen(), state: state),
      ),
      GoRoute(
        path: '/app',
        pageBuilder: (context, state) => _instantPage(child: const AppShell(), state: state),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final controller = context.read<AppController>();
          final matches = controller.projects.where((item) => item.projectId == projectId);
          if (matches.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Project not found')),
            );
          }
          return ProjectDetailScreen(project: matches.first);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/edit',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final controller = context.read<AppController>();
          final project = controller.projects.firstWhere((item) => item.projectId == projectId);
          return CreateProjectScreen(existingProject: project);
        },
      ),
      GoRoute(
        path: '/maps',
        builder: (context, state) => const MapsScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '/messages/:chatId',
        builder: (context, state) => ChatDetailScreen(
          chatId: state.pathParameters['chatId']!,
          title: state.uri.queryParameters['title'] ?? 'Conversation',
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/accessibility',
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/premium-dashboard',
        builder: (context, state) => const PremiumDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) => ProfileScreen(userId: state.pathParameters['userId']),
      ),
    ],
  );
}
