import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notsepeti/models/kategori.dart';
import 'package:notsepeti/models/notlar.dart';
import 'package:notsepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {

  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik,this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {

  var formKey=GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DataBaseHelper dataBaseHelper;
  int kategoriID;
  String notBaslik,notIcerik;
  static var _oncelik = ["düşük","orta","yüksek"];
  int secilenOncelik;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tumKategoriler=List<Kategori>();
    dataBaseHelper=DataBaseHelper();
    dataBaseHelper.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for(Map okunanMap in kategorileriIcerenMapListesi){
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if(widget.duzenlenecekNot != null){
        kategoriID = widget.duzenlenecekNot.kategoriID;
        secilenOncelik = widget.duzenlenecekNot.notOncelik;
      }else{
        kategoriID=1;
        secilenOncelik=0;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.baslik),),
      body: tumKategoriler.length <= 0 ? Center(child: CircularProgressIndicator(),) :
          Container(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Kategori :"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 40),
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButtonHideUnderline(
                              child: DropdownButton(items: kategoriItemleriOlustur(),
                                value: kategoriID,
                              onChanged: (secilenKategoriID) {
                                setState(() {
                                  kategoriID=secilenKategoriID;
                                });
                              },),
                              ),
                        
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notBaslik : "",
                      // ignore: missing_return
                      validator: (text) {
                        if(text.length < 2){
                          return "en az 2 karakter girin";
                        }
                      },
                      onSaved: (text) {
                        notBaslik=text;
                      },
                      decoration: InputDecoration(
                        hintText: "Not başlığını girin",
                        labelText: "Başlık",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notIcerik : "",
                      onSaved: (text) {
                        notIcerik=text;
                      },
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Not içeriğini girin",
                        labelText: "İçerik",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text("Öncelik :"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 20),
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(items: _oncelik.map((oncelik) {
                            return DropdownMenuItem<int>(
                              child: Text(oncelik),
                              value: _oncelik.indexOf(oncelik),);
                          }).toList(),
                            value: secilenOncelik,
                            onChanged: (secilenOncelikID) {
                              setState(() {
                                secilenOncelik=secilenOncelikID;
                              });
                            },),
                        ),
                      ),
                    ],
                  ),
                  ButtonBar(
                    children: [
                      RaisedButton(onPressed: () {
                        Navigator.pop(context);
                      }, child: Text("Vazgeç"),color: Colors.grey,),
                      RaisedButton(onPressed: () {
                        if(formKey.currentState.validate()){
                          formKey.currentState.save();
                          var suan=DateTime.now();
                          if(widget.duzenlenecekNot != null){
                            dataBaseHelper.notEkle(Not(kategoriID, notBaslik, notIcerik, suan.toString(),
                                secilenOncelik)).then((kaydedilenNotID) {
                              if(kaydedilenNotID != 0){
                                Navigator.pop(context);
                              }
                            });
                          }
                          else{
                            dataBaseHelper.notGuncelle(Not.withID(widget.duzenlenecekNot.notID,kategoriID, notBaslik, notIcerik, suan.toString(),
                                secilenOncelik)).then((guncellenenID) {
                                  if(guncellenenID != null){
                                    Navigator.pop(context);
                                  }
                            });
                          }

                        }
                      }, child: Text("Kaydet"),color: Colors.brown,),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  List<DropdownMenuItem<int>>kategoriItemleriOlustur() {

    return tumKategoriler.map((kategori)  => DropdownMenuItem(value: kategori.kategoriID,child: Text(kategori.kategoriBaslik))).toList();

  }


}

