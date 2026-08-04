import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.isPassword = false,
    this.enabled = true,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isPassword;
  final bool enabled;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isTextHidden;

  @override
  void initState() {
    super.initState();
    _isTextHidden = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPassword != widget.isPassword) {
      _isTextHidden = widget.isPassword;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isTextHidden = !_isTextHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          obscureText: widget.isPassword && _isTextHidden,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          textCapitalization: widget.textCapitalization,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _isTextHidden
                        ? context.l10n.showPassword
                        : context.l10n.hidePassword,
                    onPressed: widget.enabled
                        ? _togglePasswordVisibility
                        : null,
                    icon: Icon(
                      _isTextHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
