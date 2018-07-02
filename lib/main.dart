import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  final _chartSize = const Size(250.0, 250.0);

  Color labelColor = Colors.blue;

  List<CircularStackEntry> _generateChartData(int min, int second) {
    double temp = second * 0.6;
    double adjustedSeconds = second + temp;

    double tempmin = min * 0.6;
    double adjustedMinutes = min + tempmin;

    Color dialColor = Colors.blue;

    labelColor = dialColor;

    List<CircularStackEntry> data = [
      new CircularStackEntry(
          [new CircularSegmentEntry(adjustedSeconds, dialColor)])
    ];

    if (min > 0) {
      labelColor = Colors.green;
      data.removeAt(0);
      data.add(new CircularStackEntry(
          [new CircularSegmentEntry(adjustedSeconds, dialColor)]));
      data.add(new CircularStackEntry(
          [new CircularSegmentEntry(adjustedMinutes, Colors.green)]));
    }

    return data;
  }

  Stopwatch watch = new Stopwatch();
  Timer timer;

  String elapsedTime = '';

  updateTime(Timer timer) {
    if (watch.isRunning) {
      var milliseconds = watch.elapsedMilliseconds;
      int hundreds = (milliseconds / 10).truncate();
      int seconds = (hundreds / 100).truncate();
      int minutes = (seconds / 60).truncate();
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
        if (seconds > 59) {
          seconds = seconds - (59 * minutes);
          seconds = seconds - minutes;
        }
        List<CircularStackEntry> data = _generateChartData(minutes, seconds);
        _chartKey.currentState.updateData(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _labelStyle = Theme
        .of(context)
        .textTheme
        .title
        .merge(new TextStyle(color: labelColor));
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text('StopWatch'),
        ),
        body: new Container(
            padding: EdgeInsets.all(20.0),
            child: new Column(
              children: <Widget>[
                // new Text(elapsedTime, style: new TextStyle(fontSize: 25.0)),
                new Container(
                  child: new AnimatedCircularChart(
                    key: _chartKey,
                    size: _chartSize,
                    initialChartData: _generateChartData(0, 0),
                    chartType: CircularChartType.Radial,
                    edgeStyle: SegmentEdgeStyle.round,
                    percentageValues: true,
                    holeLabel: elapsedTime,
                    labelStyle: _labelStyle,
                  ),
                ),
                SizedBox(height: 20.0),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new FloatingActionButton(
                        backgroundColor: Colors.green,
                        onPressed: startWatch,
                        child: new Icon(Icons.play_arrow)),
                    SizedBox(width: 20.0),
                    new FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: stopWatch,
                        child: new Icon(Icons.stop)),
                    SizedBox(width: 20.0),
                    new FloatingActionButton(
                        backgroundColor: Colors.blue,
                        onPressed: resetWatch,
                        child: new Icon(Icons.refresh)),
                  ],
                )
              ],
            )));
  }

  startWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 1000), updateTime);
  }

  stopWatch() {
    watch.stop();
    setTime();
  }

  resetWatch() {
    watch.reset();
    setTime();
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
      List<CircularStackEntry> data = _generateChartData(0, 0);
      _chartKey.currentState.updateData(data);
    });
  }

  transformMilliSeconds(int milliseconds) {
    //Thanks to Andrew
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }
}
