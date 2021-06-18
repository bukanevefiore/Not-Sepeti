class Kategori {

  int kategoriID;
  String kategoriBaslik;

  Kategori(this.kategoriBaslik);  // verileri yazarken
  Kategori.withID(this.kategoriID,this.kategoriBaslik);// verileri okurken



  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    map["katogoriID"] = kategoriID;
    map["kategoriBaslik"] = kategoriBaslik;
    return map;
  }

  Kategori.fromMap(Map<String, dynamic> map){
    this.kategoriID = map['katogoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
  }

  @override
  String toString() {
    return 'Kategori{kategoriID: $kategoriID, kategoriBaslik: $kategoriBaslik}';
  }
}