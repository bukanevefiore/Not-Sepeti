import 'package:flutter/material.dart';
import 'package:notsepeti/models/kategori.dart';
import 'package:notsepeti/models/notlar.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter/services.dart';

class DataBaseHelper{

  static DataBaseHelper _dataBaseHelper;
  static Database _database;

  factory DataBaseHelper(){
    if(_dataBaseHelper == null){
      _dataBaseHelper = DataBaseHelper._internal();
      return _dataBaseHelper;
    }
    else{
      return _dataBaseHelper;
    }
  }

  DataBaseHelper._internal();

  Future<Database> _getDataBase() async {
    if(_database == null){
      _database = await _initializeDatabase();
      return _database;
    }
    else{
      return _database;
    }
  }

  Future<Database> _initializeDatabase() async{


    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notlar.db");

// Check if the database exists
     var exists = await databaseExists(path);

     if (!exists) {
       // Should happen only the first time you launch your application
       print("Creating new copy from asset");

       // Make sure the parent directory exists
       try {
         await Directory(dirname(path)).create(recursive: true);
       } catch (_) {}

       // Copy from asset
       ByteData data = await rootBundle.load(join("assets", "notlar.db"));
       List<int> bytes =
       data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

       // Write and flush the bytes written
       await File(path).writeAsBytes(bytes, flush: true);

     } else {
       print("Opening existing database");
     }
// open the database
     return await openDatabase(path, readOnly: false);

  }

  Future<List<Map<String, dynamic>>> kategorileriGetir() async {
    var db = await _getDataBase();
    var sonuc = await db.query("kategori");
    return sonuc;
    //print(sonuc);

    //var ekleme = await db.insert("kategori", {"kategoriBaslik" : "Test kategorisi"});
    //var sonuc2 = await db.query("kategori");
    //print(sonuc2);
  }

  Future<int> kategorileriEkle(Kategori kategori) async {
    var db=await _getDataBase();
    var sonuc = await db.insert("kategori",kategori.toMap());
    return sonuc;
  }

  Future<int> kategorileriGuncelle(Kategori kategori) async {
    var db=await _getDataBase();
    var sonuc = await db.update("kategori", kategori.toMap(), where: 'kategoriID = ?', whereArgs: [kategori.kategoriID]);
    return sonuc;
  }
  
  Future<int> kategoriSil(int kategoriID) async {
    var db=await _getDataBase();
    var sonuc = await db.delete("kategori", where: 'kategoriID = ?', whereArgs: [kategoriID]);
    return sonuc;
  }
  Future<List<Map<String, dynamic>>> notlariGetir() async {
    var db =await _getDataBase();
    var sonuc = await db.query("not", orderBy: 'notID DESC');
    return sonuc;
  }

  Future<int> notEkle(Not not) async {
    var db =await _getDataBase();
    var sonuc = await db.insert("not", not.toMap());
    return sonuc;
  }

  Future<int> notGuncelle(Not not) async {
    var db = await _getDataBase();
    var sonuc = await db.update("not", not.toMap(), where: 'notID = ?', whereArgs: [not.notID]);
    return sonuc;
  }

  Future<int> notSil(int notID) async {
    var db = await _getDataBase();
    var sonuc = await db.delete("not", where: 'notID = ?',whereArgs: [notID]);
  }


}