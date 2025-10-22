import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/core/constants/app_assets.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/localization/generated/l10n.dart';
import 'package:season_app/core/router/routes.dart';
import 'package:season_app/core/utils/validators.dart';
import 'package:season_app/features/auth/presentation/widgets/agreement_policy.dart';
import 'package:season_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:season_app/features/auth/presentation/widgets/social_icons.dart';
import 'package:season_app/features/auth/providers.dart';
import 'package:season_app/shared/helpers/snackbar_helper.dart';
import 'package:season_app/shared/providers/locale_provider.dart';
import 'package:season_app/shared/widgets/custom_button.dart';
import 'package:season_app/shared/widgets/custom_text_field.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final _formKey = GlobalKey<FormState>();
    final firstNameController = ref.watch(firstNameControllerProvider);
    final lastNameController = ref.watch(lastNameControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final phoneController = ref.watch(phoneControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final confirmPasswordController = ref.watch(confirmPasswordControllerProvider);
    final signupState = ref.watch(signupControllerProvider);
    final signupNotifier = ref.read(signupControllerProvider.notifier);
    CountryCode selectedCode = CountryCode.fromDialCode('+966'); // الافتراضي مصر

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(AppAssets.seasonAuthImage, height: 80),
                  const SizedBox(height: 10),
                  Text(
                    tr.signUp,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Name
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                hintText: tr.firstName,
                                controller: firstNameController,
                                onChanged: (val) => ref.read(firstNameProvider.notifier).state = val,
                                validator: (value) => Validators.notEmpty(value, isArabic: isArabic),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                hintText: tr.lastName,
                                controller:lastNameController,
                                onChanged: (val) => ref.read(lastNameProvider.notifier).state = val,
                                validator: (value) => Validators.notEmpty(value, isArabic: isArabic),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        // Email
                        CustomTextField(
                          hintText: tr.email,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) => ref.read(emailProvider.notifier).state = val,
                          validator: (value) => Validators.email(value, isArabic: isArabic),
                          controller: emailController,
                        ),
                        const SizedBox(height: 10),
                        // Phone
                        CustomTextField(
                          hintText: tr.phone,
                          keyboardType: TextInputType.phone,
                          showCountryPicker: true,
                          initialCountry: selectedCode,
                          onCountryChanged: (code) {
                            selectedCode = code;
                          },
                          onChanged: (val) {
                            final fullNumber = '${selectedCode.dialCode}$val';
                            ref.read(phoneProvider.notifier).state = fullNumber;
                          },
                          validator: (value) =>
                              Validators.phone(value, isArabic: isArabic),
                          controller: phoneController,
                        ),
                        const SizedBox(height: 10),
                        // Password
                        CustomTextField(
                          hintText: tr.password,
                          obscureText: ref.watch(passwordVisibilityProvider),
                          suffixIcon: IconButton(
                            icon: Icon(ref.watch(passwordVisibilityProvider)
                                ? Icons.remove_red_eye
                                : Icons.visibility_off),
                            onPressed: () {
                              ref.read(passwordVisibilityProvider.notifier).state =
                              !ref.read(passwordVisibilityProvider.notifier).state;
                            },
                          ),
                          onChanged: (val) => ref.read(passwordProvider.notifier).state = val,
                          validator: (value) => Validators.password(value, isArabic: isArabic),
                          controller: passwordController
                        ),
                        const SizedBox(height: 10),
                        // Confirm Password
                        CustomTextField(
                          hintText: tr.confirmPassword,
                          obscureText: ref.watch(confirmPasswordVisibilityProvider),
                          suffixIcon: IconButton(
                            icon: Icon(ref.watch(confirmPasswordVisibilityProvider)
                                ? Icons.remove_red_eye
                                : Icons.visibility_off),
                            onPressed: () {
                              ref.read(confirmPasswordVisibilityProvider.notifier).state =
                              !ref.read(confirmPasswordVisibilityProvider.notifier).state;
                            },
                          ),
                          onChanged: (val) => ref.read(confirmPasswordProvider.notifier).state = val,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isArabic ? 'تأكيد كلمة المرور مطلوب' : 'Confirm password is required';
                            }
                            if (value != ref.watch(passwordProvider)) {
                              return isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
                            }
                            return null;
                          },
                          controller: confirmPasswordController
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          isLoading:signupState.isLoading ,
                          text: tr.signUp,
                          color: AppColors.primary,
                          onPressed: signupState.isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              await signupNotifier.register(
                                firstName: ref.watch(firstNameProvider),
                                lastName: ref.watch(lastNameProvider),
                                email: ref.watch(emailProvider),
                                phone: ref.watch(phoneProvider),
                                password: ref.watch(passwordProvider),
                                passwordConfirmation: ref.watch(confirmPasswordProvider),
                              );

                              if (signupState.error != null) {
                                SnackbarHelper.error(context, signupState.error.toString());
                              } else if (signupState.message != null) {
                                SnackbarHelper.success(context, signupState.message.toString());
                                context.push(Routes.verifyOtp);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        OrDivider(tr: tr),
                        const SizedBox(height: 20),
                        SocialIcons(),
                        const SizedBox(height: 20),
                        AgreementPolicy(isArabic: isArabic),
                        const SizedBox(height: 20),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tr.alreadyHaveAccount,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                context.go(Routes.login);
                              },
                              child: Text(
                                tr.login,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

