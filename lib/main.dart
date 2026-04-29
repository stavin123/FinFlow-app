import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FinFlowApp());
}

class FinFlowApp extends StatelessWidget {
  const FinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>(),
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          // Listen for auth state to load transactions when authenticated
          return BlocListener<AuthBloc, AuthState>(
            listener: (ctx, state) {
              if (state is AuthAuthenticated) {
                ctx.read<TransactionBloc>().add(
                      TransactionLoadRequested(state.user.id),
                    );
              }
            },
            child: MaterialApp.router(
              title: 'FinFlow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
