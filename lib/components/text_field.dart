import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_installer/utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final Function(String?)? validator;
  // final Function(String?)? onChanged;
  final ValueChanged<String> onChanged;
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
    required this.onChanged,
    required this.controller,
    this.suffixIcon,
    this.onSuffixIcon,
    this.iconColor,
    this.numLines,
    this.obscureText = false,
    this.keyboardtype,
    this.textInputAction,
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
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool wasNotEdited = true;
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Container(
      width: widget.width,
      child: TextFormField(
        scrollPhysics: const BouncingScrollPhysics(),
        cursorRadius: const Radius.circular(10),
        focusNode: widget.focusNode,
        textInputAction: widget.textInputAction,
        textCapitalization:
            widget.textCapitalization ?? TextCapitalization.none,
        readOnly: widget.readOnly,
        onEditingComplete: widget.onEditCompleted as void Function()?,
        initialValue: widget.initialValue,
        autofocus: widget.autofocus ?? false,
        keyboardType: widget.keyboardtype ?? TextInputType.text,
        obscureText: widget.obscureText,
        maxLines: widget.numLines ?? 1,
        style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
        inputFormatters: [
          widget.filteringTextInputFormatter ??
              FilteringTextInputFormatter.deny(RegExp(''))
        ],
        decoration: InputDecoration(
          errorStyle: const TextStyle(color: kRedColor),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
          fillColor: Colors.blueGrey.withOpacity(0.2),
          filled: true,
          hintText: widget.hintText,
          counterStyle: TextStyle(
            color: customTheme.textTheme.bodyText1!.color!.withOpacity(0.75),
          ),
          hintStyle: TextStyle(
              color: customTheme.textTheme.bodyText1!.color!.withOpacity(0.75),
              fontSize: 15),
        ),
        textAlignVertical: TextAlignVertical.center,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        validator: widget.validator == null
            ? null
            : widget.validator as String? Function(String?)?,
        keyboardAppearance: Brightness.dark,
        onChanged: (String _input) {
          widget.onChanged(_input);

          if (wasNotEdited) {
            setState(() {
              wasNotEdited = false;
            });
          }
        },

        // onChanged: onChanged,
        controller: widget.controller,
      ),
    );
  }
}
