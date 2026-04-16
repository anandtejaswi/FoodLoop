// ============================================================
// config/app_routes.dart  –  All Named Routes (GoRouter)
// ============================================================

import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/onboarding/role_selection_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/giver/giver_dashboard_screen.dart';
import '../screens/giver/post_food_screen.dart';
import '../screens/giver/giver_requests_screen.dart';
import '../screens/taker/taker_dashboard_screen.dart';
import '../screens/taker/food_list_screen.dart';
import '../screens/taker/food_detail_screen.dart';
import '../screens/taker/taker_requests_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/shared/review_screen.dart';
import '../models/request_model.dart';

class AppRoutes {
  // ─── Route name constants ────────────────────────────────────
  static const String splash         = '/';
  static const String signIn         = '/sign-in';
  static const String signUp         = '/sign-up';
  static const String roleSelection  = '/role-selection';

  // Giver routes
  static const String giverDashboard = '/giver/dashboard';
  static const String postFood       = '/giver/post-food';
  static const String giverRequests  = '/giver/requests';
  static const String giverProfile   = '/giver/profile';

  // Taker routes
  static const String takerDashboard = '/taker/dashboard';
  static const String foodList       = '/taker/food-list';
  static const String foodDetail     = '/taker/food-detail';
  static const String takerRequests  = '/taker/requests';
  static const String takerProfile   = '/taker/profile';

  // Shared routes
  static const String review         = '/review';
  static const String settings       = '/settings';

  // ─── GoRouter configuration ──────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash
      GoRoute(path: splash,        builder: (ctx, state) => const SplashScreen()),
      // Auth
      GoRoute(path: signIn,        builder: (ctx, state) => const SignInScreen()),
      GoRoute(path: signUp,        builder: (ctx, state) => const SignUpScreen()),
      GoRoute(path: roleSelection,  builder: (ctx, state) => const RoleSelectionScreen()),

      // Giver shell with bottom nav
      ShellRoute(
        builder: (ctx, state, child) => AppShell(role: 'giver', child: child),
        routes: [
          GoRoute(path: giverDashboard, builder: (ctx, state) => const GiverDashboardScreen()),
          GoRoute(path: postFood,       builder: (ctx, state) => const PostFoodScreen()),
          GoRoute(path: giverRequests,  builder: (ctx, state) => const GiverRequestsScreen()),
          GoRoute(path: giverProfile,   builder: (ctx, state) => const ProfileScreen()),
        ],
      ),

      // Taker shell with bottom nav
      ShellRoute(
        builder: (ctx, state, child) => AppShell(role: 'taker', child: child),
        routes: [
          GoRoute(path: takerDashboard, builder: (ctx, state) => const TakerDashboardScreen()),
          GoRoute(path: foodList,       builder: (ctx, state) => const FoodListScreen()),
          GoRoute(
            path: foodDetail,
            builder: (ctx, state) {
              final foodId = state.uri.queryParameters['id'] ?? '';
              return FoodDetailScreen(foodId: foodId);
            },
          ),
          GoRoute(path: takerRequests,  builder: (ctx, state) => const TakerRequestsScreen()),
          GoRoute(path: takerProfile,   builder: (ctx, state) => const ProfileScreen()),
        ],
      ),

      // Review screen using query params for reliability
      GoRoute(
        path: review,
        builder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final title = state.uri.queryParameters['title'];
          final giver = state.uri.queryParameters['giver'];
          return ReviewScreen(requestId: id, foodTitle: title, giverName: giver);
        },
      ),
      GoRoute(path: settings,  builder: (ctx, state) => const SettingsScreen()),
    ],
  );
}
