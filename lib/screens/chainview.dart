import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChainView extends StatefulWidget {
  const ChainView({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<ChainView> createState() => _ChainViewState();
}

class _ChainViewState extends State<ChainView> {
  late final WebSocketChannel? _chchain;

  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();

  late BlockInfo lastBlock = BlockInfo();

  @override
  void initState() {
    _chchain = WebSocketChannel.connect(
      Uri.parse('ws://' + widget.title + "/chaininfo"),
    );

    Node node1 = Node.Id('Start');
    graph.addNode(node1);

    _builder
      ..siblingSeparation = (10)
      ..levelSeparation = (15)
      ..subtreeSeparation = (15)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_BOTTOM_TOP);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            final node12 = Node.Id('$r');
            try {
              // var edge = graph.getNodeAtPosition(r - 1);
              var n = graph.getNodeUsingId('Start');
              debugPrint('$r : ' + graph.nodeCount().toString());
              debugPrint('$r : ' + n.toString());
              // graph.addEdge(edge, node12);
              graph.addEdge(n, node12);
              r++;
              setState(() {});
            } on StateError catch (e) {
              debugPrint(e.toString());
            }
          },
          child: const Text("Add"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {});
          },
          child: const Text("set State"),
        ),
        // Expanded(
        //   child: InteractiveViewer(
        //       constrained: false,
        //       boundaryMargin: const EdgeInsets.all(1000),
        //       minScale: 0.1, //0.01,
        //       maxScale: 1.0, //5.6,
        //       child: GraphView(
        //         graph: graph,
        //         algorithm: BuchheimWalkerAlgorithm(
        //             _builder, TreeEdgeRenderer(_builder)),
        //         paint: Paint()
        //           ..color = Colors.black
        //           ..strokeWidth = 1
        //           ..style = PaintingStyle.stroke,
        //         builder: (Node node) {
        //           var a = node.key!.value as String;
        //           return rectangleWidget(a);
        //         },
        //       )),
        // ),
        StreamBuilder(
          stream: _chchain!.stream,
          // builder: (BuildContext context, AsyncSnapshot snapshot) {
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("no data");
            } else {
              debugPrint('${snapshot.data}');
              Map<String, dynamic> userMap = jsonDecode('${snapshot.data}');
              var block = BlockInfo.fromJson(userMap);
              debugPrint("current block : " + block.hash);
              debugPrint("last block : " + lastBlock.hash);

              if (graph.nodeCount() == 1) {
                if (lastBlock.hash != "" && lastBlock.hash == block.prev) {
                  // Add fist two block to the graph : lastBlock and block
                  try {
                    final Node node1 = Node.Id(lastBlock.hash);
                    final Node node2 = Node.Id(block.hash);

                    var pre = graph.getNodeUsingId("Start");
                    graph.addEdge(pre, node1);
                    graph.addEdge(node1, node2);
                    // setState(() {});
                  } on StateError catch (e) {
                    debugPrint(e.toString());
                  }
                }
              } else {
                try {
                  var pre = graph.getNodeUsingId(block.prev);
                  final Node node = Node.Id(block.hash);
                  graph.addEdge(pre, node);
                  // setState(() {});
                } on StateError catch (e) {
                  debugPrint(e.toString());
                }
              }
              lastBlock = block;
              return expandedWidget();
            }
          },
        ),
      ]),
    );
  }

  Widget expandedWidget() {
    return Expanded(
      child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(1000),
          minScale: 0.1, //0.01,
          maxScale: 1.0, //5.6,
          child: GraphView(
            graph: graph,
            algorithm:
                BuchheimWalkerAlgorithm(_builder, TreeEdgeRenderer(_builder)),
            paint: Paint()
              ..color = Colors.black
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              var a = node.key!.value as String;
              return rectangleWidget(a);
            },
          )),
    );
  }

  var r = 0;
  Widget rectangleWidget(String a) {
    return InkWell(
      onTap: () {
        debugPrint('clicked  $a');
      },
      child: Container(
          width: 80,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Colors.blue, spreadRadius: 1),
            ],
          ),
          child: Text(a, overflow: TextOverflow.ellipsis)),
    );
  }
}

class BlockInfo {
  final int height;
  final int timestamp;
  final String hash;
  final String prev;

  BlockInfo(
      {this.height = -1, this.timestamp = 0, this.hash = "", this.prev = ""});

  BlockInfo.fromJson(Map<String, dynamic> json)
      : height = json['Height'],
        timestamp = json['Timestamp'],
        hash = json['Hash'],
        prev = json['Prev'];
}
