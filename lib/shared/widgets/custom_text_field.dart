import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/shared/providers/locale_provider.dart';

class CustomTextField extends ConsumerWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool showCountryPicker;
  final void Function(CountryCode)? onCountryChanged;
  final CountryCode? initialCountry;
  final TextDirection? textDirection;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.showCountryPicker = false,
    this.onCountryChanged,
    this.textDirection,
    this.initialCountry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection ?? (isArabic ? TextDirection.rtl : TextDirection.ltr),
      obscureText: obscureText,
      obscuringCharacter: '●',
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: showCountryPicker
            ? CountryCodePicker(
          onChanged: onCountryChanged,
          initialSelection: initialCountry?.code ?? 'KSA',
          favorite: const ['+966', 'KSA', '+20', 'EG',],
          showCountryOnly: false,
          alignLeft: false,
          showOnlyCountryWhenClosed: false,
        )
            : prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
