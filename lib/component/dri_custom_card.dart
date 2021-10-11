import 'package:flutter/material.dart';

import 'dri_details_container.dart';

class DriCustomCard extends StatelessWidget {
  const DriCustomCard(
      {
      required this.category,
      required this.vehicle,
      required this.status,
      required this.fromTerminal,
      required this.cusEmail,
      required this.text});

  final String fromTerminal;

  final String category;
  final String vehicle;
  final String cusEmail;

  final String status;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shadowColor: Colors.black12,
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.blue, fontSize: 30),
                  ),
                ),
                subtitle: DriDetailsContainer(
                  fromTerminal: fromTerminal,
                    category: category,
                    vehicle: vehicle,
                    cusEmail: cusEmail,
                    ),
                // trailing:
                // status == 'completed' ?   Icon(Icons.stars,color: Colors.yellow,):
                // status == 'current' ?   Icon(Icons.adjust,color: Colors.green,): null ,
                tileColor: Colors.white60.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
