import 'dart:convert';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:tree_view/tree_view.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'node.dart';
import 'nodeview.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/nodes'),
  );

  List<Node> _makeGUINodeList(Map<int, List<Node>> mapNodes) {
    List<Node> nodes = [];
    for (var ns in mapNodes.values) {
      nodes.add(Node(sc: ns[0].sc, isSC: true, childNodes: ns));
      // for (var n in ns) {
      //   nodes.add(n);
      // }
    }
    return nodes;
  }

  List<Widget> _genTreeItems(List<Node> nodes) {
    return nodes.map((node) {
      if (node.isSC) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          child: TreeViewChild(
            parent: StorageClassWidget(sc: node.sc),
            children: _genTreeItems(node.childNodes),
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.only(left: 4.0),
        child: NodeWidget(node: node),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(children: <Widget>[
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                label: const Text("Test Start"),
                icon: const Icon(Icons.web),
                onPressed: _sendStart,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                label: const Text("Test Stop"),
                icon: const Icon(Icons.web),
                onPressed: _sendStop,
              ),
            ),
            const SizedBox(width: 10),
          ]),
          Flexible(
            child: StreamBuilder(
              stream: _channel.stream,
              //builder: (BuildContext context, AsyncSnapshot snapshot) {
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("no data");
                } else if (snapshot.data.toString() == "null\n") {
                  return const Text("no data");
                } else {
                  List<Node> nodes = parseNodes("${snapshot.data}");
                  var nodeMap = nodes.groupListsBy((element) => element.sc);
                  for (var n in nodeMap.values) {
                    n.sort((a, b) => a.hash.compareTo(b.hash));
                  }
                  List<Node> nodesGui = _makeGUINodeList(nodeMap);

                  return TreeView(
                    startExpanded: true,
                    children: _genTreeItems(nodesGui),
                  );
                }
              },
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendStart(){
    _sendMessage(true);
  }

  void _sendStop(){
    _sendMessage(false);
  }

  void _sendMessage(bool start) {
    _channel.sink.add(jsonEncode({"start": start}));
  }
}

class StorageClassWidget extends StatelessWidget {
  final int sc;
  final VoidCallback? onPressedNext;

  const StorageClassWidget({
    Key? key,
    required this.sc,
    this.onPressedNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text("Storage Class " + sc.toString());
    Icon folderIcon = const Icon(Icons.folder);

    IconButton expandButton = IconButton(
      icon: const Icon(Icons.navigate_next),
      onPressed: onPressedNext,
    );

    return Card(
      child: ListTile(
        leading: folderIcon,
        title: titleWidget,
        trailing: expandButton,
        onTap: (() => print("Storage Class " + sc.toString())),
      ),
    );
  }
}

class NodeWidget extends StatelessWidget {
  final Node node;

  const NodeWidget({Key? key, required this.node}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget nodeHashWidget = Text(node.hash);
    Widget ipAddressWidget = Text(
      node.ip + ":" + node.port.toString(),
    );
    Icon fileIcon = const Icon(Icons.insert_drive_file);

    return Card(
      elevation: 0.0,
      child: ListTile(
        leading: fileIcon,
        title: ipAddressWidget,
        subtitle: nodeHashWidget,
        onTap: () {
          print(ipAddressWidget);
          final _addr = node.ip + ":" + node.port.toString();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NodeViewPage(title: _addr)),
          );
        },
      ),
    );
  }
}

List<Node> parseNodes(String data) {
  final parsed = json.decode(data).cast<Map<String, dynamic>>();
  return parsed.map<Node>((json) => Node.fromJson(json)).toList();
}
