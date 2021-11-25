import 'package:bcsimapp/screens/list_view.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        const SizedBox(height: 24),
        StreamBuilder(
          stream: _channel.stream,
          builder: (context, snapshot) {

            print(snapshot.data);
            List<Node> nodes = parseNodes('${snapshot.data}');
            print(nodes[0].hash);

            return Text(snapshot.hasData ? '${snapshot.data}' : '');
          },
        )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
      _channel.sink.add(
          jsonEncode(
          {
            "start": false
          }
          )
    );
  }
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

  Node({this.mode ="", this.sc=0, this.ip="", this.port=0, this.hash=""});

  // 사진의 정보를 포함하는 인스턴스를 생성하여 반환하는 factory 생성자
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