import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/component/app_drawer.dart';
import 'package:rentit_app/component/cus_custom_card.dart';
import 'package:rentit_app/component/db_methods.dart';
import 'package:rentit_app/component/no_data_display.dart';
import 'package:rentit_app/component/rounded_button.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/providers/current_variable_provider.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';
import 'package:rentit_app/screens/payment_screen.dart';
import 'package:rentit_app/screens/rating_screen.dart';

import 'chat_screen.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({required this.stat});

  final String stat;

  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  final List<Tab> tab = <Tab>[
    const Tab(text: 'Active Ride'),
    const Tab(text: 'Pending'),
    const Tab(text: 'Completed'),
  ];

  late TabController tabController;
  List<Trip> completedAndCancelledRides = [];

  List<Trip> allTrips = [];
  late Trip currentTrip;
  late Trip pendingTrip;

  String current = 'loading';
  bool pending = false;

  void caller() async {
    allTrips = await Provider.of<TripProvider>(context, listen: false).getListTrip();
        await Provider.of<CustomerProvider>(context,listen:false).getListCustomer();
        await Provider.of<DriverProvider>(context,listen:false).getListDriver();


    if (allTrips.isNotEmpty) {
      setState(() {
        getCurrentUserRides();
      });
    }
  }



  @override
  void initState() {
    if(widget.stat == 'done'){
      setState(() {
        current='completed';
      });
    }
    setState(()  {

      //current= Provider.of<CurrentVariable>(context,listen: false).current;
      print('currenttttttttt$current');
      caller();
    });
    super.initState();


    tabController = TabController(vsync: this, length: tab.length);
  }

  bool history = false;

  String uuid = '';

  Future<void> getCurrentUserRides() async {
    User? user = _auth.currentUser;
    print('88888888888888888888888888888888${user!.email}8888888888888888');

    for (var tripp in allTrips) {
      print('88888888888888888888888888888888${tripp.customer!.email} 8888888888888888');
      print('88888888888888888888888888888888${tripp.status} 8888888888888888');
      if (tripp.customer!.email == user!.email) {
        if ((tripp.status == 'completed')) {
          completedAndCancelledRides.add(tripp);
          setState(() {
            history = true;
          });
        } else if (tripp.status == 'cancelled') {
          completedAndCancelledRides.add(tripp);
          setState(() {
            history = true;
          });
        } else if (tripp.status == 'accepted') {
          currentTrip = tripp;
          setState(() {
            current = tripp.status;
          });

          final token = await FirebaseFirestore.instance.collection('tokens')
              .where('email', isEqualTo: tripp.driver!.userName).get();
          var data3 = token.docs[0].data();
          setState(() {
            uuid = data3['tokenId'];

          });

        } else if (tripp.status == 'current') {
          currentTrip = tripp;
          setState(() {
            current = tripp.status;
          });
        } else if (tripp.status == 'pending') {
          pendingTrip = tripp;
          setState(() {
            pending = true;
          });
        } else if (tripp.status == 'ending') {
          currentTrip = tripp;

          print(currentTrip.status);
          setState(() {
            current = tripp.status;
          });


        } else if (tripp.status == 'end') {
          currentTrip = tripp;
          setState(() {
            current = tripp.status;
          });

        }
      }
    }
    if (current == 'loading') {
      setState(() {
        current = 'null';
      });
    }
  }

  void updateTrip() async {
    Map<String, dynamic> mapUpdate = pendingTrip.converttoJson();


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

  void updateDriver() async {
    Map<String, dynamic> mapUpdate = pendingTrip.driver!.converttoJson();

    print('data');
    return await Http.put(Uri.parse('$kIpAddress:7070/api/drivers'),
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

  void updateVehicle() async {
    pendingTrip.vehicle!.status = true;
    Map<String, dynamic> mapUpdate = pendingTrip.vehicle!.converttoJson();

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

  void cancelRequest() {
    pendingTrip.status = 'cancelled';

    print(pendingTrip.driver!.converttoJson());
    updateTrip();

    updateVehicle();

    if (pendingTrip.driver != null) {
      pendingTrip.driver!.driverOnTrip = false;
      updateDriver();
    }

    setState(() {
      completedAndCancelledRides.add(pendingTrip);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Dashboard'),
          centerTitle: true,
          bottom: TabBar(
            controller: tabController,
            tabs: tab,
          ),
        ),
        body: Container(
          child: TabBarView(
            controller: tabController,
            children: [
              Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      current == 'loading'
                          ? const Center(child: CircularProgressIndicator())
                          : current == 'current'
                              ? CusCustomCard(
                                  terminal: currentTrip.terminal!.name,
                                  vehicle: currentTrip.vehicle!.vMake,
                                  category: currentTrip.vehicle!.category,
                                  isDriver: currentTrip.optionDriver,
                                  text: 'Active Ride Info',
                                  status: currentTrip.status,
                                )
                              : current == 'accepted'
                                  ? Column(
                                      children: [
                                        CusCustomCard(
                                          terminal: currentTrip.terminal!.name,
                                          vehicle: currentTrip.vehicle!.vMake,
                                          category:
                                              currentTrip.vehicle!.category,
                                          isDriver: currentTrip.optionDriver,
                                          text: 'Current Ride Info',
                                          status: current,
                                        ),
                                        if (currentTrip.optionDriver)
                                          RoundedButton(
                                            buttonPressed: () {
                                              createChatRoomAndStartConversation(
                                                  currentTrip.driver!.userName,
                                                currentTrip
                                                    .customer!.userName);
                                            },
                                            buttonText: 'Chat',
                                            buttonColor: Colors.lightBlueAccent,
                                            minWidth: 110,
                                          ),
                                      ],
                                    )
                                  : current == 'ending'
                                      ? PaymentScreen()
                                      : current == 'end'
                                          ? Ratings()
                                          : NoDataDisplayWidget(),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    pending
                        ? CusCustomCard(
                            terminal: pendingTrip.terminal!.name,
                            vehicle: pendingTrip.vehicle!.vMake,
                            category: pendingTrip.vehicle!.category,
                            isDriver: pendingTrip.optionDriver,
                            text: 'Pending Ride Info',
                            status: pendingTrip.status,
                          )
                        : NoDataDisplayWidget(),
                    pending
                        ? RoundedButton(
                            buttonColor: Colors.red,
                            buttonText: 'Cancel',
                            buttonPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Alert',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: const Text(
                                          'Are you sure you want to cancel the request?'),
                                      actions: [
                                        RoundedButton(
                                          buttonColor: Colors.green,
                                          buttonText: 'No',
                                          buttonPressed: () {
                                            Navigator.pop(context);
                                          },
                                          minWidth: 65,
                                        ),
                                        RoundedButton(
                                          buttonColor: Colors.red,
                                          buttonText: 'Yes',
                                          buttonPressed: () {
                                            cancelRequest();
                                            Provider.of<CurrentVariable>(context,listen: false).update('cancelled');
                                            setState(() {
                                              pending = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          minWidth: 60,
                                        ),
                                      ],
                                    );
                                  });
                            },
                            minWidth: 100)
                        : Text(''),
                  ],
                ),
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      history
                          ? getWidgets(completedAndCancelledRides)
                          : NoDataDisplayWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: AppDrawer(),
      ),
    );
  }

  createChatRoomAndStartConversation(String secondUser, String firstUser) {
    DatabaseMethods databaseMethods = DatabaseMethods();

    String chatRoomId = getChatRoomId(secondUser, firstUser);
    List<String> users = [secondUser, firstUser];
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'chatroomId': chatRoomId
    };
    databaseMethods.createChatRoom(chatRoomId, chatRoomMap, firstUser);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChattingScreen(
                  chatRoomId: chatRoomId,
                  driUserName: secondUser,
                  cusUserName: firstUser,
                  userType: 'customer', uuid: uuid,
                )));
  }

  getChatRoomId(String a, String b) {
    if (a.compareTo(b) == 1) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

  Widget getWidgets(List<Trip> rides) {
    print('----------------------------------------------------------');
    print(rides.length);
    List<Widget> list = [];
    for (var i = 0; i < rides.length; i++) {
      var num = i + 1;
      list.add(
        CusCustomCard(
          terminal: rides[i].terminal!.name,
          category: rides[i].vehicle!.category,
          vehicle: rides[i].vehicle!.vMake,
          isDriver: rides[i].optionDriver,
          text: 'Ride $num',
          status: rides[i].status,
        ),
      );
    }
    return Column(children: list);
  }

}
