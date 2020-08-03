import 'package:flutter/material.dart';

class ContainerTest extends StatefulWidget {
  @override
  ContainerTestState createState() => ContainerTestState();
}

class ContainerTestState extends State<ContainerTest> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Note that the editor requires special `ZefyrScaffold` widget to be
    // one of its parents.
    return Scaffold(
      appBar: AppBar(title: Text("Editor page")),
      body: GestureDetector(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                child: Text('Contaner:Padding'),
                decoration: new BoxDecoration(
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              width: 414,
              decoration: new BoxDecoration(
                color: Colors.grey,
              ),
              padding: EdgeInsets.all(20),
              child: Text('Contaner:Padding'),
            ),
          ],
        ),
      ),
    );
  }
}
