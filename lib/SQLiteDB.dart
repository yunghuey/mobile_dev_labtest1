import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDB{
  static const String _dbName = "bitp3453_bmi";
  Database? _db;
  SQLiteDB._();
  static final SQLiteDB _instance = SQLiteDB._();

  factory SQLiteDB(){
    return _instance;
  }

  Future<Database> get database async{
    if(_db != null){
      print("db not null");
      return _db!;
    }
    print("db is null");
    String path = join(await getDatabasesPath(), _dbName,);
    _db = await openDatabase(path, version: 1, onCreate: (createdDb, version) async {
      for (String tableSql in SQLiteDB.tableSQLStrings){
        await createdDb.execute(tableSql);
      }
    });
    return _db!;
  }

  static List<String> tableSQLStrings = [
    ''' 
      CREATE TABLE IF NOT EXISTS bmi (
         id INTEGER PRIMARY KEY AUTOINCREMENT, 
         username DOUBLE, 
         weight DOUBLE, 
         height DOUBLE, 
         gender INTEGER,
         bmi_status INTEGER
      )
    ''',
  ];


  Future<int> insert(String tablename, Map<String, dynamic> row) async{
    Database db = await _instance.database;
    return await db.insert(tablename, row);
  }

  Future<List<Map<String, Object?>>> loadLast(String tableName) async{
    Database db = await _instance.database;
    return await db.query(tableName, orderBy: 'id DESC', limit: 1);
  }

}