import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'nodeinfo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class NodeViewPage extends StatefulWidget {
  const NodeViewPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NodeViewState createState() => _NodeViewState();
}

class _NodeViewState extends State<NodeViewPage> {
  late final WebSocketChannel? channel;
  late TooltipBehavior _tooltipBehavior;

  List<_ChartData> chartData = <_ChartData>[
  ];
  int count = 0;
  ChartSeriesController? _chartSeriesController;

  @override
  void initState() {
    // TODO: implement initState
    channel = WebSocketChannel.connect(
      Uri.parse('ws://' + widget.title + "/nodeinfo"),
    );
    _tooltipBehavior = TooltipBehavior(enable: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            StreamBuilder(
              stream: channel!.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("no data");
                } else {
                  NodeInfo nodeInfo = NodeInfo.fromJson(json.decode('${snapshot.data}'));
                  _updateDataSource(nodeInfo);
                  return Text(nodeInfo.Timestamp);
                  //return Text(snapshot.hasData ? '${snapshot.data}' : '');
                }
              },
            ),
            SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis:
                  DateTimeAxis(dateFormat: DateFormat.Hms(), majorGridLines: const MajorGridLines(width: 0)),
                primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0)),
                series: <LineSeries<_ChartData, DateTime>>[
                  LineSeries<_ChartData, DateTime>(
                    onRendererCreated: (ChartSeriesController controller) {
                      _chartSeriesController = controller;
                    },
                    dataSource: chartData,
                    color: const Color.fromRGBO(192, 108, 132, 1),
                    xValueMapper: (_ChartData ni, _) => ni.timestamp,
                    yValueMapper: (_ChartData ni, _) => ni.size,
                    animationDuration: 0,
                  )
                ]),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    channel!.sink.add("test");
  }

  @override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }

  void _updateDataSource(NodeInfo ni) {
      chartData.add(_ChartData.fromNodeInfo(ni));
      if (chartData.length == 200) {
        chartData.removeAt(0);
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
          removedDataIndexes: <int>[0],
        );
      } else {
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
        );
      }
      count = count + 1;
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min);
  }
}

class _ChartData {
  _ChartData({
    DateTime ? timestamp,
    this.size = 0,
  }): this.timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final num size;

  factory _ChartData.fromNodeInfo(NodeInfo ni){
    DateTime t = DateTime.parse(ni.Timestamp);
    return _ChartData(timestamp:t, size:ni.Size);
  }
}