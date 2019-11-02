import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String pickedTime = '00 00';
  void _showInfo(){
    Alert(
      context: context,
      type: AlertType.info,
      title: 'Справка',
      content: Center(
          child: Text('Стандартное время - это минута и секунда, которые будут выставлены в выборе времени для тренировки по умолчанию')
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
    ).show();
  }
  void _showTimePicker(){
    Alert(
      context: context,
      title: 'Выставьте время',
      content:  TimePickerSpinner(
        time: DateTime(201,2,2,0,int.parse(standardTime.split(' ')[0]),int.parse(standardTime.split(' ')[1])),
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
              standardTime = pickedTime;
            });
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
    ).show();
  }
  @override
  void initState() {
    super.initState();
  }
  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: null,
        child: Icon(Icons.save),
      ),
      bottomNavigationBar:_bottomAppBar(),
      body: _body(),
    );
  }
  Widget _body() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView(
        physics: ScrollPhysics(),
        children: <Widget>[
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
              child: Text(
                'Язык',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButton(
              value: dropdownValue,
              items: <String>['Русский', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (v){
                setState(() {
                  dropdownValue = v;
                });
              },
            ),
          ]
         ),
          _line(),
          Card(
            elevation: 1,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: IconButton(icon: Icon(Icons.info),color: color, onPressed: _showInfo),
                  trailing: IconButton(icon: Icon(Icons.edit),color: color, onPressed: _showTimePicker),
                  title: Text(
                    'Станд. время',
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${standardTime.split(' ')[0]}min ${standardTime.split(' ')[1]}sec',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )
                )
              ],
            ),
          ),
          _line(),
       ]
      )
     );
  Widget _line() => Divider(
    height: 1,
    color: Colors.black,
  );
  Widget _bottomAppBar() => BottomAppBar(
    color: Colors.white,
    shape: CircularNotchedRectangle(),
    notchMargin: 4.0,
    child: Row (
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(icon: Icon( Icons.menu,color: color,size:30), onPressed: (){Navigator.of(context).pop();}),
        IconButton(icon: Icon(Icons.replay,color: color,size:30), onPressed: (){},)
      ],
    ),
  );
}
