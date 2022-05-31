import 'package:flutter/material.dart';

class Shared extends StatefulWidget {
  const Shared({Key key}) : super(key: key);

  @override
  _SharedState createState() => _SharedState();
}

class _SharedState extends State<Shared> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Shared"),
    );
  }
}
