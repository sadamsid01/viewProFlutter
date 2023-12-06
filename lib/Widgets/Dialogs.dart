import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:view_pro/Utilities/AppConstants.dart';

class DialogBuilder {
  /// Builds various dialogs with different methods.
  /// * e.g. [showLoadingDialog], [showResultDialog]
  const DialogBuilder(this.context);

  /// Takes [context] as parameter.
  final BuildContext context;

  /// Example loading dialog
  Future<void> showLoadingDialog() => QuickAlert.show(
    context: context,
    type: QuickAlertType.loading,
    title: 'Loading',
    text: 'Fetching your data',
  );

  /// Example result dialog
  Future<void> showResultDialog(String text, QuickAlertType quickAlertType) => QuickAlert.show(
    context: context,
    type: quickAlertType,
    text: 'Log In $text!',
    autoCloseDuration: const Duration(seconds: 5),
  );

  Future<void> inputDialog(IconData icon,String title,String text) => QuickAlert.show(

    context: context,
    backgroundColor: AppConstants.themeBackgroundColor,
    confirmBtnColor: AppConstants.themeMainColor,
    type: QuickAlertType.custom,
    barrierDismissible: true,
    confirmBtnText: 'Save',
    showCancelBtn: true,
    widget: TextFormField(
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: 'Enter $title',
        hintStyle: AppConstants.h3,
        prefixIcon: Icon(icon,color: AppConstants.themeMainColor,),
      ),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      onChanged: (value) => text = value,
    ),
    onConfirmBtnTap: () async {
      if (text.length < 3) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Please input something',
        );
        return;
      }
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "Name: '$text' has been saved!.",
      );
    },
  );
}