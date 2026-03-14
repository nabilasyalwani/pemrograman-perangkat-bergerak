import 'package:flutter/material.dart';

// 1. Widget class (immutable)
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  // createState() links the widget to its State class
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

// 2. State class (stores mutable data)
class _CounterWidgetState extends State<CounterWidget> {
  // State variable — its value can change
  int _counter = 0;

  // Method to change the state
  void _increment() {
    setState(() {
      // setState() tells Flutter that the state has changed
      // and the widget needs to be rebuilt
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Number of clicks:', style: TextStyle(fontSize: 18.0)),
        Text(
          '$_counter', // Display the value of _counter
          style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _increment, // Call _increment when button is pressed
          child: Text('Add'),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('StatefulWidget Demo')),
        body: Center(child: CounterWidget()),
      ),
    ),
  );
}
