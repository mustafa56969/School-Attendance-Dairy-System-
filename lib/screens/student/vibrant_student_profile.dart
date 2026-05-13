import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../theme/playful_theme.dart';

class VibrantStudentProfile extends StatelessWidget {
  const VibrantStudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PlayfulTheme.primaryTeal.withOpacity(0.15),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        PlayfulTheme.primaryTeal,
                        PlayfulTheme.primaryPink,
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).cardColor,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: Text(
                        (user.name?.isNotEmpty ?? false)
                            ? user.name![0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: PlayfulTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(curve: Curves.elasticOut),
                const SizedBox(height: 20),

                // User Name
                Text(
                  (user.name != null && user.name!.length > 25)
                      ? '${user.name!.substring(0, 25)}...'
                      : (user.name ?? 'Student'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 6),

                // User Email
                Text(
                  (user.email != null && user.email!.length > 30)
                      ? '${user.email!.substring(0, 30)}...'
                      : (user.email ?? 'No email provided'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),

                // User Class
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PlayfulTheme.primaryTeal.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Class ${user.classId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PlayfulTheme.primaryTeal,
                    ),
                  ),
                ).animate(delay: 300.ms).scale(),
              ],
            ),
          ),
        ),

        // Profile Details Section
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Profile Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Profile Details Cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final items = [
                {
                  'icon': Icons.person_outline,
                  'title': 'Full Name',
                  'value': user.name ?? 'Not provided',
                  'color': PlayfulTheme.primaryTeal,
                },
                {
                  'icon': Icons.email_outlined,
                  'title': 'Email Address',
                  'value': user.email ?? 'Not provided',
                  'color': PlayfulTheme.primaryPink,
                },
                {
                  'icon': Icons.class_outlined,
                  'title': 'Class',
                  'value': user.classId ?? 'Not assigned',
                  'color': PlayfulTheme.primaryOrange,
                },
                {
                  'icon': Icons.school_outlined,
                  'title': 'Role',
                  'value': (user.role ?? 'student').capitalize(),
                  'color': PlayfulTheme.accentPurple,
                },
              ];

              if (index >= items.length) return null;

              final item = items[index];
              return _buildProfileCard(
                context: context,
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                value: item['value'] as String,
                color: item['color'] as Color,
                index: index,
              );
            }, childCount: 4),
          ),
        ),

        // Interface Settings
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'Interface Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return _buildActionCard(
                  context: context,
                  icon: themeService.themeMode == ThemeMode.system 
                    ? Icons.brightness_auto 
                    : (themeService.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  title: 'Theme Mode',
                  subtitle: themeService.themeMode == ThemeMode.system 
                    ? 'System Default' 
                    : (themeService.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                  color: PlayfulTheme.primaryTeal,
                  onTap: () => _showThemeDialog(context, themeService),
                  index: 0,
                );
              },
            ),
          ),
        ),

        // Account Actions
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'Account Actions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Action Buttons
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final actions = [
                {
                  'icon': Icons.logout,
                  'title': 'Logout',
                  'subtitle': 'Sign out of your account',
                  'color': Colors.red,
                  'onTap': () => _showLogoutDialog(context, authService),
                },
                {
                  'icon': Icons.help_outline,
                  'title': 'Help & Support',
                  'subtitle': 'Get help with using the app',
                  'color': PlayfulTheme.primaryOrange,
                  'onTap': () => _showHelpDialog(context),
                },
              ];

              if (index >= actions.length) return null;

              final action = actions[index];
              return _buildActionCard(
                context: context,
                icon: action['icon'] as IconData,
                title: action['title'] as String,
                subtitle: action['subtitle'] as String,
                color: action['color'] as Color,
                onTap: action['onTap'] as VoidCallback,
                index: index,
              );
            }, childCount: 2),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int index,
  }) {
    // Limit value length to prevent overflow
    final displayValue = value.length > 25
        ? '${value.substring(0, 25)}...'
        : value;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 300.ms)
        .moveX(begin: -0.2, end: 0);
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
                color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            onTap: onTap,
          ),
        )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 300.ms)
        .moveX(begin: -0.2, end: 0);
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Logout',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Help & Support',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'For help with using the app, please contact your teacher or school administrator.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Select Theme',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              'Light Mode',
              Icons.light_mode,
              ThemeMode.light,
              themeService,
            ),
            _buildThemeOption(
              context,
              'Dark Mode',
              Icons.dark_mode,
              ThemeMode.dark,
              themeService,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeService themeService,
  ) {
    final isSelected = themeService.themeMode == mode;
    final Color iconColor = isSelected ? PlayfulTheme.primaryTeal : (Theme.of(context).textTheme.bodySmall?.color ?? PlayfulTheme.textSecondary);
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? PlayfulTheme.primaryTeal : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: PlayfulTheme.primaryTeal) : null,
      onTap: () {
        themeService.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
