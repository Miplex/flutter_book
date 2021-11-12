import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show NotesModel, notesModel;


class NotesEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  //key for form

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  NotesEntry({Key? key}) : super(key: key){
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  @override
  Widget build(BuildContext inContext) {



    // Set value of controllers.
    if (notesModel.entityBeingEdited != null) {
      _titleEditingController.text = notesModel.entityBeingEdited.title;
      _contentEditingController.text = notesModel.entityBeingEdited.content;
    }

    // Return widget.
    return ScopedModel(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget inChild, NotesModel inModel) {
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : const EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(
                                child : const Text("Cancel"),
                                onPressed : () {
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            const Spacer(),
                           TextButton(
                                child : const Text("Save"),
                                onPressed : () { _save(inContext, notesModel); }
                            )
                          ]
                      )
                  ),
                  body : Form(
                      key : _formkey,
                      child : ListView(
                          children : [
                            // Title.
                            ListTile(
                                leading : const Icon(Icons.title),
                                title : TextFormField(
                                    decoration : const InputDecoration(hintText : "Title"),
                                    controller : _titleEditingController,
                                    validator : (String? inValue) {
                                      if (inValue!.length == 0) { return "Please enter a title"; }
                                      return null;
                                    }
                                )
                            ),
                            // Content.
                            ListTile(
                                leading : const Icon(Icons.content_paste),
                                title : TextFormField(
                                    keyboardType : TextInputType.multiline, maxLines : 8,
                                    decoration : const InputDecoration(hintText : "Content"),
                                    controller : _contentEditingController,
                                    validator : (String? inValue) {
                                      if (inValue!.length == 0) { return "Please enter content"; }
                                      return null;
                                    }
                                )
                            ),
                            // Note color.
                            ListTile(
                                leading : const Icon(Icons.color_lens),
                                title : Row(
                                    children : [
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.red, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "red" ? Colors.red : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "red";
                                            notesModel.setColor("red");
                                          }
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.green, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "green" ? Colors.green : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "green";
                                            notesModel.setColor("green");
                                          }
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.blue, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "blue" ? Colors.blue : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "blue";
                                            notesModel.setColor("blue");
                                          }
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.yellow, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "yellow" ? Colors.yellow : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "yellow";
                                            notesModel.setColor("yellow");
                                          }
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.grey, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "grey" ? Colors.grey : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "grey";
                                            notesModel.setColor("grey");
                                          }
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.purple, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.color == "purple" ? Colors.purple : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "purple";
                                            notesModel.setColor("purple");
                                          }
                                      )
                                    ]
                                )
                            )
                          ] /* End Column children. */
                      ) /* End ListView. */
                  ) /* End Form. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, NotesModel inModel) async {



    // Abort if form isn't valid.
    if (!_formkey.currentState!.validate()) { return; }

    // Creating a new note.
    if (inModel.entityBeingEdited.id == 0) {


      await NotesDBWorker.db.create(notesModel.entityBeingEdited);

      // Updating an existing note.
    } else {

      print("## NotesEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);

    }

    // Reload data from database to update list.
    notesModel.loadData("notes", NotesDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Note saved")
        )
    );

  } /* End _save(). */

}
