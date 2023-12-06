// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../Utilities/AppConstants.dart';

class CustomFormField extends StatelessWidget {
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final String headingText;
  final String hintText;
  final bool obscureText;
  final Widget suffixIcon;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final int maxLines;

  const CustomFormField(
      {Key? key,
      required this.validator,
      required this.onSaved,
      required this.headingText,
      required this.hintText,
      required this.obscureText,
      required this.suffixIcon,
      required this.textInputType,
      required this.textInputAction,
      required this.controller,
      required this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(AppConstants.appPadding),
          child: Text(
            headingText,
            style: AppConstants.h2,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.appHeight*.025),
          child: TextFormField(
            onSaved: onSaved,
            validator: validator,
            cursorColor: AppConstants.themeSecondaryColor,
            maxLines: maxLines,
            textAlign: TextAlign.left,
            controller: controller,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            style: AppConstants.h3,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppConstants.h3,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.appRadius),
                borderSide: const BorderSide(
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.appRadius),
              fillColor: AppConstants.themeBackgroundColor.withOpacity(.05),
            ),
          ),
        ),
      ],
    );
  }
}
