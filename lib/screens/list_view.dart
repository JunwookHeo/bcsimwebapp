import 'package:flutter/material.dart';

class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("hello!"),
        ),
        body: ListView(scrollDirection: Axis.vertical, children: <Widget>[
          ListTile(
            leading: Icon(Icons.home),
            title: Text("one"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.access_alarm),
            title: Text("two"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text("three"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
        ]));
  }
}
