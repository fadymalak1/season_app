import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
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
    this.initialCountry,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
