import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'Timer.dart';

class TrainMenu extends StatefulWidget {
  @override
  TrainMenu({
    Key key,
    this.currentPage,
    this.size
  }): super(key: key);
  final int currentPage;
  final size;
  _TrainMenuState createState() => _TrainMenuState();
}

class _TrainMenuState extends State<TrainMenu> with TickerProviderStateMixin{
  bool _buttonPressed = false;
  bool _loopActive = false;
  var _listOfArray = [];
  String pickedTime = '00 00';
  String selectedColor = '0xFFFFCA28';
  TextEditingController controllerT = TextEditingController();
  final listKey = GlobalKey<AnimatedListState>();
  List<String> colors = ['0xFFE53935','0xFF607D8B','0xFF66BB6A','0xFFFFCA28','0xFFF57C00','0xFF3949AB','0xFF00E676','0xFF00E5FF','0xFF7E57C2','0xFFFFFFFF','0xFFC6FF00','0xFFD500F9'];
  List<dynamic> countOfTrain() {
    var data = [];
    for(int i = 1; i < _listOfArray.length; i++){
      _listOfArray[i][3] == 'true' ? data.add(i) : null;
    }
    return data;
  }
  void _onSetCountOfLaps(num) async{
    // make sure that only one loop is active
    if (_loopActive) return;
    _loopActive = true;
    int i = 0;
    while (_buttonPressed) {
      i = i + 3 ;
      setState(() {
        int.parse(_listOfArray[0]) + num == 0 ? null :
        int.parse(_listOfArray[0]) + num == 100 ?  null :
        _listOfArray[0] = '${int.parse(_listOfArray[0]) + num}';
      });
      await Future.delayed(Duration(milliseconds: 200 - i));
    }
    _loopActive = false;
  }
  void _showTimePicker(i, show, start){
    Alert(
      context: context,
      title: 'Выставьте время',
      content:  TimePickerSpinner(
        time: show ? null : DateTime(201,2,2,0,int.parse(_listOfArray[i][0].split(' ')[0]),int.parse(_listOfArray[i][0].split(' ')[1])),
        isShowSeconds: true,
        normalTextStyle: TextStyle(
            fontSize: 30,
            color: Colors.grey
        ),
        highlightedTextStyle: TextStyle(
            fontSize: 30,
            color: color
        ),
        spacing: 40,
        itemHeight: 80,
        isForce2Digits: true,
        onTimeChange: (time) {
          setState(() {
            pickedTime = '${time.minute.toString().padLeft(2,'0')} ${time.second.toString().padLeft(2,'0')}';
          });
        },
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
              Navigator.pop(context);
              if(show){
                _listOfArray.add([pickedTime,selectedColor,controllerT.text.length == 0 ? 'Упражнение ${_listOfArray.length}': controllerT.text,'true']);
              } else if(start){
                Navigator.pop(context);
                _listOfArray[i][0] = pickedTime;
                _onClickStart();
              } else {
                _listOfArray[i][0] = pickedTime;
              }
              _save();
            });
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  void _showColorPicker(i,show){
    Alert(
      context: context,
      title: 'Выберете цвет',
      content: _colorPicker(i),
      buttons: [
        DialogButton(
          color: color,
          child: Text(
            "ПРИНЯТЬ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: (){
            Navigator.pop(context);
            if(show){
              _showTimePicker(i,true,false);
            } else {
              setState(() {
                _listOfArray[i][1] = selectedColor;
              });
            }
            _save();
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  void _onPressedAdd(i,show) {
    controllerT.clear();
    Alert(
      context: context,
      title: "Введите название",
      content: Column(
        children: <Widget>[
          TextField(
            maxLength: 15,
            controller: controllerT,
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
            Navigator.pop(context);
            if(show) {
              _showColorPicker(i,true);
            } else {
              Navigator.pop(context);
              controllerT.text.length == 0 ? null : _listOfArray[i][2] = controllerT.text;
              _onPressRebuild(i);
            }
            _save();
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  void _onClickStart(){
    var data = [];
    for(int i = 1;i < _listOfArray.length;i++) {
      if(_listOfArray[i][0] == '00 00' && _listOfArray[i][3] == 'true'){
        data.add(i);
      }
    }
    if(data.length == 0){
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TimerForTrain(listOfArray: _listOfArray,)));
    } else {
      Alert(
        context: context,
        title: 'Ошибка',
        content: Column(
            children: data.map((item) => MaterialButton(
              color: Colors.white,
              child: Text(_listOfArray[item][2],style: TextStyle(color: color,fontSize: 15),),
              onPressed: (){
                _showTimePicker(item, false , true);
              },
            )).toList()
        ),
        buttons: [
          DialogButton(
            color: color,
            child: Text(
              "ЗАКРЫТЬ",
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
  void _onPressRebuild (i){
    Alert(
      context: context,
      title: '${_listOfArray[i][2]}',
      content: Column(
          children: [0,1,2].map((index) => MaterialButton(
            child: Text(index == 0 ? 'Время' : index == 1 ? 'Цвет' : 'Название'),
            color: color,
            onPressed: (){
              index == 0 ? _showTimePicker(i,false,false)
                  : index == 1 ? _showColorPicker(i,false)
                  : _onPressedAdd(i,false);
            },
          )).toList()
      ),
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
      closeFunction: null,
    ).show();
  }
  _load() {
    for(int i = 0; i < listOfString[widget.currentPage].split('.').length;i++){
      if(i == 0) _listOfArray.add(listOfString[widget.currentPage].split('.')[0]);
      else _listOfArray.add(listOfString[widget.currentPage].split('.')[i].split(','));
    }
  }
  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for(int i = 0;i < _listOfArray.length;i++){
      if(i == 0){
        listOfString[widget.currentPage] = '${_listOfArray[0]}';
      } else{
        listOfString[widget.currentPage] += '.${_listOfArray[i][0]},${_listOfArray[i][1]},${_listOfArray[i][2]},${_listOfArray[i][3]}';
      }
    }
    prefs.setStringList('list', listOfString);
  }
  @override
  void initState() {
    super.initState();
      _load();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: countOfTrain().length  == 0 ? Colors.grey : color,
            onPressed:countOfTrain().length == 0 ? null : _onClickStart,
            child: Icon(Icons.play_arrow),
          ),
          bottomNavigationBar: _bottomAppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView(
              physics: ScrollPhysics(),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                          child: Text(
                            'Круги',
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Listener(
                      onPointerDown: (v){
                        _buttonPressed = true;
                        _onSetCountOfLaps(-1);
                      },
                      onPointerUp: (v){
                        _buttonPressed = false;
                        _save();
                      },
                      child: Icon(Icons.remove,color: color,),
                    ),
                    Text(_listOfArray[0],style: TextStyle(color: Colors.black,fontSize: 20),),
                    Listener(
                      onPointerDown: (v){
                        _buttonPressed = true;
                        _onSetCountOfLaps(1);
                      },
                      onPointerUp: (v){
                        _buttonPressed = false;
                        _save();
                      },
                      child: Icon(Icons.add,color: color,),
                    )
                  ],
                ),
                Divider(
                  height: 0.1,
                  color: Colors.black,
                ),
                SizedBox(height: 10,),
                _listOfArray.length-1 == 0 ? SizedBox() :
                ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext content, int index) => _countOfLaps(index),
                          itemCount: _listOfArray.length-1,
                        ),
              ],
            ),
          )
      ),
    );
  }

  Widget _countOfLaps(int i) => Column(
    key: Key(UniqueKey().toString()),
    children: <Widget>[
    Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(UniqueKey().toString()),
      onDismissed: (direction) {
        setState(() {
          _listOfArray.removeAt(i+1);
          _save();
        });
    },
    background: Card(color: Colors.red,child: Align(alignment: Alignment.centerRight,child: Icon(Icons.delete,color: Colors.white,size: 30,)),),
    child: Card(
      elevation: 1,
      child: Column(
        children: <Widget>[
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                  colors: [Color(int.parse(_listOfArray[i+1][1])),Colors.white]
              ),
            ),
          ),
          ListTile(
            leading: Checkbox(
              activeColor: color,
                value: _listOfArray[i+1][3] == 'true',
                onChanged: (v){
                  setState(() {
                    _listOfArray[i+1][3] = v.toString();
                    _save();
                  });
                }
                ),
            trailing: IconButton(
                icon:Icon( Icons.edit,color: color,),
                onPressed: (){_onPressRebuild(i+1);}),
            title: Text(_listOfArray[i+1][2],style: TextStyle(fontSize: 20),),
            subtitle: Text('${_listOfArray[i+1][0].split(' ')[0]}min ${_listOfArray[i+1][0].split(' ')[1]}sec',style: TextStyle(fontSize: 16),),
          )
        ],
      ),
    ),
  ),
      SizedBox(height: 20,)
    ],
  );

  Widget _bottomAppBar() => BottomAppBar(
    color: Colors.white,
    shape: CircularNotchedRectangle(),
    notchMargin: 4.0,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(icon:Icon( Icons.menu,color: color,size:30), onPressed: (){Navigator.of(context).pop();}),
        Row(
          children: <Widget>[
            IconButton(icon:Icon(Icons.add,color: color,size:30), onPressed: (){_onPressedAdd(_listOfArray.length-1,true);},)
          ],
        )
      ],
    ),
  );

  Widget _colorBtn(color,i,setState) => Column(
    children: <Widget>[
      Container(
        height: 40,
        child: MaterialButton(
          shape: CircleBorder(),
          color: Color(int.parse(color)),
          onPressed: (){
            setState(() {
              selectedColor = color;
            });
          },
          child: selectedColor == color ?
          Icon(Icons.check,color: color == '0xFFFFFFFF'  || color == '0xFFC6FF00' ? Colors.black : Colors.white,size: 20,) : SizedBox(),
        ),
      ),
      SizedBox(height: 10,)
    ],
  );

  Widget _colorPicker(i) => StatefulBuilder(builder: (context, setState) {
    return Wrap(
      children: colors.map((el) => _colorBtn(el, i, setState)).toList()
    );
  });
}
