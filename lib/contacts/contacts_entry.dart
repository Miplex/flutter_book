import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:scoped_model/scoped_model.dart";
import "package:image_picker/image_picker.dart";
import "../utils.dart" as utils;
import "contacts_db_worker.dart";
import "contacts_model.dart" show ContactsModel, contactsModel;



class ContactsEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  ContactsEntry({Key? key}) : super(key: key) {


    // Attach event listeners to controllers to capture entries in model.
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });

  } /* End constructor. */


  @override
  Widget build(BuildContext context) {


    // Set value of controllers.
    if (contactsModel.entityBeingEdited != null) {
      _nameEditingController.text = contactsModel.entityBeingEdited.name;
      _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
      _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    // Return widget.
    return ScopedModel(
        model : contactsModel,
        child : ScopedModelDescendant<ContactsModel>(
            builder : (BuildContext inContext, Widget inChild, ContactsModel inModel) {
              // Get reference to avatar file, if any.  If it doesn't exist and the entityBeingEdited has an id then
              // look for an avatar file for the existing contact.
              File avatarFile = File(join(utils.docsDir!.path, "avatar"));
              if (avatarFile.existsSync() == false) {
                if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id != null) {
                  avatarFile = File(join(utils.docsDir!.path, inModel.entityBeingEdited.id.toString()));
                }
              }
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : const EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(
                                child : const Text("Cancel"),
                                onPressed : () {
                                  // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                                  File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                                  if (avatarFile.existsSync()) {
                                    avatarFile.deleteSync();
                                  }
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            const Spacer(),
                            TextButton(
                                child : const Text("Save"),
                                onPressed : () { _save(inContext, inModel); }
                            )
                          ]
                      )),
                  body : Form(
                      key : _formKey,
                      child : ListView(
                          children : [
                            ListTile(
                                title : avatarFile.existsSync() ? Image.file(avatarFile) : const Text("No avatar image for this contact"),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectAvatar(inContext)
                                )
                            ),
                            // Name.
                            ListTile(
                                leading : const Icon(Icons.person),
                                title : TextFormField(
                                    decoration : const InputDecoration(hintText : "Name"),
                                    controller : _nameEditingController,
                                    validator : (String? inValue) {
                                      if (inValue!.length == 0) { return "Please enter a name"; }
                                      return null;
                                    }
                                )
                            ),
                            // Phone.
                            ListTile(
                                leading : const Icon(Icons.phone),
                                title : TextFormField(
                                    keyboardType : TextInputType.phone,
                                    decoration : const InputDecoration(hintText : "Phone"),
                                    controller : _phoneEditingController
                                )
                            ),
                            // Email.
                            ListTile(
                                leading : const Icon(Icons.email),
                                title : TextFormField(
                                    keyboardType : TextInputType.emailAddress,
                                    decoration : const InputDecoration(hintText : "Email"),
                                    controller : _emailEditingController
                                )
                            ),
                            // Birthday.
                            ListTile(
                                leading : const Icon(Icons.today),
                                title : const Text("Birthday"),
                                subtitle : Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () async {
                                      // Request a date from the user.  If one is returned, store it.
                                      String chosenDate = await utils.selectDate(
                                          inContext, contactsModel, contactsModel.entityBeingEdited.birthday
                                      );
                                      if (chosenDate != null) {
                                        contactsModel.entityBeingEdited.birthday = chosenDate;
                                      }
                                    }
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



  Future _selectAvatar(BuildContext inContext) {


    return showDialog(context : inContext,
        builder : (BuildContext inDialogContext) {
          return AlertDialog(
              content : SingleChildScrollView(
                  child : ListBody(
                      children : [
                        GestureDetector(
                            child : const Text("Take a picture"),
                            onTap : () async {
                              var cameraImage = await ImagePicker().pickImage(source : ImageSource.camera);
                              if (cameraImage != null) {
                                 var ImageFile = File(cameraImage.path);
                                cameraImage = ImageFile.copySync(join(utils.docsDir!.path, "avatar")) as XFile?;

                                contactsModel.triggerRebuild();
                              }
                              // Hide this dialog.
                              Navigator.of(inDialogContext).pop();
                            }
                        ),
                        const Padding(padding : EdgeInsets.all(10)),
                        GestureDetector(
                            child : const Text("Select From Gallery"),
                            onTap : () async {
                              var galleryImage = await ImagePicker().pickImage(source : ImageSource.gallery);
                              if (galleryImage != null) {
                               var galleryImageFile = File(galleryImage.path);
                                galleryImage =galleryImageFile.copySync(join(utils.docsDir!.path, "avatar")) as XFile?;
                                // Tell the entry screen to rebuild itself to show the avatar.
                                contactsModel.triggerRebuild();
                              }
                              // Hide this dialog.
                              Navigator.of(inDialogContext).pop();
                            }
                        )
                      ]
                  )
              )
          );
        }
    );

  } /* End _selectAvatar(). */



  void _save(BuildContext inContext, ContactsModel inModel) async {



    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // We'll need the ID whether creating or updating way.
    var id;

    // Creating a new contact.
    if (inModel.entityBeingEdited.id == 0) {


      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);

      // Updating an existing contact.
    } else {


      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);

    }

    // If there is an avatar file, rename it using the ID.
    File avatarFile = File(join(utils.docsDir!.path, "avatar"));
    if (avatarFile.existsSync()) {

      avatarFile.renameSync(join(utils.docsDir!.path, id.toString()));
    }

    // Reload data from database to update list.
    contactsModel.loadData("contacts", ContactsDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Contact saved")
        )
    );

  } /* End _save(). */


} /* End class. */