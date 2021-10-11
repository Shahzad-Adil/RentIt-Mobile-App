import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as Http;
import 'package:rentit_app/component/rounded_button.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/payment.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/providers/current_variable_provider.dart';
import 'package:rentit_app/providers/payment_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';
import 'my_dashboard.dart';

class PaymentScreen extends StatefulWidget {
  //static final String id = 'PaymentScreen';

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Payment> listPayments = [];
  List<Trip> listTrips = [];
  late Trip trip= Trip(
      id: -1,
      terminal: null,
      description: 'null',
      driver: null,
      optionDriver: false,
      tripDate: 'null',
      endTime: 'null',
      startTime: 'null',
      customer: null,
      readingAtEnd: 0.0,
      readingAtStart: 0.0,
      status: 'up',
      vehicle: null);

  final _auth = FirebaseAuth.instance;

  double fare = 0.0;

  final int fairConstant = 100;

  bool _isLoading = false;

  bool isDriver = false;

  String paymentMethod = 'cash';

  void sendData(Map<String, dynamic> abc) async {
    print(abc['customer']['name']);

    return await Http.post(Uri.parse('$kIpAddress:7070/api/payments'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(abc))
        .then((value) {
      if (value.statusCode == 200) {
        final dataString = jsonDecode(value.body);
        final int val = dataString['id'];

        print('true');
        return val;
      } else {
        print(value.statusCode);
        print(
            '-----------------------------------------------------------------------');
        print('eroor sending the whole Data');
        return -1;
      }
    });
  }

  void updateVehicle() async {
    trip.vehicle!.status = true;
    Map<String, dynamic> mapUpdate = trip.vehicle!.converttoJson();

    print('data');
    return await Http.put(Uri.parse('$kIpAddress:7070/api/vehicles'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(mapUpdate))
        .then((value) {
      if (value.statusCode == 200) {
        print('true');
      } else {
        print(value.statusCode);
        print(value.body);
        print('error sending the whole Data');
      }
      return;
    });
  }

  void updateTrip() async {
    Map<String, dynamic> mapUpdate = trip.converttoJson();

    print('data');
    return await Http.put(Uri.parse('$kIpAddress:7070/api/trips'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(mapUpdate))
        .then((value) {
      if (value.statusCode == 200) {
        print('true');
      } else {
        print(value.statusCode);
        print(value.body);
        print('error sending the whole Data');
      }
      return;
    });
  }

  void changeStatus() async {
    setState(() {
      trip.status = 'end';
    });

    trip.endTime =
        '${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}';
    updateTrip();
  }

  void updateList() async {
    User? user = _auth.currentUser;

     listTrips= await Provider.of<TripProvider>(context, listen: false).getListTrip();

     print('---------------------------------------------------');
      print('---------------------Trips in Payment Screen-----------------------------');
      print(listTrips);
      print('---------------------------------------------------');
      for (var a in listTrips) {
        if (a.customer!.email == user!.email) {
          print(a.status);
          print('...............................................................');
          if (a.status == 'ending') {
            setState(() {
              trip = a;
              print(trip.vehicle);
              print('...............................................................');
              getFair();
              return;

            });
          }
      }

    }
  }

  void postpayment() {

    print('----------------------------------------------------------');
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");


    print(trip.converttoJson());

    print('----------------------------------------------------------');
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    Payment payment = Payment(
        trip: trip,
        bill: fare,
        customer: trip.customer,
        description: 'N/A',
        paymentMethod: paymentMethod,
        id: 1);

    print('----------------------------------------------------------------');
    print (payment.convertoJson());

    sendData(payment.convertoJson());
  }


  int getFairConstant()
  {
    int karaya=0;
    print(trip.vehicle!.vMake);
    if(trip.vehicle!.category=='mini')
    {
      if((int.parse(trip.vehicle!.modelNumber))<2000)
      {
        karaya=70;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2010)
      {
        karaya=100;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2020)
      {
        karaya=120;
      }
      else
      {
        karaya = 150;
      }
    }
    else  if(trip.vehicle!.category=='go')
    {
      if((int.parse(trip.vehicle!.modelNumber))<2000)
      {
        karaya=150;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2010)
      {
        karaya=200;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2020)
      {
        karaya=220;
      }
      else
      {
        karaya = 250;
      }

    }

    else if(trip.vehicle!.category=='pro')
    {
      if((int.parse(trip.vehicle!.modelNumber))<2000)
      {
        karaya=200;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2010)
      {
        karaya=250;
      }
      else if((int.parse(trip.vehicle!.modelNumber))<2020)
      {
        karaya=300;
      }
      else
      {
        karaya = 350;
      }
    }

    return karaya;
  }


  void getFair() {

    int ab=getFairConstant();

    var a = trip.readingAtEnd - trip.readingAtStart;

    setState(() {
      print('((((((((((((((((((($fare');
      fare = a * ab.round();
    });

  }


  static const _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '19',
      status: PaymentItemStatus.final_price,
    )
  ];

  @override
  void initState() {
    super.initState();
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: const CircularProgressIndicator())
        : Container(
            color: Colors.white,
            child: Container(
              alignment: Alignment.center,
              // padding: EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Fare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    fare.toString(),
                    style: const TextStyle(
                      fontSize: 30.0,
                      // color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Make Payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedButton(
                        buttonPressed: () {
                          Provider.of<CurrentVariable>(context, listen: false)
                              .update('end');
                          paymentMethod = 'cash';

                          setState(() {
                            _isLoading = true;
                          });

                          updateVehicle();
                          postpayment();
                          changeStatus();

                          setState(() {
                            _isLoading = false;
                          });

                          Provider.of<CurrentVariable>(context,listen: false).update('end');

                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MyDashboard(stat: 'paid')));
                        },
                        buttonColor: Colors.deepOrangeAccent,
                        buttonText: 'Cash',
                        minWidth: 100,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      GooglePayButton(
                        paymentConfigurationAsset: 'googlepay.json',
                        paymentItems: _paymentItems,
                        style: GooglePayButtonStyle.flat,
                        type: GooglePayButtonType.pay,
                        // margin: const EdgeInsets.only(top: 15.0),
                        width: 150,
                        height: 50,
                        onPaymentResult: (data) {

                          Provider.of<CurrentVariable>(context, listen: false)
                              .update('end');

                          paymentMethod = 'G pay';
                          setState(() {
                            _isLoading = true;
                          });


                          updateVehicle();
                          postpayment();
                          changeStatus();



                          setState(() {
                            _isLoading = false;
                          });

                          Provider.of<CurrentVariable>(context,listen: false).update('end');

                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MyDashboard(stat: 'paid')));
                        },
                        loadingIndicator: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
