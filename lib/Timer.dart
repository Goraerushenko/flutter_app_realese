import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'data.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
class TimerForTrain extends StatefulWidget {
  @override
  TimerForTrain({
    Key key,
    this.listOfArray,
  }): super(key: key);
  final listOfArray;
  @override
  _TimerForTrainState createState() => _TimerForTrainState();
}

class _TimerForTrainState extends State<TimerForTrain>
    with TickerProviderStateMixin, WidgetsBindingObserver{
  int i = 0;
  int j = 0;
  DateTime time;
  int lastSecond = 0;
  Duration duration = Duration(seconds: 9);
  AudioCache  player = AudioCache();
  AnimationController controller;
  AnimationController iconController;
  final alarmAudioPath = "endOfTrain.mp3";
  String get timerString {
    Duration durations = controller.duration * controller.value;
    if(durations.inSeconds+1 == lastSecond && lastSecond < 5) Vibration.vibrate(amplitude: 50,duration: 100);
    lastSecond = durations.inSeconds;
    return '${durations.inMinutes}:${(durations.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  String get _color {
    return i == 0 ? widget.listOfArray[i+1][1] : widget.listOfArray[i][1];
  }
  Future<bool> _exitTimer(BuildContext context) {
    controller.stop();
    iconController.reverse();
    return Alert(
      context: context,
      type: AlertType.warning,
      title: 'Вы уверены, что хотите прервать тренировку?',
      buttons: [
        DialogButton(
          color: color,
          child: Text(
            "ПРИНЯТЬ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: (){
            Navigator.pop(context);
            Navigator.of(context).pop(true);
          },
          width: MediaQuery.of(context).size.width - 150,
        )
      ],
      closeFunction: (){
        controller.reverse(
            from: controller.value == 0.0
                ? 1.0
                : controller.value);
        iconController.forward();
      }
    ).show();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      time = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (controller.isAnimating) {
        double data = DateTime
            .now()
            .difference(time)
            .inSeconds
            .toDouble();
        for (int h = j; h < int.parse(widget.listOfArray[0]); h++) {
          for (int g = i; g < widget.listOfArray.length; g++) {
            int currentTime = (int.parse(
                widget.listOfArray[g][0].split(' ')[0]) * 60 +
                int.parse(widget.listOfArray[g][0].split(' ')[1]));
            if (g == i && h == j) {
              data = data - currentTime * (controller.value * 100) / 100;
            } else {
              data = data - currentTime;
            }
            if (data < 0) {
              controller.value = (-data / currentTime * 100) / 100;
              i = g;
              j = h;
              setState(() {
                controller.duration = Duration(
                    minutes: int.parse(widget.listOfArray[i][0].split(' ')[0]),
                    seconds: int.parse(widget.listOfArray[i][0].split(' ')[1]));
                controller.reverse(
                    from: controller.value == 0.0
                        ? 1.0
                        : controller.value);
              });
              h = int.parse(widget.listOfArray[0]);
              g = widget.listOfArray.length;
            }
          }
        }
        print(data);
      }
    }
    print('state = $state');
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    iconController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    controller.addListener((){
      if( controller.value == 0){
        if( i+1 < widget.listOfArray.length) {
          i++;
          while(widget.listOfArray[i][3] == 'false'){
            i++;
          }
          player.play("startAndbetween.mp3");
          duration = Duration(minutes: int.parse( widget.listOfArray[i][0].split(' ')[0]),seconds: int.parse( widget.listOfArray[i][0].split(' ')[1]),);
          controller.duration = duration;
          controller.value = 1;
          controller.reverse(from: 1);
        } else if(j+1 < int.parse( widget.listOfArray[0])) {
          j++;
          i = 1;
          duration = Duration(minutes: int.parse( widget.listOfArray[i][0].split(' ')[0]),seconds: int.parse( widget.listOfArray[i][0].split(' ')[1]),);
          controller.duration = duration;
          controller.value = 1;
          controller.reverse(from: 1);
        } else {
          player.play(alarmAudioPath);
          Vibration.vibrate(amplitude: 128,duration: 1000);
          Navigator.pop(context);
          iconController.reverse();
        }
      }
    });
    controller.reverse(from: 0);
    iconController.forward();
    iconController.forward();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitTimer(context),
        child: Scaffold(
          primary: true,
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: (){
              Vibration.vibrate(duration: 100, amplitude: 100);
              if (controller.isAnimating){
                controller.stop();
                iconController.reverse();
              }
              else {
                controller.reverse(
                    from: controller.value == 0.0
                        ? 1.0
                        : controller.value);
                iconController.forward();
              }
            },
            child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: iconController
            ),
          ),
          body: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child:
                      Container(
                        color: Color(int.parse(_color)),
                        height: controller.value * MediaQuery.of(context).size.height,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: FractionalOffset.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                i == 0 ? widget.listOfArray[i+1][2] : widget.listOfArray[i][2],
                                                style: TextStyle(
                                                    fontSize: 40.0,
                                                    color: _color == '0xFFC6FF00'  ? color : _color == '0xFFFFFFFF' ? color : Colors.white),
                                              ),
                                              Text(
                                                'Круг: ${j+1}/${ widget.listOfArray[0]}',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color:_color == '0xFFC6FF00' ? color : _color == '0xFFFFFFFF' ? color : Colors.white
                                                ),
                                              ),
                                            ],
                                          ),
                                          AnimatedBuilder(
                                              animation: controller,
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return Text(
                                                  timerString,
                                                  style: TextStyle(
                                                      fontSize: 112.0,
                                                      color: _color == '0xFFC6FF00' ? color : _color == '0xFFFFFFFF' ? color : Colors.white),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        )
    );
  }
}