import 'dart:async';
import 'dart:convert';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  Widget _buildListTile(List<ListItem> items, int index) {
    final item = items[index];

    return ListTile(
      title: item.buildTitle(context),
      subtitle: item.buildSubtitle(context),
    );
  }

  List<ListItem> _genListItems(Map<int, List<Node>> mapNodes) {
    List<ListItem> listitems = [];
    for (var ns in mapNodes.values) {
      listitems.add(HeadingItem(ns[0].sc));
      for (var n in ns) {
        listitems.add(NodeItem(n));
      }
    }
    return listitems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(children: <Widget>[
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                label: const Text("Test Start"),
                icon: const Icon(Icons.web),
                onPressed: _sendMessage,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                label: const Text("Test Stop"),
                icon: const Icon(Icons.web),
                onPressed: _sendMessage,
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
                  List<ListItem> listitems = _genListItems(nodeMap);

                  return ListView.builder(
                    itemCount: listitems.length,
                    itemBuilder: (context, index) =>
                        _buildListTile(listitems, index),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    _channel.sink.add(jsonEncode({"start": false}));
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);

  Widget buildSubtitle(BuildContext context);
}

class HeadingItem implements ListItem {
  final int sc;

  HeadingItem(this.sc);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      "Storage Class : " + sc.toString(),
      style: Theme.of(context).textTheme.headline6,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

class NodeItem implements ListItem {
  final Node node;
  NodeItem(this.node);

  @override
  Widget buildTitle(BuildContext context) =>
      Text(node.ip + ":" + node.port.toString());

  @override
  Widget buildSubtitle(BuildContext context) => Text(node.hash);
}

List<Node> parseNodes(String data) {
  final parsed = json.decode(data).cast<Map<String, dynamic>>();
  return parsed.map<Node>((json) => Node.fromJson(json)).toList();
}

class Node {
  final String mode;
  final int sc;
  final String ip;
  final int port;
  final String hash;

  Node(
      {this.mode = "",
      this.sc = 0,
      this.ip = "",
      this.port = 0,
      this.hash = ""});

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      mode: json['mode'] as String,
      sc: json['storage_class'] as int,
      ip: json['ip'] as String,
      port: json['port'] as int,
      hash: json['hash'] as String,
    );
  }
}
