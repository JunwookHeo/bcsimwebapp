import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'nodeinfo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  late NodeInfo _lastNode = NodeInfo();

  List<_ChartData> chartData = <_ChartData>[];
  int count = 0;
  ChartSeriesController? _chartSeriesController;

  @override
  void initState() {
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
                  return showNodeInfo(_lastNode); //Text("no data");
                } else {
                  NodeInfo nodeInfo =
                      NodeInfo.fromJson(json.decode('${snapshot.data}'));
                  print(nodeInfo.size);
                  _updateDataSource(nodeInfo);
                  _lastNode = nodeInfo;
                  return showNodeInfo(nodeInfo); // Text(_lastNode.Timestamp);
                  //return Text(snapshot.hasData ? '${snapshot.data}' : '');
                }
              },
            ),
            const SizedBox(height: 24),
            SfCartesianChart(
                margin: const EdgeInsets.all(50),
                title: ChartTitle(
                    text: 'Blockchain Data Size',
                    //backgroundColor: Colors.lightGreen,
                    //borderColor: Colors.blue,
                    borderWidth: 2,
                    // Aligns the chart title to left
                    alignment: ChartAlignment.center,
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    )),
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.Hms(),
                    majorGridLines: const MajorGridLines(width: 0)),
                primaryYAxis: NumericAxis(
                    title: AxisTitle(
                        text: 'Size[Byte]',
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300)),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0)),
                //series: <LineSeries<_ChartData, DateTime>>[
                series: <CartesianSeries>[
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

  Row showNodeInfo(NodeInfo ni) {
    return (Row(
      children: <Widget>[
        const Expanded(flex: 1, child: Icon(Icons.add_chart)),
        Expanded(flex: 1, child: Text("# Blocks : " + ni.blocks.toString())),
        Expanded(
            flex: 1,
            child: Text("# Transactions : " + ni.transactions.toString())),
        Expanded(
            flex: 1, child: Text("Size : " + ni.size.toString() + "[Byte]")),
        Expanded(
            flex: 1, child: Text("Total Query : " + ni.totalQuery.toString())),
        Expanded(flex: 1, child: Text("Query To : " + ni.queryTo.toString())),
        Expanded(
            flex: 1, child: Text("Query From : " + ni.queryFrom.toString())),
      ],
    ));
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
    chartData.add(_ChartData.fromNodeInfo(_lastNode, ni));
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
    DateTime? timestamp,
    this.size = 0,
    this.networkoverhead = 0,
  }) : this.timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final num size;
  final num networkoverhead;

  factory _ChartData.fromNodeInfo(NodeInfo lni, NodeInfo ni) {
    DateTime t = DateTime.parse(ni.timestamp);
    var no = (ni.totalQuery - lni.totalQuery == 0)
        ? 0
        : (ni.queryFrom - lni.queryFrom) / (ni.totalQuery - lni.totalQuery);

    return _ChartData(timestamp: t, size: ni.size, networkoverhead: no);
  }
}
