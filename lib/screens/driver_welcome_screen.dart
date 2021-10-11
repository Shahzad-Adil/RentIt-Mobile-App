import 'package:flutter/material.dart';
import 'package:rentit_app/component/dri_app_drawer.dart';
import 'package:rentit_app/component/map_widget.dart';

class DriverWelcomeScreen extends StatefulWidget {

  @override
  _DriverWelcomeScreenState createState() => _DriverWelcomeScreenState();
}

class _DriverWelcomeScreenState extends State<DriverWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('RentIt'),
          ),
          // body: Center(child: Text('${user!.email}')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: MapWidget(),
              ),
            ],
          ),
          drawer:
          Container(
            width: 250,
            child: DriAppDrawer(),
          ),
        )
    );
  }
}
