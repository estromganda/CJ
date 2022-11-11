import 'dart:convert';
import 'dart:io';
import 'sommaire_widget.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class CJSon{

  CJSon({required this.title, required this.number, required this.content, required this.isFavorite});
  String title;
  int number;
  String content;
  bool isFavorite = false;
  static  bool isLoaded = false;
  static  bool _isLoading = false;
  static List<CJSon> list = [];
  static List<CJSon> shortedList = [];
  static List<int> favorites = [];
  static String fileName = "favorite.json";
  static String homeVar = "EMULATED_STORAGE";

  static Future<bool> load (AssetBundle assetBundle) async {
    if (isLoaded) return Future.value(isLoaded);
    if (_isLoading) return Future.value(false);
    _isLoading = true;
    await getApplicationDocumentsDirectory().then((value){
      debugPrint("$value");
      fileName = "${value.path}/$fileName";
      debugPrint(fileName);
    });


    var path = "assets/data/cj.json";
    await assetBundle.loadString(path).then((value) async {
      var file = File(fileName);
      if(file.existsSync()){
        await file.readAsString().then((value){
          List<dynamic> ls = json.decode(value);
          for(var i in ls){
            favorites.add(i);
          }
          favorites.sort((int a, int b)=> a.compareTo(b));
        }).onError((error, stackTrace){
          debugPrint("On read fav error: $error");
        });
      }
      else{
        debugPrint("$fileName doesn't exist");
      }
      List<dynamic> ls = json.decode(value);
      for (var element in ls) {
        var song = CJSon(
            title: element["title"],
            number: int.tryParse(element["number"])!,
            content: element["content"], isFavorite: false
        );
        song.isFavorite = favorites.contains(song.number);
        list.add(song);
      }
      list.sort((CJSon a, CJSon b) => a.number.compareTo(b.number));
      isLoaded = true;
    },
    onError: (error){
      debugPrint(error);
    });
    _isLoading = false;
    return Future.value(isLoaded);
  }

  static List<int> getNumbers({bool areFavorites= false, bool sorted=false}){
    assert(isLoaded);
    List<int> ls = [];
    if(areFavorites){
      for (var element in list) {
        if(element.isFavorite){
          ls.add(element.number - 1);
        }
      }
    }
    else{
      ls = List.generate(list.length, (index) => index);
    }
    if(sorted){
      ls.sort((int a, int b)=> list.elementAt(a).title.toUpperCase().compareTo(list.elementAt(b).title.toUpperCase()));
    }
    return ls;
  }

  static Future<void> save() async {
    favorites.clear();
    for (var element in list) {
      if(element.isFavorite){
        favorites.add(element.number);
      }
    }
    try{
      var file = File(fileName);
      if(!file.existsSync()){
        file = await file.create();
      }
      var rFile = file.openSync(mode: FileMode.writeOnly);
      rFile.writeStringSync(json.encode(favorites));
      rFile.close();
      debugPrint("Saved .......................");
    }
    on FileSystemException catch (e){
      debugPrint("...............................${Platform.script}");
      debugPrint("Error on saving file $fileName: $e");
      debugPrint("...............................${Platform.script}");
    }
  }
}
//////////////////////////////////////////////////

class CJSonSearchDelegate extends SearchDelegate<CJSon>{

  CJSonSearchDelegate():super(
    searchFieldLabel: "Entrez un titre ou un numéro"
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isNotEmpty){
      int? index = int.tryParse(query);
      if(index != null && index < CJSon.list.length && index>0){
        return CJTitle(index: index-1, isSelected: false, onClick: (){});
      }
      List<int> ls = [];
      for (var element in CJSon.list) {
        if(element.title.toUpperCase().contains(query.toUpperCase())){
          ls.add(element.number - 1);
        }
      }
      if(ls.isNotEmpty){
        ls.sort((int a, int b)=> CJSon.list.elementAt(a).title.toUpperCase().compareTo(CJSon.list.elementAt(b).title.toUpperCase()));
        return ListView.builder(
            itemCount: ls.length,
            itemBuilder: (BuildContext ctx, int index){
              return CJTitle(index: ls.elementAt(index), isSelected: false, onClick: (){});
            }
        );
      }
    }
    return const Center(
      child: Text("Auccun resultant", style: TextStyle(fontSize: 18),),
    );
  }
}