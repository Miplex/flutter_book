import 'package:flutter_book/base_model.dart';

/// A class representing this PIM entity type.
class Note{

  /// The fields this entity type contains.
   int id = 0;
  String title = '';
  String content = '';
  String color = '';

  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, color: $color}';
  }
}/* End class. */



/// ****************************************************************************
/// The model backing this entity type's views.
/// ****************************************************************************
class NotesModel extends BaseModel{


  /// The color.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  String color ='';


  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.

 void setColor(String inColor) {
   color = inColor;
   notifyListeners();
 }/* End setColor(). */
}/* End class. */

NotesModel notesModel = NotesModel();