import 'package:labtest1/SQLiteDB.dart';
class BMI{
  static const String SQLiteTable = 'bmi';
  String username;
  double weight;
  double height;
  int gender;
  int status;
  BMI({
    required this.username,
    required this.weight,
    required this.height,
    required this.gender,
    required this.status,
});

  Map<String, dynamic> toJson() =>{
    'username': username,
    'weight': weight,
    'height': height,
    'gender' :gender,
    'bmi_status': status,
  };

  BMI.fromJson(Map<String, dynamic> json):
        username = json['username'] as String ?? "",
        weight = json['weight'] as double ?? 0,
        height = json['height'] as double ?? 0,
        gender = int.parse(json['gender'].toString()) ?? 1,
        status = int.parse(json['bmi_status'].toString()) ?? 1;


  Future<bool> save() async{
    if (await SQLiteDB().insert(SQLiteTable,toJson()) != 0){
      return true;
    }
    return false;
  }

  static Future<BMI?> load() async{
    //   API operation
    try {
      BMI? result;
      List<Map<String, dynamic>> resultFromDatabase = await SQLiteDB().loadLast(SQLiteTable);
      if (resultFromDatabase.length > 0 ) {
        print("got data");
        print(resultFromDatabase.toString());
        result = BMI.fromJson(resultFromDatabase.first);
      }
      return result;
    } catch (e) {
      print("Error loading data from the database: $e");
      return null;
    }
  }
}