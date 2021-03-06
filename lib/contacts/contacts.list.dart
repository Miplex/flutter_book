import "dart:io";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:path/path.dart";
import "../utils.dart" as utils;
import "contacts_db_worker.dart";
import "contacts_model.dart" show Contact, ContactsModel, contactsModel;


class ContactsList extends StatelessWidget {
  const ContactsList({Key? key}) : super(key: key);



  /// The build() method.

  @override
  Widget build(BuildContext context) {

    // Return widget.
    return ScopedModel<ContactsModel>(
        model : contactsModel,
        child : ScopedModelDescendant<ContactsModel>(
            builder : (BuildContext inContext, Widget inChild, ContactsModel inModel) {
              return Scaffold(
                // Add contact.
                  floatingActionButton : FloatingActionButton(
                      child : const Icon(Icons.add, color : Colors.white),
                      onPressed : () async {
                        // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                        File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                        if (avatarFile.existsSync()) {
                          avatarFile.deleteSync();
                        }
                        contactsModel.entityBeingEdited = Contact();
                        contactsModel.setChosenDate('');
                        contactsModel.setStackIndex(1);
                      }
                  ),
                  body : ListView.builder(
                      itemCount : contactsModel.entityList.length,
                      itemBuilder : (BuildContext inBuildContext, int inIndex) {
                        Contact contact = contactsModel.entityList[inIndex];
                        // Get reference to avatar file and see if it exists.
                        File avatarFile = File(join(utils.docsDir!.path, contact.id.toString()));
                        bool avatarFileExists = avatarFile.existsSync();
                        return Column(
                            children : [
                              Slidable(
                                  actionPane: const SlidableDrawerActionPane(),
                                  actionExtentRatio : .25,
                                  child : ListTile(
                                      leading : CircleAvatar(
                                          backgroundColor : Colors.indigoAccent,
                                          foregroundColor : Colors.white,
                                          backgroundImage : avatarFileExists ? FileImage(avatarFile) : null,
                                          child : avatarFileExists ? null : Text(contact.name.substring(0, 1).toUpperCase())
                                      ),
                                      title : Text("${contact.name}"),
                                      subtitle : contact.phone == null ? null : Text("${contact.phone}"),
                                      // Edit existing contact.
                                      onTap : () async {
                                        // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                                        File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                                        if (avatarFile.existsSync()) {
                                          avatarFile.deleteSync();
                                        }
                                        // Get the data from the database and send to the edit view.
                                        contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);
                                        // Parse out the  birthday, if any, and set it in the model for display.
                                        if (contactsModel.entityBeingEdited.birthday == null) {
                                          contactsModel.setChosenDate('');
                                        } else {
                                          List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                                          DateTime birthday = DateTime(
                                              int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
                                          );
                                          contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(birthday.toLocal()));
                                        }
                                        contactsModel.setStackIndex(1);
                                      }
                                  ),
                                  secondaryActions : [
                                    IconSlideAction(
                                        caption : "Delete",
                                        color : Colors.red,
                                        icon : Icons.delete,
                                        onTap : () => _deleteContact(inContext, contact)
                                    )
                                  ]
                              ),
                              const Divider()
                            ]
                        ); /* End Column. */
                      } /* End itemBuilder. */
                  ) /* End ListView.builder. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder. */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a dialog requesting delete confirmation.
  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : const Text("Delete Contact"),
              content : Text("Are you sure you want to delete ${inContact.name}?"),
              actions : [
                TextButton(child : const Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }
                ),
                TextButton(child : const Text("Delete"),
                    onPressed : () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      File avatarFile = File(join(utils.docsDir!.path, inContact.id.toString()));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      await ContactsDBWorker.db.delete(inContact.id);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(
                          const SnackBar(
                              backgroundColor : Colors.red,
                              duration : Duration(seconds : 2),
                              content : Text("Contact deleted")
                          )
                      );
                      // Reload data from database to update list.
                      contactsModel.loadData("contacts", ContactsDBWorker.db);
                    }
                )
              ]
          );
        }
    );

  } /* End _deleteContact(). */


} /* End class. */