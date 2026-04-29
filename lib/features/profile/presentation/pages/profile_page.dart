import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox();
          final user = state.user;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: context.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(user.email, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                label: 'Security',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,
                  side: const BorderSide(color: AppColors.expense),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: context.textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
