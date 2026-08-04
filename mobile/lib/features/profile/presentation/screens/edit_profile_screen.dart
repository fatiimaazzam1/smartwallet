import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/user_profile_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_load_failure.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<ProfileController>().profile == null) {
        context.read<ProfileController>().load();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final UserProfileModel? profile = context.read<ProfileController>().profile;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final ProfileController controller = context.read<ProfileController>();
    final bool success = await controller.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (!mounted || !success) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );

    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProfileController controller = context.watch<ProfileController>();
    final UserProfileModel? profile = controller.profile;

    if (!_initialized && profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.isSavingProfile ? null : widget.onBack,
          tooltip: l10n.goBack,
          icon: const BackButtonIcon(),
        ),
        title: Text(l10n.editProfile),
      ),
      body: SafeArea(
        child: profile == null
            ? controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ProfileLoadFailure(
                      message: l10n.profileLoadError,
                      error: controller.error,
                      onRetry: () => controller.load(force: true),
                    )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.editProfileSubtitle,
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: l10n.firstName,
                            hintText: l10n.firstNameHint,
                            controller: _firstNameController,
                            enabled: !controller.isSavingProfile,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (String? value) => FormValidators.name(
                              value,
                              fieldName: l10n.firstName,
                              l10n: l10n,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.fieldGap),
                          AppTextField(
                            label: l10n.lastName,
                            hintText: l10n.lastNameHint,
                            controller: _lastNameController,
                            enabled: !controller.isSavingProfile,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _save(),
                            validator: (String? value) => FormValidators.name(
                              value,
                              fieldName: l10n.lastName,
                              l10n: l10n,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.fieldGap),
                          Text(l10n.emailAddress, style: AppTextStyles.fieldLabel),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            initialValue: profile.email,
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.emailCannotChange,
                            style: AppTextStyles.helperText,
                          ),
                          if (controller.error != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            AppStatusMessage(
                              message: LocalizedErrorMessage.fromException(
                                context,
                                controller.error,
                              ),
                              isError: true,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: l10n.save,
                            isLoading: controller.isSavingProfile,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
