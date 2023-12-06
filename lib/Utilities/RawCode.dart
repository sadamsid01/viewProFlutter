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