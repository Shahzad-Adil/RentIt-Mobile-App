

import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';

import 'customer.dart';
import 'driver.dart';

class Trip {
  late int id;
  late String tripDate;
  late String startTime;
  late String endTime;
  late double readingAtStart;
  late double readingAtEnd;
  late String description;
  late bool optionDriver;
  late String status;
  late Vehicle? vehicle;
  late Driver? driver;
  late  Terminal? terminal;

  late Customer? customer;

  Trip(
      {required this.id,
      required this.tripDate,
      required this.startTime,
      required this.endTime,
      required this.readingAtStart,
      required this.readingAtEnd,
      required this.description,
      required this.status,
      required this.vehicle,
      required this.driver,
      required this.customer,
        required this.terminal,
      required this.optionDriver});

  Trip.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tripDate = json['trip_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    readingAtStart = json['reading_at_start'];
    readingAtEnd = json['reading_at_end'];
    description = json['description'];
    status = json['status'];
    optionDriver=json['optionDriver'];
    vehicle =
        (json['vehicle'] != null ?  Vehicle.fromJson(json['vehicle']) : null)!;
    driver =
        (json['driver'] != null ?  Driver.fromJson(json['driver']) : null)!;
    customer = (json['customer'] != null
        ?  Customer.fromJson(json['customer'])
        : null)!;
    terminal = (json['terminal'] != null
        ?  Terminal.fromJson(json['terminal'])
        : null)!;
  }


  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trip_date'] = this.tripDate;
    data['start_time'] =this.startTime;
    data['end_time'] =this.endTime;
    data['reading_at_start'] = this.readingAtStart;
    data['reading_at_end'] = this.readingAtEnd;
    data['status'] = this.status;
    data['description'] = this.description;
    data['optionDriver'] = this.optionDriver;
    data['status'] = this.status;
    data['vehicle'] = this.vehicle!.converttoJson();
    data['customer'] = this.customer!.convettoJson();
    data['terminal']=this.terminal!.convettoJson();
    data['driver']=this.driver==null?null: this.driver!.converttoJson();
    return data;
  }

  Map<String, dynamic> converttoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['trip_date'] = this.tripDate;
    data['start_time'] =this.startTime;
    data['end_time'] =this.endTime;
    data['reading_at_start'] = this.readingAtStart;
    data['reading_at_end'] = this.readingAtEnd;
    data['status'] = this.status;
    data['description'] = this.description;
    data['optionDriver'] = this.optionDriver;
    data['status'] = this.status;
    data['vehicle'] = this.vehicle!.converttoJson();
    data['customer'] = this.customer!.convettoJson();
    data['terminal']=this.terminal!.convettoJson();
    data['driver']=this.driver==null?null: this.driver!.converttoJson();
    return data;
  }



}
