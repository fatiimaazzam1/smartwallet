import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/smartwallet_logo.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.screenVertical,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - (AppSpacing.screenVertical * 2),
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),

                          const SmartWalletLogo(size: 92, showName: true),

                          const SizedBox(height: AppSpacing.xxl),

                          const Text(
                            'Take control of your money.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.screenTitle,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          const Text(
                            'Track your spending, plan ahead, and understand '
                            'what is safe to spend.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),

                          const Spacer(),

                          AppButton(
                            label: 'Get Started',
                            onPressed: onGetStarted,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.xs,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: AppTextStyles.body,
                              ),
                              TextButton(
                                onPressed: onLogin,
                                child: const Text('Log in'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
