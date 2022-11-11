import 'cj_song.dart';
import 'package:flutter/material.dart';

class SongView extends StatefulWidget{

  final int number;

  const SongView({super.key, required this.number});

  @override
  State<StatefulWidget> createState() {
    return _SongViewState();
  }

}

class _SongViewState extends State<SongView>{

  final int _index = 0;
  final double minFontSize = 14;
  double _fontSize = 16;
  final double maxFontSize = 32;
  double _scale = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("N°${CJSon.list.elementAt(widget.number+_index).number} ${CJSon.list.elementAt(widget.number+_index).title}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: (){
              if(_fontSize> minFontSize){
                setState(() {
                  _fontSize-=2;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: (){
              if(_fontSize< maxFontSize){
                setState(() {
                  _fontSize+=2;
                });
              }
            },
          )
        ],
      ),
      body: Align(
          alignment: Alignment.center,
          child: GestureDetector(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(CJSon.list.elementAt(widget.number+_index).content,
                      style: TextStyle(fontSize: _fontSize),
                    ),
                  ),
                )
              ],
            ),
            onScaleUpdate: (ScaleUpdateDetails detail){
              debugPrint("onScaleUpdate: ${detail.scale} ${detail.horizontalScale} ${detail.focalPoint}");
              _scale = detail.scale;
            },
            onScaleEnd: (ScaleEndDetails detail){
              if(_scale != 1){
                setState(() {
                  _fontSize*= _scale;
                  _scale = 1;
                  _fontSize = _fontSize>22? 22: _fontSize;
                  _fontSize = _fontSize< 12? 12: _fontSize;
                });
              }
            },
            onTapCancel: (){
              debugPrint("onTapCancel");
            },
            onSecondaryTapCancel: (){
              debugPrint("onSecondaryTapCancel");
            },
          )
      ),
    );
  }
}
