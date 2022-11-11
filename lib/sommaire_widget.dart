
import 'song_view.dart';
import 'package:flutter/material.dart';

import '../cj_song.dart';

class SommaireWidget extends StatefulWidget{
  const SommaireWidget({super.key, required this.isFavoriteView, required this.shorted});

  final bool isFavoriteView;
  static const String sommaire = "Sommaire";
  static const String favories = "Favories";
  final bool shorted;

  @override
  State<StatefulWidget> createState() {
    return _SommaireState();
  }

}
///////////////////////////////////////
class _SommaireState extends State<SommaireWidget>{

  int currentIndex = -1;
  @override
  Widget build(BuildContext context) {

    if(!CJSon.isLoaded){
      debugPrint("Loading ............");
      CJSon.load(DefaultAssetBundle.of(context)).then((value){
        setState(() {
        });
      });
      return const Center(
        child: Text("Chargement en cours ..."),
      );
    }
    List<int> indexes = CJSon.getNumbers(areFavorites: widget.isFavoriteView, sorted: widget.shorted);

    if(widget.isFavoriteView && indexes.isEmpty){
      return const Center(
        child: Text("Auccun favori", style: TextStyle(fontSize: 22)),
      );
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              itemCount: indexes.length,
              itemBuilder: (BuildContext ctx, int index){
                var cjTitle =  CJTitle(
                  index: indexes.elementAt(index),
                  isSelected: indexes.elementAt(index) == currentIndex,
                  onClick: () {
                    if(widget.isFavoriteView){
                      setState(() {
                        currentIndex = indexes.elementAt(index);
                      });
                      return;
                    }
                    if(currentIndex != indexes.elementAt(index)){
                      setState(() {
                        currentIndex = indexes.elementAt(index);
                      });
                    }
                },
                );
                if(widget.shorted){
                  if(index >0 && index< CJSon.list.length){
                    var prev = CJSon.list.elementAt(indexes.elementAt(index-1)).title.toUpperCase();
                    var cur = CJSon.list.elementAt(indexes.elementAt(index)).title.toUpperCase();
                    if(prev.isNotEmpty && cur.isNotEmpty){
                      var a = prev.codeUnits.first;
                      var b = cur.codeUnits.first;
                      if(a != b){
                        return Column(
                          children: [
                            ListTile(
                                leading: Text(String.fromCharCode(b), style: const TextStyle(fontSize: 18))
                            ),
                            cjTitle
                          ],
                        );
                      }
                    }
                  }
                }
                if(index == 0 && widget.shorted) {
                  return Column(
                  children: [
                    const ListTile(
                        leading: Text("A", style: TextStyle(fontSize: 18))
                    ),
                    cjTitle
                  ],
                  );
                }
                return cjTitle;
              }
          ),
        )
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
//Cj Title widget
class CJTitle extends StatefulWidget{

  const CJTitle({super.key, required this.index, required this.isSelected, required this.onClick});
  final int index;
  final bool isSelected;
  final Function()? onClick;

  @override
  TitleState createState() {
    return TitleState();
  }

}

///////////////////////////////////////////////////////////////////////////////////////////
class TitleState extends State<CJTitle>{

  double fotSize= 14;
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
            color: widget.isSelected? Colors.lightBlue: Colors.white,
            child: ListTile(
              textColor: widget.isSelected? Colors.white: Colors.black,
              leading: Text("N° ${widget.index+1}",
                style: TextStyle(fontSize: fotSize),
              ),
              trailing: IconButton(
                icon: Icon(CJSon.list.elementAt(widget.index).isFavorite? Icons.favorite: Icons.favorite_border),
                onPressed: () {
                  setState(() {
                    CJSon.list.elementAt(widget.index).isFavorite = !CJSon.list.elementAt(widget.index).isFavorite;
                    if(widget.onClick != null){
                      widget.onClick!();
                    }
                  });
                },
              ),
              title: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(CJSon.list.elementAt(widget.index).title,
                    style: TextStyle(
                        color: widget.isSelected? Colors.white: Colors.black, fontSize: fotSize
                    ),
                  ),
                  onPressed: () {
                    if(widget.onClick != null){
                      widget.onClick!();
                    }
                    Navigator.of(context).push(
                        PageRouteBuilder(pageBuilder:(BuildContext ctx, Animation<double> a1, Animation<double> a2){
                          return SongView(number: widget.index);
                        }));
                  },
                ),
              )
            )
        )
    );
  }
}
