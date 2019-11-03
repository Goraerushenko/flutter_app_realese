import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TrainMenu.dart';

var image = "assets/image_04.jpg";

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}
var cardAspectRatio = 13.0 / 19.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _MenuState extends State<Menu>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = TextEditingController ();
  var currentPage = title.length - 1.0;
  bool tap = false;
  var lastRemoved = ['',0,''];
  void _onPressedAdd(){
      if(title.length < 3){
        Alert(
          context: context,
          title: "Введите название",
          content: Column(
            children: <Widget>[
              TextField(
                maxLength: 20,
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Название',
                ),
              ),
            ],
          ),
          buttons: [
            DialogButton(
              color: color,
              child: Text(
                "ПРИНЯТЬ",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                setState(() {
                  int i = 1;
                  if(controller.text.length == 0){
                    while(title.contains('Тренировка $i')){
                      i++;
                    }
                    controller.text = 'Тренировка $i';
                  }
                  title.insert(0, controller.text);
                  controller.clear();
                  listOfString.insert(0, '1');
                  _save();
                });
                Navigator.pop(context);
              },
              width: MediaQuery.of(context).size.width - 150,
            )
          ],
        ).show();
      } else {
        Alert(
          context: context,
          type: AlertType.error,
          title: "Вы не можете добать более 3-х тренировок",
          buttons: [
            DialogButton(
              color: color,
              child: Text(
                "ПРИНЯТЬ",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
              width: MediaQuery.of(context).size.width - 150,
            )
          ],
        ).show();
      }
  }
  void _showFloatingFlushbar(BuildContext context) {
    Flushbar(
      icon: IconButton(onPressed: (){
        if(!tap){
          Navigator.pop(context);
          tap = true;
        }
      },icon:Icon(Icons.close,color: Colors.blue,)),
      onStatusChanged: (v){
        if(v == FlushbarStatus.IS_HIDING){
          tap = true;
        }
      },
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [Colors.black, Colors.black],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 5),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      shouldIconPulse: true,
      message: 'Удалено: "${title[currentPage.round()]}"',
      mainButton: FlatButton.icon(onPressed: (){
        if(!tap){
          Navigator.pop(context);
          setState(() {
            title.insert(lastRemoved[1],lastRemoved[0]);// Some
            listOfString.insert(lastRemoved[1], lastRemoved[2]);// code to undo the change.
            _save();
            print(listOfString);
          });
          tap = true;
        }
      },
          icon: Icon(Icons.undo,color: Colors.blue,), label: Text('UNDO',style: TextStyle(color: Colors.blue),)),
    )..show(context);
  }
  void _onClickDel(){
    Alert(
      context: context,
      title: 'Вы уверены,что хотите удалить "${title[currentPage.round()]}"',
      type: AlertType.warning,
      buttons: [
        DialogButton(
          color: color,
          child: Text(
            "ПРИНЯТЬ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: (){
            Navigator.pop(context);
            _showFloatingFlushbar(context);
            setState(() {
              lastRemoved[0] = title[currentPage.round()];
              lastRemoved[1] = currentPage.round();
              lastRemoved[2] = listOfString[currentPage.round()];
              title.removeAt(currentPage.round());
              listOfString.removeAt(currentPage.round());
              _save();
            });
            tap = false;
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  void _onClickRename(){
    Alert(
      context: context,
      title: "Введите новое название",
      content: Column(
        children: <Widget>[
          TextField(
            maxLength: 20,
            controller: controller,
            decoration: InputDecoration(
              labelText: title[currentPage.round()],
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          color: color,
          child: Text(
            "ПРИНЯТЬ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: (){
            setState(() {
              if(controller.text.length != 0){
                title.insert(currentPage.round(), controller.text);
                title.removeAt(currentPage.round()+1);
              }
              _save();
              controller.clear();
            });
            Navigator.pop(context);
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  @override
  void initState() {
    _load();
    super.initState();
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.getStringList('title')!= null){
          setState(() {
            title = prefs.getStringList('title');
            listOfString = prefs.getStringList('list');
      });
    }
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('title', title);
    prefs.setStringList('list', listOfString);
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: title.length - 1);
    void _onClickPage(){
      if(currentPage.round() >= 0 && title.length != 0)
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TrainMenu(currentPage:currentPage.round(),size: MediaQuery.of(context).size)));
    }
    controller.addListener(() {
      setState(() => currentPage = controller.page);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap:_onClickPage,
              child:  Stack(
                children: <Widget>[
                  CardScrollWidget(currentPage),
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: title.length,
                      controller: controller,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _addBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomAppBar()
    );
  }

  Widget _addBtn() => FloatingActionButton(
    onPressed: _onPressedAdd,
    backgroundColor: color,
    tooltip: 'Дабавить',
    child: Icon(Icons.add),
  );

  Widget _bottomAppBar() => BottomAppBar(
    shape: CircularNotchedRectangle(),
    notchMargin: 4.0,
    color: Colors.white,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      IconButton(
        tooltip: 'Удалить',
        icon: Icon(Icons.delete,color: color,),
        onPressed: title.length != 0 ? _onClickDel : null //(){ //titleT.length == 0 ? null : _onClickDelete(currentPage.round(),titleT[currentPage.round()]);}
     ),
      IconButton(
          tooltip: 'Переименовать',
          icon: Icon(Icons.beenhere,color: color,),
          onPressed: title.length != 0 ? _onClickRename : null//(){_onClickReName(currentPage.round());},
      )
      ]
    ),
  );
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;

  CardScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();
        for (var i = 0; i < title.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(3.0, 6.0),
                    blurRadius: 10.0)
                  ]
                 ),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset(image, fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(title[i],
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 20.0,
                                      fontFamily: "SF-Pro-Text-Regular")),
                                ],
                              )
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }

        return Stack(
          children: cardList,
        );
      }),
    );
  }
}