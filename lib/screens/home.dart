import 'dart:convert';
import 'dart:developer';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chainview.dart';
import 'node.dart';
import 'nodeview.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required String title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  get icon => null;

  final _chnodes = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/nodes'),
  );

  final _chcmd = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/command'),
  );

  void _sendTestCommand(String arg1) {
    String msg = jsonEncode(
        {"cmd": "SET", "subcmd": "Test", "arg1": arg1, "arg2": "", "arg3": ""});

    _chcmd.sink.add(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Simulator Server'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  _sendTestCommand("Start");
                  log('Pressed Start Icon');
                },
                icon: const Icon(Icons.not_started)),
            IconButton(
                onPressed: () {
                  _sendTestCommand("Stop");
                  log('Pressed Stop Icon');
                },
                icon: const Icon(Icons.stop_circle)),
            IconButton(
                onPressed: () {
                  log('Pressed Help Icon');
                },
                icon: const Icon(Icons.help))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text('Junwook Heo'),
                accountEmail: const Text('junwookheo@gmail.com'),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('images/trunets.png'),
                  backgroundColor: Colors.white,
                ),
                otherAccountsPictures: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('images/trunets.png'),
                  )
                ],
                onDetailsPressed: () {
                  log('Pressed Details');
                },
                decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0))),
              ),
              const ListTile(
                leading: Icon(Icons.not_started),
                title: Text('Start Test'),
                trailing: Icon(Icons.access_time),
              ),
              const ListTile(
                leading: Icon(Icons.stop_circle),
                title: Text('Stop Test'),
                trailing: Icon(Icons.leave_bags_at_home),
              ),
              const ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
                trailing: Icon(Icons.question_answer),
              )
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: StreamBuilder(
                stream: _chnodes.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("no data");
                  } else if (snapshot.data.toString() == "null\n") {
                    return const Text("no data");
                  } else {
                    List<Node> nodes = parseNodes("${snapshot.data}");
                    nodes.sortBy((element) => element.hash);
                    debugPrint(nodes.toString());

                    return ListView.builder(
                        itemCount: nodes.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          var node = nodes[index];
                          return ListTile(
                              leading: Text('SC${node.sc}'),
                              title: Text('${node.ip}:${node.port}'),
                              subtitle: Text(node.hash),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                final _addr = '${node.ip}:${node.port}';
                                log(_addr);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChainView(title: _addr)),
                                );
                              });
                        });
                  }
                },
              ),
            ),
          ],
        ));
  }
}

List<Node> parseNodes(String data) {
  final parsed = json.decode(data).cast<Map<String, dynamic>>();
  return parsed.map<Node>((json) => Node.fromJson(json)).toList();
}

/*
class MyHomePage2 extends StatefulWidget {
  final String title;

  const MyHomePage2({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePage2State createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage> {
  final _chnodes = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/nodes'),
  );

  final _chcmd = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/command'),
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
              stream: _chnodes.stream,
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

  void _sendStart() {
    _sendMessage("Start");
  }

  void _sendStop() {
    _sendMessage("Stop");
  }

  void _sendMessage(String arg1) {
    String msg = jsonEncode(
        {"cmd": "SET", "subcmd": "Test", "arg1": arg1, "arg2": "", "arg3": ""});

    _chcmd.sink.add(msg);
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
        onTap: (() => log("Storage Class " + sc.toString())),
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
          log(ipAddressWidget.toString());
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
*/