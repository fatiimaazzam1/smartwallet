import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SmartWalletLogo extends StatelessWidget {
  const SmartWalletLogo({this.size = 72, this.showName = false, super.key});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SmartWallet',
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(size * 0.24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: size * 0.52,
                  color: AppColors.surface,
                ),
                Positioned(
                  right: size * 0.18,
                  top: size * 0.22,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.16,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 12),
            const Text(
              'SmartWallet',
              style: AppTextStyles.brandTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
