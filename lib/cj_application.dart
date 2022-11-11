import 'dart:io';

import 'cj_song.dart';
import 'sommaire_widget.dart';
import 'package:flutter/material.dart';


class CJApplication extends StatelessWidget {
  const CJApplication({super.key});

  @override
  Widget build(BuildContext context) {
    CJSon.load(DefaultAssetBundle.of(context));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CJ JEA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CJ JEA'),
    );
  }
}

//////////////////////////////////////

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  final List<Widget> subWidget = [
    const SommaireWidget(isFavoriteView: false, shorted: false),
    Image.asset("assets/images/home.png"),
    const SommaireWidget(isFavoriteView: true, shorted: false)
  ];
  final List<String> titles = [
    "Sommaire", "CJ JEA", "Favoris"
  ];


  @override
  State<StatefulWidget> createState() {
    return _HomeWidgetState();
  }
}

//////////////////////////////////////////

class _HomeWidgetState extends State<MyHomePage>{

  static const Color bottomBackgroundColor = Colors.lightBlue;

  int _currentIndex = 1;


  @override
  Widget build(BuildContext context) {
    List<Widget> lsActions = [];
    if(_currentIndex != 1){
      bool isShorted = (widget.subWidget[_currentIndex] as SommaireWidget).shorted;
      var icon = isShorted? Icons.sort_by_alpha:Icons.format_list_numbered;
      lsActions.add(IconButton(onPressed: _onShorted, icon: Icon(icon)));
    }
    lsActions.add(IconButton(icon: const Icon(Icons.lightbulb_outline),
      onPressed: (){_showAbout(context);},
    ));

    return WillPopScope(
        onWillPop: _onQuit,
      child: Scaffold(
        appBar: AppBar(
          actions: lsActions,
          title: Text(widget.titles.elementAt(_currentIndex%3)),
        ),
        body: Center(
            child: widget.subWidget.elementAt(_currentIndex%3)// SommaireWidget(isFavoriteView: true)//widget.subWidget.elementAt(_currentIndex)
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showSearchDialog(context);
          },
          tooltip: 'Chercher',
          child: const Icon(Icons.search),
        ), //
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          //backgroundColor: Colors.blue,
          onTap: (int index){
            if(_currentIndex != index){
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: "Sommaire",
              //backgroundColor: bottomBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: bottomBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favoris",
              //backgroundColor: bottomBackgroundColor,
            )
          ],
        ),// This trailing comma makes auto-formatting nicer for build methods.
      )
    );
  }

  void _showSearchDialog(BuildContext context){
    SearchDelegate<CJSon> delegate = CJSonSearchDelegate();
    showSearch(context: context, delegate: delegate).then((value){
      debugPrint("On value: $value");
    });
  }

  //Show about application
  void _showAbout(BuildContext context){
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SizedBox(
            height: 140,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children:[
                  Row(
                    children: [
                      Image.asset("assets/images/home.png", width: 80, height: 80,),
                      const Text('CJ JEA', style: TextStyle(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))
                    ],
                  ),
                  const Text("Version 0.1"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Offert par "),
                      Text("Void", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.copyright, size: 8),
                      Text("2022 by", style: TextStyle(fontSize: 8)),
                      Text(" Void", style: TextStyle(fontSize: 8)),
                      Icon(Icons.star, size: 8),
                    ],
                  )
                ],
              )
            )
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _onShorted(){
    if(_currentIndex == 0){
      setState(() {
        bool isShorted = (widget.subWidget[0] as SommaireWidget).shorted;
        widget.subWidget[0] = SommaireWidget(isFavoriteView: false, shorted: !isShorted);
      });
    }
    if(_currentIndex == 2){
      setState(() {
        bool isShorted = (widget.subWidget[2] as SommaireWidget).shorted;
        widget.subWidget[2] = SommaireWidget(isFavoriteView: true, shorted: !isShorted);
      });
    }
  }
  Future<bool> _onQuit() async {
    if(_currentIndex!= 1){
      setState(() {
        _currentIndex = 1;
      });
      return Future.value(false);
    }
    return await showDialog(context: context,
      builder: (BuildContext ctx){
        return AlertDialog(
          //title: Image.asset("assets/images/home.png", width: 128, height: 64),
          title: const Text("Voulez-vous quitter l'application?"),
          actions: [
            TextButton(
                child: const Text("Non"),
                onPressed: (){
                  Navigator.of(ctx).pop(false);
                }
            ),
            TextButton(
              child: const Text("Oui"),
              onPressed: (){
                CJSon.save().then((value){
                  Navigator.of(ctx).pop(true);
                  exit(0);
                });
              },
            )
          ],
        );
      }
    );
  }
}

