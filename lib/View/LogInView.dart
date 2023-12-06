import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:async/async.dart';
import 'package:quickalert/models/quickalert_type.dart';
import '../Controller/LogInController.dart';
import '../Utilities/AppConstants.dart';
import '../Widgets/Custom Exit Widget.dart';
import '../Widgets/Custom Form Field.dart';
import '../Widgets/Dialogs.dart';

// // ignore: must_be_immutable
// class LogInView extends GetView<LogInController> {
//   LogInView({Key? key}) : super(key: key);
//   CancelableOperation? _operation;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppConstants.themeBackgroundColor,
//         appBar: null,
//         body: Obx(()=>controller.isDataLoading.value?
//         const Center(child: CircularProgressIndicator(),):
//         SingleChildScrollView(
//           child: Form(
//               key: controller.logInFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.only(top:AppConstants.appTopPadding,right:AppConstants.appTopPadding,left:AppConstants.appTopPadding),
//                     child: Center(
//                       child: SizedBox(
//                           width: AppConstants.appWidth*.75,
//                           height: AppConstants.appHeight*.25,
//                           child: Image.asset(AppConstants.logoImageURL,color: AppConstants.themeSecondaryColor,)),
//                     ),
//                   ),
//                   CustomFormField(
//                     headingText: "Email",
//                     hintText: "Enter Email here",
//                     obscureText: false,
//                     suffixIcon: const SizedBox(),
//                     controller: controller.emailController,
//                     onSaved: (value){controller.email = value!;},
//                     validator: (value){
//                       return controller.emailValidator(value!);
//                     },
//                     maxLines: 1,
//                     textInputAction: TextInputAction.done,
//                     textInputType: TextInputType.emailAddress,
//                   ),
//                   Obx(()=> CustomFormField(
//                     headingText: "Password",
//                     maxLines: 1,
//                     textInputAction: TextInputAction.done,
//                     textInputType: TextInputType.text,
//                     hintText: "Password should be atleast 8 Character",
//                     controller: controller.passwordController,
//                     onSaved: (value){controller.password = value!;},
//                     validator: (value){
//                       return controller.passwordValidator(value!);
//                     },
//                     obscureText: controller.isPasswordHidden.value,
//                     suffixIcon: IconButton(
//                         icon: const Icon(Icons.visibility),
//                         onPressed: (){controller.isPasswordHidden.value=!controller.isPasswordHidden.value;}),
//                   )),
//                   Padding(
//                     padding: EdgeInsets.only(top: AppConstants.appMiddlePadding,left: AppConstants.appSidePadding,right: AppConstants.appSidePadding),
//                     child: Container(
//                       width: AppConstants.appWidth*.50,
//                       height: AppConstants.appHeight*.10,
//                       decoration: BoxDecoration(
//                           color: AppConstants.themeMainColor, borderRadius: BorderRadius.circular(10)),
//                       child: MaterialButton(
//                         onPressed: ()
//                         {
//                           _authOperation(controller.onLogin());
//                         },
//                         child: Text(
//                           'Log In',
//                           style: AppConstants.h22,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//           ),
//         ),
//         ));
//   }
//
//   Future<String?> _authOperation(Future<String?> func) async {
//     _operation = CancelableOperation.fromFuture(func);
//     final String? result = await _operation?.valueOrCancellation();
//     if (kDebugMode) {
//       print("Print Result: $result");
//     }
//     if (result == "Failed")
//     {
//       DialogBuilder(Get.context!).showResultDialog(result ?? '$result.',QuickAlertType.error);
//     }
//     else if (result == "Successful")
//     {
//       if (_operation?.isCompleted == true)
//       {
//         await Get.offAllNamed("/bnb");
//       }
//     }
//     return result;
//   }
// }

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final LogInController controller = Get.find();
  CancelableOperation? _operation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppConstants.themeBackgroundColor,
        appBar: null,
        body: Obx(()=>controller.isDataLoading.value?
        const Center(child: CircularProgressIndicator(),):
        SingleChildScrollView(
          child: Form(
              key: controller.logInFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top:AppConstants.appTopPadding,right:AppConstants.appTopPadding,left:AppConstants.appTopPadding),
                    child: Center(
                      child: SizedBox(
                          width: AppConstants.appWidth*.75,
                          height: AppConstants.appHeight*.25,
                          child: Image.asset(AppConstants.logoImageURL,color: AppConstants.themeSecondaryColor,)),
                    ),
                  ),
                  CustomFormField(
                    headingText: "Email",
                    hintText: "Enter Email here",
                    obscureText: false,
                    suffixIcon: const SizedBox(),
                    controller: controller.emailController,
                    onSaved: (value){controller.email = value!;},
                    validator: (value){
                      return controller.emailValidator(value!);
                    },
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.emailAddress,
                  ),
                  Obx(()=> CustomFormField(
                    headingText: "Password",
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.text,
                    hintText: "Password should be atleast 8 Character",
                    controller: controller.passwordController,
                    onSaved: (value){controller.password = value!;},
                    validator: (value){
                      return controller.passwordValidator(value!);
                    },
                    obscureText: controller.isPasswordHidden.value,
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: (){controller.isPasswordHidden.value=!controller.isPasswordHidden.value;}),
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: AppConstants.appMiddlePadding,left: AppConstants.appSidePadding,right: AppConstants.appSidePadding),
                    child: Container(
                      width: AppConstants.appWidth*.50,
                      height: AppConstants.appHeight*.10,
                      decoration: BoxDecoration(
                          color: AppConstants.themeMainColor, borderRadius: BorderRadius.circular(10)),
                      child: MaterialButton(
                        onPressed: ()
                        {
                          _authOperation(controller.onLogin());
                        },
                        child: Text(
                          'Log In',
                          style: AppConstants.h22,
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
        ));
  }
  Future<String?> _authOperation(Future<String?> func) async {
    _operation = CancelableOperation.fromFuture(func);
    final String? result = await _operation?.valueOrCancellation();
    if (kDebugMode) {
      print("Print Result: $result");
    }
    if (result == "Failed")
    {
      DialogBuilder(Get.context!).showResultDialog(result ?? '$result.',QuickAlertType.error);
    }
    else if (result == "Successful")
    {
      if (_operation?.isCompleted == true)
      {
        await Get.offAllNamed("/bnb");
      }
    }
    return result;
  }
}
