import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../widgets/app_shell.dart';


class AppRouter {
  static GoRouter get router => GoRouter(
        initialLocation: '/login',
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final isAuth = authState is AuthAuthenticated;
          final isOnAuth = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';

          if (!isAuth && !isOnAuth) return '/login';
          if (isAuth && isOnAuth) return '/dashboard';
          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterPage(),
          ),
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardPage(),
              ),
              GoRoute(
                path: '/transactions',
                builder: (context, state) {
                  final userId = (context.read<AuthBloc>().state
                          as AuthAuthenticated)
                      .user
                      .id;
                  return TransactionsPage(userId: userId);
                },
              ),
              GoRoute(
                path: '/budgets',
                builder: (_, __) => const BudgetsPage(),
              ),
              GoRoute(
                path: '/reports',
                builder: (_, __) => const ReportsPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/transactions/add',
            builder: (context, state) {
              final userId = state.extra as String;
              return AddTransactionPage(userId: userId);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      );
}
