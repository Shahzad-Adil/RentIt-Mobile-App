
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/payment.dart';
import 'package:rentit_app/helper%20classes/trip.dart';



class PaymentProvider extends ChangeNotifier {
  List<Payment> listPayments = [];

  int get taskCount {
    return listPayments.length;
  }

  UnmodifiableListView<Payment> get tasks {
    return UnmodifiableListView(listPayments);
  }

  Future getListPayment() async {
    listPayments.clear();
    print('data');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/payments'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {

          final payment = Payment(
            id: item['id'],
            description: item['description'],
            paymentMethod: item['payment_method'],
            bill: item['bill'],
            customer: Customer.fromJson(item['customer']),
            trip: Trip.fromJson(item['trip']),
          );

          listPayments.add(payment);
        }

        print('------------------------------------------------${listPayments.length}');

      }

      notifyListeners();
      return listPayments;
    });
  }
}