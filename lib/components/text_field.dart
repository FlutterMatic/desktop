import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String?)? validator;
  final FilteringTextInputFormatter? filteringTextInputFormatter;
  final bool autoFocus;
  final int? maxLength;

  CustomTextField({
    required this.hintText,
    this.filteringTextInputFormatter,
    this.maxLength,
    this.onChanged,
    this.autoFocus = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(hintText: hintText),
      maxLength: maxLength,
      autofocus: autoFocus,
      validator:
          validator == null ? null : validator as String? Function(String?)?,
      inputFormatters: [
        filteringTextInputFormatter ??
            FilteringTextInputFormatter.deny(RegExp(''))
      ],
      onChanged: onChanged,
    );
  }
}
