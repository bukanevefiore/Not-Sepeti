import 'package:flutter/material.dart';
import 'package:notsepeti/models/kategori.dart';
import 'package:notsepeti/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {

  List<Kategori> tumKategoriler;
  DataBaseHelper dataBaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler=List<Kategori>();
    dataBaseHelper=DataBaseHelper();
  }

  @override
  Widget build(BuildContext context) {

    if(tumKategoriler == null){
      tumKategoriler = List<Kategori>();
      kategorilerListesiniGuncelle();
    }

    return Scaffold(
      appBar: AppBar(title: Text("Kategoriler"),),
      body: ListView.builder(
          itemCount: tumKategoriler.length,
          itemBuilder: (context,index) {
        return ListTile(
          onTap: _kategoriGuncelle(tumKategoriler[index],context),
          title: Text(tumKategoriler[index].kategoriBaslik),
          leading: Icon(Icons.category),
          trailing: InkWell(child: Icon(Icons.delete),onTap: () {
            _kategoriSil(tumKategoriler[index].kategoriID);
          },),
        );
      }),
    );
  }

  void kategorilerListesiniGuncelle() {

    dataBaseHelper.kategoriListesiniGetir().then((kategorileriIcerenList) {
      setState(() {
        tumKategoriler = kategorileriIcerenList;
      });
    });

  }

  _kategoriSil(int kategoriID) {

    showDialog(context: context, barrierDismissible: false,builder: (context) {
      return AlertDialog(
        title: Text("Kategori Sil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Kategoriyi sildiğinizde bununla ilgili tüm notlar silinecek ! \n Emin misiniz ?"),
            ButtonBar(
              children: [
                FlatButton(onPressed: () {
                  Navigator.of(context).pop();
                }, child: Text("VAZGEÇ"),),
                FlatButton(onPressed: () {

                  dataBaseHelper.kategoriSil(kategoriID).then((silinenKategori) {
                    if(silinenKategori != 0){
                      setState(() {
                        kategorilerListesiniGuncelle();
                        Navigator.pop(context);
                      });
                    }
                  });

                }, child: Text("SİL"),),
              ],
            ),
          ],
        ),
      );
    });
  }

  _kategoriGuncelle(Kategori guncellenecekKategori,BuildContext context) {

    kategoriGuncelleDialog(context,guncellenecekKategori);
  }

  void kategoriGuncelleDialog(BuildContext myContext, Kategori guncellenecekKategori) {

    var formKey=GlobalKey<FormState>();
    String guncellenenKategoriAdi;

    showDialog(
        barrierDismissible: false,
        context: myContext, builder: (context){
      return SimpleDialog(
        title: Text("Kategori Ekle", style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: guncellenecekKategori.kategoriBaslik,
                onSaved: (yeniDeger) {
                  guncellenenKategoriAdi=yeniDeger;
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
                  dataBaseHelper.kategorileriGuncelle(Kategori.withID(guncellenecekKategori.kategoriID,
                      guncellenenKategoriAdi)).then((kategorID) {
                    if(kategorID != 0){
                      Scaffold.of(myContext).showSnackBar(SnackBar(content: Text("Kategori Güncellendi"),
                        duration: Duration(seconds: 1),
                      ),
                      );
                      kategorilerListesiniGuncelle();
                      Navigator.of(context).pop();
                    }
                  });

                  /*  dataBaseHelper.kategorileriEkle(Kategori(guncellenenKategoriAdi)).then((kategoriID) {
                  if(kategoriID > 0 ){
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(" Kategori eklenedi"), duration: Duration(seconds: 2),),
                    );
                    debugPrint("Kategori eklendi $kategoriID");
                    Navigator.pop(context);
                  }
                });*/
                }
              }, color: Colors.brown,child: Text("Kyadet",style: TextStyle(color: Colors.white),),),
            ],
          ),
        ],
      );
    });
  }
}



