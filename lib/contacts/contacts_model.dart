import 'package:flutter_book/base_model.dart';

class Contact {

  int id = 0;
  String name = '';
  String phone = '';
  String? email;
  String? birthday;

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phone: $phone, email: $email, birthday: $birthday}';
  }
}


class ContactsModel extends BaseModel{
  void triggerRebuild(){
    notifyListeners();
}
}

ContactsModel contactsModel = ContactsModel();