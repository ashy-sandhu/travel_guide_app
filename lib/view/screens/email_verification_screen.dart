import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
import '../components/custom_app_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  
  const EmailVerificationScreen({
    super.key,
    this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  bool _isVerified = false;
  String? _message;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    // Auto-check every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isVerified) {
        _checkVerificationStatus();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.checkEmailVerification();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _isVerified = isVerified;
      if (isVerified) {
        _message = 'Your email has been verified!';
      } else {
        _message = 'Please check your email and click the verification link.';
      }
    });

    // Auto-navigate to home if verified
    if (isVerified) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _message = null;
    });

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.resendVerificationEmail();
      if (!mounted) return;
      
      setState(() {
        _isResending = false;
        _message = 'Verification email has been resent. Please check your inbox.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isResending = false;
        _errorMessage = authProvider.error ?? 'Failed to resend verification email';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to resend verification email'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _continueToApp() {
    if (_isVerified) {
      context.go('/home');
    }
  }

  String _getUserEmail() {
    final authProvider = context.read<AuthProvider>();
    return widget.email ?? authProvider.user?.email ?? 'your email';
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _getUserEmail();

    return Scaffold(
      appBar: CustomAppBar(title: 'Verify Email'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            // Icon
            Icon(
              _isVerified ? Icons.check_circle : Icons.mark_email_read,
              size: 80,
              color: _isVerified ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              _isVerified ? 'Email Verified!' : 'Verify Your Email',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Message
            Text(
              _isVerified 
                ? 'Your email has been successfully verified. You can now access all features.'
                : 'We\'ve sent a verification email to:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Email address
            if (!_isVerified) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Status message
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isVerified 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isVerified 
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVerified ? Icons.check_circle : Icons.info_outline,
                      color: _isVerified ? AppColors.success : AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _isVerified ? AppColors.success : AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Instructions
            if (!_isVerified) ...[
              Text(
                'Instructions:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              _buildInstruction(
                context,
                '1. Check your email inbox',
                Icons.email_outlined,
              ),
              _buildInstruction(
                context,
                '2. Click the verification link in the email',
                Icons.link,
              ),
              _buildInstruction(
                context,
                '3. Come back here and click "Check Status"',
                Icons.refresh,
              ),
              const SizedBox(height: 24),
            ],
            
            // Check Status button
            if (!_isVerified)
              OutlinedButton.icon(
                onPressed: _isChecking ? null : _checkVerificationStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isChecking ? 'Checking...' : 'Check Verification Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            
            if (!_isVerified) const SizedBox(height: 12),
            
            // Resend Email button
            if (!_isVerified)
              OutlinedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isResending ? 'Sending...' : 'Resend Verification Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            
            if (!_isVerified) const SizedBox(height: 12),
            
            // Continue button
            ElevatedButton(
              onPressed: _isVerified ? _continueToApp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
              ),
              child: const Text(
                'Continue to App',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Back to login
            if (!_isVerified)
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

