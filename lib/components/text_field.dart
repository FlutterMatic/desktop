import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final FilteringTextInputFormatter? filteringTextInputFormatter;
  final int? numLines;
  final int? maxLength;
  final dynamic suffixIcon;
  final Function? onSuffixIcon;
  final Color? iconColor;
  final bool obscureText;
  final TextInputType? keyboardtype;
  final Color? color;
  final Function? onEditCompleted;
  final TextEditingController? controller;
  final String? initialValue;
  final bool? autofocus;
  final double? width;
  final bool readOnly;
  final TextCapitalization? textCapitalization;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  CustomTextField({
    this.filteringTextInputFormatter,
    this.validator,
    this.initialValue,
    this.autofocus,
    this.onChanged,
    this.suffixIcon,
    this.onSuffixIcon,
    this.iconColor,
    this.numLines,
    this.obscureText = false,
    this.keyboardtype,
    this.textInputAction,
    this.controller,
    this.maxLength,
    this.color,
    this.hintText,
    this.focusNode,
    this.width,
    this.onEditCompleted,
    this.readOnly = false,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Container(
      width: width,
      child: TextFormField(
        scrollPhysics: const BouncingScrollPhysics(),
        cursorRadius: const Radius.circular(10),
        focusNode: focusNode,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        readOnly: readOnly,
        onEditingComplete: onEditCompleted as void Function()?,
        initialValue: initialValue,
        autofocus: autofocus ?? false,
        keyboardType: keyboardtype ?? TextInputType.text,
        obscureText: obscureText,
        maxLines: numLines ?? 1,
        style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
        inputFormatters: [
          filteringTextInputFormatter ??
              FilteringTextInputFormatter.deny(RegExp(''))
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5)),
          fillColor: Colors.blueGrey.withOpacity(0.2),
          filled: true,
          hintText: hintText,
          counterStyle: TextStyle(
            color: customTheme.textTheme.bodyText1!.color!.withOpacity(0.75),
          ),
          hintStyle: TextStyle(
              color: customTheme.textTheme.bodyText1!.color!.withOpacity(0.75),
              fontSize: 15),
        ),
        textAlignVertical: TextAlignVertical.center,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        validator:
            validator == null ? null : validator as String? Function(String?)?,
        keyboardAppearance: Brightness.dark,
        onChanged: onChanged,
        controller: controller,
      ),
    );
  }
}
