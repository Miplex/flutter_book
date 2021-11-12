import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'notes_model.dart';




class NotesDBWorker{

  /// Static instance and private constructor, since this is a singleton.
 NotesDBWorker._();
  static final NotesDBWorker db =  NotesDBWorker._();

/// The one and only database instance.

 Database? _db;


/// Get singleton instance, create if not available yet.
///
/// @return The one and only Database instance.
Future get database async{

  if(_db == null){
    _db = await init();
  }

  //_db ??= await init();

  return _db;
}/* End database getter. */

/// Initialize database.
///
/// @return A Database instance.

Future<Database> init() async{
  
  String path = join(utils.docsDir!.path, 'notes.db');
  
  Database db = await openDatabase(path,version: 1,onOpen: (db){},
    onCreate: (Database inDB, int inVersion) async {
    await inDB.execute('CREATE TABLE IF NOT EXISTS notes ('
        'id INTEGER PRIMARY KEY,'
        'title TEXT,'
        'content TEXT,'
        'color TEXT'
        ')'
    );
    }
  );
  return db;
}/* End init(). */



 /// Create a Note from a Map.
 Note noteFromMap(Map inMap) {



   Note note = Note();
   note.id = inMap["id"];
   note.title = inMap["title"];
   note.content = inMap["content"];
   note.color = inMap["color"];


   return note;

 } /* End noteFromMap(); */



/// Create a Map from a Note.

 Map<String, dynamic> noteToMap(Note inNote) {
   Map <String, dynamic> map = Map <String, dynamic>();
   map['id'] = inNote.id;
   map['title'] = inNote.title;
   map['content'] = inNote.content;
   map['color'] = inNote.color;

   return map;
 }/* End noteToMap(). */



/// Create a note.
///
/// @param  inNote The Note object to create.
/// @return        Future.

Future create(Note inNote) async{
  Database db = await database;

  // Get largest current id in the table, plus one, to be the new ID.
  var val = await db.rawQuery('SELECT MAX(id) + 1 AS id FROM notes');
  var id = val.first['id'];
  id ??= 1;

  // Insert into table.
  return await db.rawInsert('INSERT INTO notes (id, title, content, color) VALUES (?, ?, ?, ?)',[
    id,
    inNote.title,
    inNote.content,
    inNote.color
  ]);
}/* End create(). */


/// Get a specific note.
///
/// @param  inID The ID of the note to get.
/// @return      The corresponding Note object.

 Future<Note> get(int inID) async {

   Database db = await database;
   var rec = await db.query('notes', where : 'id = ?', whereArgs : [ inID ]);


   return noteFromMap(rec.first);

 } /* End get(). */


 /// Get all notes.
 ///
 /// @return A List of Note objects.

Future <List> getAll() async{
  Database db = await database;
  var recs = await db.query('notes');
  var list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList():[];

  return list;
}/* End getAll(). */



 /// Update a note.
 ///
 /// @param inNote The note to update.
 /// @return       Future.
 Future update(Note inNote) async {



   Database db = await database;
   return await db.update("notes", noteToMap(inNote), where : 'id = ?', whereArgs : [ inNote.id ]);

 } /* End update(). */


 /// Delete a note.
 ///
 /// @param inID The ID of the note to delete.
 /// @return     Future.
 Future delete(int inID) async {



   Database db = await database;
   return await db.delete('notes', where : 'id = ?', whereArgs : [ inID ]);

 } /* End delete(). */




}