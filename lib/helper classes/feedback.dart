import 'package:rentit_app/helper%20classes/vehicle.dart';

import 'customer.dart';

class Feedbackk {
  late int id;
  late String description;
  late int rating;
  late Customer? customer;
  late Vehicle? vehicle;

  Feedbackk(
      {required this.id, required this.description, required this.rating, required this.customer, required this.vehicle});

  Feedbackk.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    rating = json['rating'];
    customer = (json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null)!;
    vehicle =
    (json['vehicle'] != null ? new Vehicle.fromJson(json['vehicle']) : null)!;
  }

  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['rating'] = this.rating;
    if (this.customer != null) {
      data['customer'] = this.customer!.convettoJson();
    }
    if (this.vehicle != null) {
      data['vehicle'] = this.vehicle!.converttoJson();
    }
    return data;
  }



  Map<String, dynamic> converttoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['rating'] = this.rating;

      data['customer'] = this.customer!.convettoJson();


      data['vehicle'] = this.vehicle!.converttoJson();

    return data;
  }
}







