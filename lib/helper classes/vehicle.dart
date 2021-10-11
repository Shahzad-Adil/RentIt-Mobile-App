
import 'package:rentit_app/helper%20classes/terminal.dart';

import 'company.dart';

class Vehicle {
  late int id;
  late String vRegNo;
  late String modelNumber;
  late String category;
  late bool status;
  late String vMake;
  late String vDescription;
  late Company company;
  late Terminal terminal;

  Vehicle(
      {required this.id,
        required this.vRegNo,
        required this.modelNumber,
        required this.category,
        required this.status,
        required this.vMake,
        required this.vDescription,
        required this.company,
        required this.terminal});

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vRegNo = json['v_reg_no'];
    modelNumber = json['modelNumber'];
    category = json['category'];
    status = json['status'];
    vMake = json['v_make'];
    vDescription = json['v_description'];
    company =
    (json['company'] != null ? new Company.fromJson(json['company']) : null)!;
    terminal = (json['terminal'] != null
        ? new Terminal.fromJson(json['terminal'])
        : null)!;
  }



  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['v_reg_no'] = this.vRegNo;
    data['modelNumber'] = this.modelNumber;
    data['category'] = this.category;
    data['status'] = this.status;
    data['v_make'] = this.vMake;
    data['v_description'] = this.vDescription;
    if (this.company != null) {
      data['company'] = this.company.convertoJson();
    }
    if (this.terminal != null) {
      data['terminal'] = this.terminal.convetoJson();
    }
    return data;
  }

  Map<String, dynamic> converttoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['v_reg_no'] = this.vRegNo;
    data['id'] = this.id;
    data['modelNumber'] = this.modelNumber;
    data['category'] = this.category;
    data['status'] = this.status;
    data['v_make'] = this.vMake;
    data['v_description'] = this.vDescription;
    if (this.company != null) {
      data['company'] = this.company.convertoJson();
    }
    if (this.terminal != null) {
      data['terminal'] = this.terminal.convettoJson();
    }
    return data;
  }
}

