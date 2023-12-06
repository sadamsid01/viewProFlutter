// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../Controller/HomeController.dart';
import '../Model/NoteModel.dart';
import '../Utilities/AppConstants.dart';

class HomeView extends GetView<HomeController> {
  final storage = const FlutterSecureStorage();
  HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.themeBackgroundColor,
      appBar: null,
      body: SingleChildScrollView(
        child: Obx(
              () {
            return (controller.loadingData!.isTrue)
                ? Container(
              width: AppConstants.appWidth,
              height: AppConstants.appHeight,
              color: Colors.transparent,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Image at the start
                  Padding(
                    padding: EdgeInsets.all(AppConstants.appRadius),
                    child: Center(
                      child: SizedBox(
                        width: Get.width*.75,
                        height: Get.height*.175,
                        child: Image.asset(
                          'assets/logo/logo.png',
                          fit: BoxFit.contain,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Three text widgets
                  Padding(
                    padding: EdgeInsets.all(AppConstants.appRadius),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(' + Screen Share',style: AppConstants.h3,),
                        Text(' + Realtime Suggestions',style: AppConstants.h3,),
                        Text(' + Live Chat',style: AppConstants.h3,),
                      ],
                    ),
                  ),
                  //notes code
                  // Padding(
                  //     padding: EdgeInsets.all(AppConstants.appRadius),
                  //     child: Text('My Notes',style: AppConstants.h2,),
                  //   ),
                  // Expanded(
                  //   child: (controller.notes.isEmpty)
                  //       ? Container(
                  //         color: Colors.white24,
                  //         child: Center(
                  //         child: Text(
                  //         "No Notes found.",
                  //         style: AppConstants.h2,
                  //     ),
                  //   ),
                  //       )
                  //       : ListView.builder(
                  //     padding: EdgeInsets.all(AppConstants.appRadius),
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     itemCount: controller.notes.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       Note note = controller.notes[index];
                  //       return ListTile(
                  //         title: Text(note.title),
                  //         subtitle: Text(note.description),
                  //         onTap: () async {
                  //           var result = await Get.dialog(
                  //             AlertDialog(
                  //               title: Text(note.title),
                  //               content: Text(note.description),
                  //               actions: [
                  //                 TextButton(
                  //                   onPressed: () {
                  //                     Get.back(result: "edit");
                  //                   },
                  //                   child: const Text("Edit"),
                  //                 ),
                  //                 TextButton(
                  //                   onPressed: () {
                  //                     Get.back(result: "delete");
                  //                   },
                  //                   child: const Text("Delete"),
                  //                 ),
                  //                 TextButton(
                  //                   onPressed: () {
                  //                     Get.back(result: "cancel");
                  //                   },
                  //                   child: const Text("Cancel"),
                  //                 ),
                  //               ],
                  //             ),
                  //           );
                  //           if (result == "delete") {
                  //             controller.deleteNoteById(note.id!);
                  //           } else if (result == "edit") {
                  //             showEditDialog(note);
                  //           }
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
              ],
            ),
                );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showAddDialog();
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  void showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Add a note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Description",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                Note note = Note(
                  id: 0,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                await controller.addNote(note);
                Get.back();
              } else {
                Get.snackbar(
                  "Error",
                  "Title and description cannot be empty.",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Note thisNote) {
    TextEditingController titleController = TextEditingController(text: thisNote.title);
    TextEditingController descriptionController = TextEditingController(text: thisNote.description);
    Get.dialog(
      AlertDialog(
        title: const Text("Edit a note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Description",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                Note note = Note(
                  id: thisNote.id,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                await controller.updateNoteById(note);
                Get.back();
              } else {
                Get.snackbar(
                  "Error",
                  "Title and description cannot be empty.",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}