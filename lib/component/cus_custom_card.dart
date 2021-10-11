import 'package:flutter/material.dart';
import 'package:rentit_app/component/request_details_container.dart';

class CusCustomCard extends StatelessWidget {
  const CusCustomCard(
      {
         required this.terminal,
         required this.category,
         required this.vehicle,
         required this.isDriver,
         required this.text,

        required this.status});

  final String terminal;
  final String category;
  final String vehicle;
  final bool isDriver;
  final String text;
  final  String status ;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shadowColor: Colors.black12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.indigo, fontSize: 30),
                  ),
                ),
                subtitle:  RequestDetailsContainer(
                    terminal: terminal,
                    category: category,
                    vehicle: vehicle,
                    isDriver: isDriver,
                  status: status,),
                trailing: status == 'cancelled' ? const Icon(Icons.cancel,color: Colors.red,) :
                status == 'pending' ? const Icon(Icons.pending,color: Colors.blue,)  :
                status == 'completed' ? const  Icon(Icons.stars,color: Colors.yellow,):
                status == 'current' ?   const Icon(Icons.adjust,color: Colors.green,): null ,
                tileColor: Colors.white60.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }


}