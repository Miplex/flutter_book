import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show Note, NotesModel, notesModel;


/// ****************************************************************************
/// The Notes List sub-screen.
/// ****************************************************************************

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext context) {

    // Return widget.
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext inContext, Widget inChild, NotesModel inModel){
            return  Scaffold(
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add, color: Colors.white,),
                onPressed: () async {
                  notesModel.entityBeingEdited = Note();
                  notesModel.setColor(' ');
                  notesModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                itemCount: notesModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex){
                  Note note = notesModel.entityList[inIndex];
                    // Determine note background color (default to white if none was selected).
                    Color color = Colors.white;
                    switch(note.color){
                      case "red" : color = Colors.red; break;
                      case "green" : color = Colors.green; break;
                      case "blue" : color = Colors.blue; break;
                      case "yellow" : color = Colors.yellow; break;
                      case "grey" : color = Colors.grey; break;
                      case "purple" : color = Colors.purple; break;
                    }
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        actionExtentRatio: .25,
                        secondaryActions: [
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _deleteNote(inContext, note),
                          )
                        ],
                        child: Card(
                          elevation: 8,
                          color: color,
                          child: ListTile(
                            title: Text('${note.title}'),
                            subtitle: Text('${note.content}'),
                    // Edit existing note.
                    onTap : () async {
                      // Get the data from the database and send to the edit view.
                      notesModel.entityBeingEdited =
                      await NotesDBWorker.db.get(note.id);
                      notesModel.setColor(notesModel.entityBeingEdited.color);
                      notesModel.setStackIndex(1);
                    }
                          ),
                        ),
                      ),
                    );
                  }
              ),
            );
          }
        ),
    );
  }/* End build(). */

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future _deleteNote(BuildContext inContext, Note inNote) async {


    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : const Text('Delete Note'),
              content : Text('Are you sure you want to delete ${inNote.title}?'),
              actions : [
                TextButton(child : const Text('Cancel'),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }
                ),
                TextButton(child : const Text('Delete'),
                    onPressed : () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      await NotesDBWorker.db.delete(inNote.id);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(
                          const SnackBar(
                              backgroundColor : Colors.red,
                              duration : Duration(seconds : 2),
                              content : Text('Note deleted')
                          )
                      );
                      // Reload data from database to update list.
                      notesModel.loadData('notes', NotesDBWorker.db);
                    }
                )
              ]
          );
        }
    );

  } /* End _deleteNote(). */

}
