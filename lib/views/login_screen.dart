import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final SmartHomeController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isAr = widget.controller.isArabic;
    final tr = widget.controller.tr;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.surfaceDark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar with Language Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_tethering, color: AppTheme.accentGreen, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            tr('ppp_system_control'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGlow,
                        backgroundColor: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        setState(() {
                          widget.controller.toggleLanguage();
                        });
                      },
                      icon: const Icon(Icons.language, size: 18),
                      label: Text(
                        tr('lang_switch'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Center Branding & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardDark,
                          border: Border.all(color: AppTheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_max_rounded,
                          size: 56,
                          color: AppTheme.primaryGlow,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr('app_name'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr('app_desc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Login Card Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.borderDark),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tr('auth_required'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tr('auth_desc'),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Google Sign-In Action Button
                      ListenableBuilder(
                        listenable: widget.controller,
                        builder: (context, _) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            onPressed: widget.controller.isAuthLoading
                                ? null
                                : () async {
                                    final nav = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(context);
                                    try {
                                      final success = await widget.controller.signInWithGoogle();
                                      if (success) {
                                        nav.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => DashboardScreen(controller: widget.controller),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isAr
                                                ? 'تعذر تسجيل الدخول بـ Google: يرجى التحقق من الاتصال أو تجربة الحساب التجريبي'
                                                : 'Google Sign-In failed: Check connectivity or try Demo Mode',
                                          ),
                                          backgroundColor: Colors.amber.shade900,
                                          action: SnackBarAction(
                                            label: isAr ? 'دخول تجريبي' : 'Demo Mode',
                                            textColor: Colors.white,
                                            onPressed: () {
                                              widget.controller.loginAsDemoUser();
                                              nav.pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) => DashboardScreen(controller: widget.controller),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: widget.controller.isAuthLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.primary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.g_mobiledata_rounded,
                                        color: Colors.redAccent,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        tr('google_signin'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Direct Demo Mode Button
                      TextButton(
                        onPressed: () {
                          widget.controller.loginAsDemoUser();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => DashboardScreen(controller: widget.controller),
                            ),
                          );
                        },
                        child: Text(
                          isAr ? 'الدخول السريع بالحساب التجريبي' : 'Quick Demo Mode Access',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
