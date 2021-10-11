
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> listTrips = [];



  int get taskCount {
    return listTrips.length;
  }

  

  Future getListTrip() async {
    listTrips.clear();
    print('data');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/trips'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {
          final driver = Trip(

            optionDriver: item['optionDriver'],
              description: item['description'],
              id: item['id'],
              status: item['status'],
              readingAtEnd: item['reading_at_end'],
              readingAtStart: item['reading_at_start'],
              terminal: Terminal.fromJson(item['terminal']) ,
              startTime: item['start_time'],
              endTime: item['end_time'],
              tripDate: item['trip_date'],

              customer: Customer.fromJson(item['customer']),
            vehicle: Vehicle.fromJson(item['vehicle']),
            driver: item['driver']!=null ? Driver.fromJson(item['driver']) :null
              );
          listTrips.add(driver);
        }



      }
      print(listTrips);
      notifyListeners();
      return listTrips;
    });

  }
}