import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {


  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner();
        });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
            key: key,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Column(children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text("Please Wait....",style: TextStyle(color: Colors.blueAccent),)
                ]),
              )
            ]));
  }
}

