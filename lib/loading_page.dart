import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Text(
            "loading...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class LoadingContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("loading...", style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
