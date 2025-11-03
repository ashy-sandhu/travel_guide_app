import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Navigate to home after animation completes (3 seconds) or minimum delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed('home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation with error handling
              SizedBox(
                width: 300,
                height: 300,
                child: _hasError
                    ? const Icon(
                        Icons.travel_explore,
                        size: 150,
                        color: AppColors.textOnPrimary,
                      )
                    : Lottie.asset(
                        'assets/animations/splash_screen.json',
                        fit: BoxFit.contain,
                        repeat: false,
                        animate: true,
                        width: 300,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) {
                          // Log error for debugging
                          debugPrint('=== LOTTIE ANIMATION ERROR ===');
                          debugPrint('Error: $error');
                          debugPrint('Stack trace: $stackTrace');
                          debugPrint('Asset path: assets/animations/splash_screen.json');
                          debugPrint('===============================');
                          
                          // Set error flag on next frame
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _hasError = true;
                              });
                            }
                          });
                          // Return fallback icon
                          return const Icon(
                            Icons.travel_explore,
                            size: 150,
                            color: AppColors.textOnPrimary,
                          );
                        },
                        frameBuilder: (context, child, frame) {
                          if (frame == null) {
                            // Animation is still loading
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textOnPrimary,
                                ),
                              ),
                            );
                          }
                          return child ?? const SizedBox();
                        },
                      ),
              ),
              const SizedBox(height: 40),
              // App Name
              const Text(
                'Travel Guide',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover amazing places',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
