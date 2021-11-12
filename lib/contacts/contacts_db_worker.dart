import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "contacts_model.dart";



class ContactsDBWorker {


  /// Static instance and private constructor, since this is a singleton.
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();


  /// The one and only database instance.
  Database? _db;



  Future get database async {

    // if (_db == null) {
    //   _db = await init();
    // }

    _db ??= await init();

    return _db;

  } /* End database getter. */



  Future<Database> init() async {

    String path = join(utils.docsDir!.path, "contacts.db");

    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
        onCreate : (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS contacts ("
                  "id INTEGER PRIMARY KEY,"
                  "name TEXT,"
                  "email TEXT,"
                  "phone TEXT,"
                  "birthday TEXT"
                  ")"
          );
        }
    );
    return db;

  } /* End init(). */


  /// Create a Contact from a Map.
  Contact contactFromMap(Map inMap) {

    Contact contact = Contact();
    contact.id = inMap["id"];
    contact.name = inMap["name"];
    contact.phone = inMap["phone"];
    contact.email = inMap["email"];
    contact.birthday = inMap["birthday"];

    return contact;

  } /* End contactFromMap(); */


  /// Create a Map from a Contact.
  Map<String, dynamic> contactToMap(Contact inContact) {


    Map<String, dynamic> map = <String, dynamic>{};  //Map<String, dynamic>();
    map["id"] = inContact.id;
    map["name"] = inContact.name;
    map["phone"] = inContact.phone;
    map["email"] = inContact.email;
    map["birthday"] = inContact.birthday;

    return map;

  } /* End contactToMap(). */


  /// Create a contact.

  Future create(Contact inContact) async {

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    var id = val.first["id"];

    //if (id == null) { id = 1; }
    id ??= 1;

    // Insert into table.
    await db.rawInsert(
        "INSERT INTO contacts (id, name, email, phone, birthday) VALUES (?, ?, ?, ?, ?)",
        [
          id,
          inContact.name,
          inContact.email,
          inContact.phone,
          inContact.birthday
        ]
    );

    return id;

  } /* End create(). */


  /// Get a specific contact.
  Future<Contact> get(int inID) async {

    Database db = await database;
    var rec = await db.query("contacts", where : "id = ?", whereArgs : [ inID ]);

    return contactFromMap(rec.first);

  } /* End get(). */


  /// Get all contacts.

  Future<List> getAll() async {

    Database db = await database;
    var recs = await db.query("contacts");
    var list = recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [ ];

    return list;

  } /* End getAll(). */


  /// Update a contact.
  Future update(Contact inContact) async {
    Database db = await database;
    return await db.update("contacts", contactToMap(inContact), where : "id = ?", whereArgs : [ inContact.id ]);

  } /* End update(). */


  /// Delete a contact.
  Future delete(int inID) async {

    Database db = await database;
    return await db.delete("contacts", where : "id = ?", whereArgs : [ inID ]);

  } /* End delete(). */


} /* End class. */