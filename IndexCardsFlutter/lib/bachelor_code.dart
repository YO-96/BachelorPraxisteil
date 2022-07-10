import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(child: Scaffold(body: ChangeColorWithLabel())),
    );
  }
}

class HelloWorldWidget extends StatelessWidget {
  const HelloWorldWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Hello World")));
  }
}

class XAMLExampleWidget extends StatelessWidget {
  const XAMLExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(
      children: [
        Container(
          height: 100,
          color: Colors.blue,
          child: Row(
            children: const [
              Text(
                "Plane Count: 0",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Box Count: 0",
                style: TextStyle(color: Colors.white),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
        ),
        const ARView()
      ],
    )));
  }
}

class ARView extends StatelessWidget {
  const ARView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("ARView"));
  }
}

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(onChanged: (value) {
      print(value);
    });
  }
}

class ChangeColorWidget extends StatefulWidget {
  const ChangeColorWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangeColorWidgetState();
  }
}

class _ChangeColorWidgetState extends State<ChangeColorWidget> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isActive = !_isActive;
        });
      },
      child: Container(
        height: 100,
        width: 100,
        color: _isActive ? Colors.blue : Colors.red,
      ),
    );
  }
}

class ChangeColorWithLabel extends StatefulWidget {
  const ChangeColorWithLabel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangeColorWithLabelState();
  }
}

class _ChangeColorWithLabelState extends State<ChangeColorWithLabel> {
  bool _isActive = false;

  void _onActiveChanged(bool value) {
    setState(() {
      _isActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_isActive ? "Blue" : "Red"),
        StatelessColorChanger(
            isActive: _isActive, onActiveChanged: _onActiveChanged)
      ],
    );
  }
}

class StatelessColorChanger extends StatelessWidget {
  const StatelessColorChanger(
      {Key? key, this.isActive = false, required this.onActiveChanged})
      : super(key: key);
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onActiveChanged(!isActive);
      },
      child: Container(
        height: 100,
        width: 100,
        color: isActive ? Colors.blue : Colors.red,
      ),
    );
  }
}