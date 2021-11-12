import 'package:scoped_model/scoped_model.dart';



/// ********************************************************************************************************************
/// Base class that the model for all entities extend.
/// ********************************************************************************************************************

class BaseModel extends Model{


  /// Which page of the stack is currently showing.
  ///
    int stackIndex = 0;


  /// The list of entities

    List entityList = [];

    /// The entity being edited.
    var entityBeingEdited;


    /// The date chosen by the user.  Needed to be able to display what the user picks on the entry screen.

    String chosenDate = '';


///For display of the date chosen by the user.
///
/// @param inDate The date in MM/DD/YYYY form.

    void setChosenDate(String intDate){
      chosenDate = intDate;
      notifyListeners();
    }/* End setChosenDate(). */

/// Load data from database.
///
/// @param inEntityType The type of entity being loaded ("appointments", "contacts", "notes" or "tasks").
/// @param inDatabase   The DBProvider.db instance for the entity.


   void loadData(String inEntityType, dynamic inDataBase) async{

     // Load entities from database.
     entityList = await inDataBase.getAll();

// Notify listeners that the data is available so they can paint themselves.
     notifyListeners();
   }





/// For navigating between entry and list views.
///
/// @param inStackIndex The stack index to make current.

  void setStackIndex(int inStackIndex){
    stackIndex = inStackIndex;
    notifyListeners();
  }/* End setStackIndex(). */


}/* End class. */