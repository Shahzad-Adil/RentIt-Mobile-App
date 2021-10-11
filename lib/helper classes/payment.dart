
import 'package:rentit_app/helper%20classes/trip.dart';

import 'customer.dart';

class Payment {
  late int id;
  late String paymentMethod;
  late double bill;
  late String description;
  late Customer? customer;
  late Trip? trip;

  Payment(
      {required this.id,
      required this.paymentMethod,
      required this.bill,
      required this.description,
      required this.customer,
      required this.trip});

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentMethod = json['payment_method'];
    bill = json['bill'];
    description = json['description'];
    customer = (json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null)!;
    trip = (json['trip'] != null ? new Trip.fromJson(json['trip']) : null)!;
  }

  Map<String, dynamic> converttoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['payment_method'] = this.paymentMethod;
    data['bill'] = this.bill;
    data['description'] = this.description;
    if (this.customer != null) {
      data['customer'] = this.customer!.convettoJson();
    }
    if (this.trip != null) {
      data['trip'] = this.trip!.converttoJson();
    }
    return data;
  }

  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_method'] = this.paymentMethod;
    data['bill'] = this.bill;
    data['description'] = this.description;
    if (this.customer != null) {
      data['customer'] = this.customer!.convettoJson();
    }
    if (this.trip != null) {
      data['trip'] = this.trip!.converttoJson();
    }
    return data;
  }
}
