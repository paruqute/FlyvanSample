import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/colors.dart';
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.textFieldController,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onTap,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.initialValue,
  });
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final TextEditingController textFieldController;
  final void Function()? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
final List<TextInputFormatter>? inputFormatters;
final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
    //  focusNode: ,
      onTapOutside: (event) => FocusScope.of(context).unfocus,
      initialValue: initialValue,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required';
        }
        return null;
      },
      readOnly: readOnly,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: primaryColor),
      // cursorHeight: 20,
      // autofocus: true,
       onTap: onTap,

      controller: textFieldController,

      decoration: InputDecoration(
        //enabled: true,
        hintText:hintText,
        labelText: labelText,
        helperText: helperText,

        labelStyle: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color:primaryColorOpacity),
        // contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.zero),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.3), // Color when focused
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.3), // Default border color
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
