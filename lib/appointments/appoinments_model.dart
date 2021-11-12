import 'package:flutter_book/base_model.dart';

class Appointment{
  int id = 0;
  String? title;
  String? description;
  String? apptDate; // YYYY,MM,DD
  String? apptTime;

  @override
  String toString() {
    return 'Appointment{id: $id, title: $title, description: $description, apptDate: $apptDate, apptTime: $apptTime}';
  } // HH,MM

}

class AppointmentsModel extends BaseModel{

  String apptTime='';

  void setApptTime(String inApptTime) {

    apptTime = inApptTime;
    notifyListeners();

  }
}


AppointmentsModel appointmentsModel = AppointmentsModel();