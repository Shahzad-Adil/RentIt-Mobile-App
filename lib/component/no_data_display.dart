import 'package:flutter/material.dart';

class NoDataDisplayWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No Data Found',
        style: TextStyle(
          color: Colors.black38,
          fontSize: 30,
        ),
      ),
    );
  }
}