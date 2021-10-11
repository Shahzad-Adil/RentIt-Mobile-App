
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/company.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> listVehicles = [];

  int get taskCount {
    return listVehicles.length;
  }



  Future getListVehicle() async {
    listVehicles.clear();
    print('-------------------------------------------------------data Vehicle------------------------------------------------');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/vehicles'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {
          final veh = Vehicle(
            id: item['id'],
            modelNumber: item['modelNumber'],
            vRegNo: item['v_reg_no'],
            vMake: item['v_make'],
            vDescription: item['v_description'],
            status: item['status'],
            category: item['category'],
            company: Company.fromJson(item['company']),
            terminal: Terminal.fromJson(item['terminal'])
          );
          listVehicles.add(veh);

        }
      }

      print(listVehicles);
      notifyListeners();
      return listVehicles;
    });
  }
}