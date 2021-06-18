

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notsepeti/kategori_islemleri.dart';
import 'package:notsepeti/models/kategori.dart';
import 'package:notsepeti/models/notlar.dart';
import 'package:notsepeti/not_detay.dart';
import 'package:notsepeti/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {

  DataBaseHelper dataBaseHelper =DataBaseHelper();
  var scaffoldKey=GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Not Sepeti"),
      actions: [
        PopupMenuButton(itemBuilder: (context){
          return [
            PopupMenuItem(child: ListTile(
              leading: Icon(Icons.category),title: Text("Kategoriler"),
              onTap:() {
                Navigator.pop(context);
                _kategorilerSayfasinaGit(context);
              }
            )),
          ];
        },),
      ],),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Kategori ekle",
            onPressed: () {
            yeniKategoriEkleDialog(context);
          }, child: Icon(Icons.add),mini: true,tooltip: "KategoriEkle",),
          FloatingActionButton(
            heroTag: "Not ekle",
            onPressed: () {
            _detaySayafasinaGit(context);
          }, child: Icon(Icons.add),tooltip: "NotEkle",),
        ],
      ),
      body: Notlar(),
    );
  }

  void yeniKategoriEkleDialog(BuildContext context) {

    var formKey=GlobalKey<FormState>();
    String yeniKategoriAdi;

    showDialog(
      barrierDismissible: false,
        context: context, builder: (context){
      return SimpleDialog(
        title: Text("Kategori Ekle", style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        children: [
          Form(
            key: formKey,
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onSaved: (yeniDeger) {
                yeniKategoriAdi=yeniDeger;
              },
              decoration: InputDecoration(
                labelText: "Kategori Adı",
                border: OutlineInputBorder(),
              ),
              // ignore: missing_return
              validator: (girilenKategoriAdi){
                if(girilenKategoriAdi.length < 2){
                  return "En az 2 karakter giriniz";
                }
              },
            ),
          ),
          ),
          ButtonBar(
            children: [
              RaisedButton(onPressed: () {Navigator.pop(context);}, color: Colors.brown,child: Text("Vazgeç",style: TextStyle(color: Colors.white),),),
              RaisedButton(onPressed: () {
                if(formKey.currentState.validate()){
                  formKey.currentState.save();
                  dataBaseHelper.kategorileriEkle(Kategori(yeniKategoriAdi)).then((kategoriID) {
                    if(kategoriID > 0 ){
                      scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                          content: Text(" Kategori eklenedi"), duration: Duration(seconds: 2),),
                      );
                      debugPrint("Kategori eklendi $kategoriID");
                      Navigator.pop(context);
                    }
                  });
                }
              }, color: Colors.brown,child: Text("Kyadet",style: TextStyle(color: Colors.white),),),
            ],
          ),
        ],
      );
    });
  }


  void _detaySayafasinaGit(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => NotDetay(baslik: "Notu Düzenle",)));

  }

  _kategorilerSayfasinaGit(BuildContext context) {

    Navigator.of(context).push(MaterialPageRoute(builder: (contex) => Kategoriler()));

  }


}

class Notlar extends StatefulWidget {
  
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {

  List<Not> tumNotlar;
  DataBaseHelper dataBaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar=List<Not>();
    dataBaseHelper=new DataBaseHelper();
    
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataBaseHelper.notListesiniGetir(),
      builder: (context,AsyncSnapshot<List<Not>> snapshot) {
      if(snapshot.connectionState == ConnectionState.done){

        tumNotlar = snapshot.data;
        sleep(Duration(microseconds: 500));
        print("notlar :"+ tumNotlar.toString());
        return ListView.builder(itemCount: tumNotlar.length,itemBuilder: (context,index) {
          return ExpansionTile(
            leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
            title: Text(tumNotlar[index].notBaslik),
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Kategori :",style: TextStyle(color: Colors.black)),
                        Text(tumNotlar[index].kategoriBaslik,style: TextStyle(color: Colors.black26),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Oluşturulma Tarihi :",style: TextStyle(color: Colors.black)),
                         Text(dataBaseHelper.dateFormat(DateTime.parse(tumNotlar[index].notTarih)),style: TextStyle(color: Colors.black26),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("İçerik :",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold)),
                        Text(tumNotlar[index].notIcerik,style: TextStyle(color: Colors.black54),),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: [
                      FlatButton(onPressed: () => _notSil(tumNotlar[index].notID), child: Text("SİL",style: TextStyle(color: Colors.red),)),
                      FlatButton(onPressed: () => _detaySayafasinaGit(context,tumNotlar[index]), child: Text("GÜNCELLE")),
                    ],
                  ),
                ],
              ),
            ),
          ],
          );
        });
      }
      else{
        return Center(child: CircularProgressIndicator());
      }
    },);
  }

  void _detaySayafasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => NotDetay(
          baslik: "Notu Düzenle",
          duzenlenecekNot: not,
        )));

  }

  _oncelikIconuAta(int notOncelik) {
    switch(notOncelik){
      case 0:
        return CircleAvatar(child: Text("AZ",style: TextStyle(color: Colors.white,fontSize: 15)),backgroundColor: Colors.blue.shade200,);
      case 1:
        return CircleAvatar(child: Text("ORTA",style: TextStyle(color: Colors.white,fontSize: 13)),backgroundColor: Colors.blue.shade300,);
      case 2:
        return CircleAvatar(child: Text("ÇOK",style: TextStyle(color: Colors.white,fontSize: 13)),backgroundColor: Colors.blue.shade400,);

    }

  }

  _notSil(int notID) {

    dataBaseHelper.notSil(notID).then((silinenID) {
      if(silinenID != null){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not silindi")));
        setState(() {});
      }
    });
  }

  _notGuncelle(int notID) {}
}



