
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/customer.dart';



class CustomerProvider extends ChangeNotifier {
  List<Customer> listCustomer = [];

  void updateTerminal(int index, Customer customer) {
    listCustomer[index].name = customer.name;
    listCustomer[index].description = customer.description;
    notifyListeners();
  }

  int get taskCount {
    return listCustomer.length;
  }

  UnmodifiableListView<Customer> get tasks {
    return UnmodifiableListView(listCustomer);
  }

  void addTerminal(Customer t) {
    listCustomer.add(t);
    notifyListeners();
  }

  void deleteTerminal(Customer t) {
    listCustomer.remove(t);
    notifyListeners();
  }

  Future getListCustomer() async {
    listCustomer.clear();
    print('------------------------------------------------------------data Customer----------------------------------------------');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/customers'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {

          final customerr = Customer(
              userName: item['userName'],
              password: item['password'],
              email: item['email'],
              cnic: item['cnic'],
              phone: item['phone'],
              name: item['name'],
              description: item['description'],
              id: item['id']);
          listCustomer.add(customerr);
        }
        for(var a in listCustomer)
          {
            print(a.name);
          }
        print(listCustomer.length);

      }

      notifyListeners();
      return listCustomer;
    });
  }
}