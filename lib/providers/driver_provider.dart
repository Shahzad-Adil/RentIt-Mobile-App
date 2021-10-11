
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';

class DriverProvider extends ChangeNotifier {
  List<Driver> listDrivers = [];




  void updateDriver(int index, Driver driver) {
    listDrivers[index].name = driver.name;
    listDrivers[index].description = driver.description;
    notifyListeners();
  }

  int get taskCount {
    return listDrivers.length;
  }

  UnmodifiableListView<Driver> get tasks {
    return UnmodifiableListView(listDrivers);
  }

  void addDriver(Driver t) {
    listDrivers.add(t);
    notifyListeners();
  }

  void deleteDriver(Driver t) {
    listDrivers.remove(t);
    notifyListeners();
  }

  Future getListDriver() async {
    listDrivers.clear();
    print('-------------------------------------------------data Driver------------------------------------------------');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/drivers'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {
          final driver = Driver(  
              name: item['name'],
              description: item['description'],
              id: item['id'],
              userName: item['userName'],
              password: item['password'],
              email: item['email'],
              cnic: item['cnic'],
              phone: item['phone'],
              driverOnTrip: item['driver_on_trip'],
              terminal: item['terminal'] != null ? Terminal.fromJson(item['terminal'])
                  : null);
          listDrivers.add(driver);
        }
        print('list $listDrivers');
        print(listDrivers.length);
      }
      for(var a in listDrivers)
      {
        print(a.name);
      }
      print(listDrivers.length);

      notifyListeners();
      return listDrivers;
    });
  }
}