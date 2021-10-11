import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as Http;
import 'package:rentit_app/component/db_methods.dart';
import 'package:rentit_app/component/dri_app_drawer.dart';
import 'package:rentit_app/component/dri_custom_card.dart';
import 'package:rentit_app/component/no_data_display.dart';
import 'package:rentit_app/component/rounded_button.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/providers/terminal_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';
import 'package:rentit_app/screens/profile_screen.dart';

import 'chat_screen.dart';
import 'login_screen.dart';

class DriDashboard extends StatefulWidget {
  @override
  _DriDashboardState createState() => _DriDashboardState();
}

class _DriDashboardState extends State<DriDashboard>
    with SingleTickerProviderStateMixin {
  final List<Tab> tab = <Tab>[
    Tab(text: 'Current Ride'),
    Tab(text: 'Completed'),
  ];

  late TabController tabController;

  List<Trip> listTrips = [];
  List<Trip> driverTrip = [];
  List<Trip> completedTrips = [];
  Trip currentTrip = Trip(
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

  get vsync => this;

  List<String> terminalsList = [];

  List<Terminal> listTerminal = [];
  String selectedTerminal = '';

  Terminal? getTerminal() {
    for (var a in listTerminal) {
      if (a.name == selectedTerminal) {
        return a;
      }
    }
    return null;
  }

  final TextEditingController meterController = TextEditingController();

  int getFairConstant()
  {
    int karaya=0;
    print(currentTrip.vehicle!.vMake);
    if(currentTrip.vehicle!.category=='mini')
    {
      if((int.parse(currentTrip.vehicle!.modelNumber))<2000)
      {
        karaya=70;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2010)
      {
        karaya=100;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2020)
      {
        karaya=120;
      }
      else
      {
        karaya = 150;
      }
    }
    else  if(currentTrip.vehicle!.category=='go')
    {
      if((int.parse(currentTrip.vehicle!.modelNumber))<2000)
      {
        karaya=150;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2010)
      {
        karaya=200;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2020)
      {
        karaya=220;
      }
      else
      {
        karaya = 250;
      }

    }

    else if(currentTrip.vehicle!.category=='pro')
    {
      if((int.parse(currentTrip.vehicle!.modelNumber))<2000)
      {
        karaya=200;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2010)
      {
        karaya=250;
      }
      else if((int.parse(currentTrip.vehicle!.modelNumber))<2020)
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

  void getListTrips() async {
    User? u = FirebaseAuth.instance.currentUser;

    listTrips =
        await Provider.of<TripProvider>(context, listen: false).getListTrip();

    if (listTrips.isNotEmpty) {
      for (var a in listTrips) {
        if (a.optionDriver == true) {
          if (a.driver!.email == u!.email) {
            print('0000000000000000000000000000000000000000000000000000000');
            print(a.driver!.name);
            print('0000000000000000000000000000000000000000000000000000000');

            setState(() {
              driverTrip.add(a);
            });
          }
        }
      }

      if (driverTrip.isNotEmpty) {
        print('.....................................................');
        for (var ab in driverTrip) {
          if (ab.status == 'current') {
            setState(() {
              currentTrip = ab;
              isStarted = true;
            });

            break;
          } else if (ab.status == 'accepted') {
            setState(() {
              currentTrip = ab;
              driverUserName = ab.driver!.userName;
              customerUserName = ab.customer!.userName;
            });

            final token = await FirebaseFirestore.instance.collection('tokens')
                .where('email', isEqualTo: ab.customer!.email).get();
            var data4 = token.docs[0].data();
            setState(() {
              uuid = data4['tokenId'];
              print('uuid--------$uuid');
            });

            break;
          } else if (ab.status == 'ending') {
            setState(() {
              currentTrip = ab;
              isEnding = true;
            });
            break;
          } else if (ab.status == 'end') {
            setState(() {
              currentTrip = ab;
            });
            break;
          } else if (ab.status == 'completed') {
            setState(() {
              completedTrips.add(ab);
            });
          }
        }
      }
    }

    if (currentTrip.id != -1) {
      setState(() {
        getStartReading();
      });
    }
  }

  Future<void> getTerminals() async {
    listTerminal = await Provider.of<TerminalProvider>(context, listen: false).getListTerminal();

    if (listTerminal.isNotEmpty) {

      for (var a in listTerminal) {
        setState(() {
          terminalsList.add(a.name);
        });
      }
    }
  }

  bool isLoading = false;

  late String driverUserName ;

  late String customerUserName ;

  late String uuid;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tab.length, vsync: vsync);

    getTerminals();
    getListTrips();
  }

  bool isStarted = false;
  bool isEnding = false;
  double startReading = -1;

  String fair = 'calculating...';

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  void getStartReading() async {
    setState(() {
      startReading = currentTrip.readingAtStart;
    });
  }

  String? validateEndReading(String? value) {
    String patttern = r'([0-9]+(\.[0-9]+)?)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      return 'Please fill this field';
    } else if ((!regExp.hasMatch(value)) ||
        (double.parse(value) < startReading)) {
      return 'Please enter valid reading';
    }
    return null;
  }




  void updateVehicle() async {

    currentTrip.vehicle!.terminal=getTerminal()!;
    Map<String, dynamic> mapUpdate = currentTrip.vehicle!.converttoJson();


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
  void updateDriver() async {
    currentTrip.driver!.driverOnTrip=false;
    currentTrip.driver!.terminal=getTerminal();
    Map<String, dynamic> mapUpdate = currentTrip.driver!.converttoJson();

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

  Future<void> saveReading() async {
    print(currentTrip.customer!.name);
    print(currentTrip.driver!.name);
    Map<String, dynamic> mapUpdate = currentTrip.converttoJson();

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

  void getFair() {
      var a = currentTrip.readingAtEnd - currentTrip.readingAtStart;
      setState(() {
        fair = (a * 100.round()).toString();
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
                child: isLoading? const Center(child: CircularProgressIndicator()) : ((currentTrip.id != -1) &&
                        ((currentTrip.status == 'accepted') ||
                            (currentTrip.status == 'current')))
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DriCustomCard(
                                category: currentTrip.vehicle!.category,
                                vehicle: currentTrip.vehicle!.vMake,
                                status: currentTrip.status,
                                fromTerminal: currentTrip.terminal!.name,
                                cusEmail: currentTrip.customer!.email,
                                text: 'Ride'),
                            isStarted
                                ? RoundedButton(
                                buttonColor: Colors.blue,
                                buttonText: 'End Ride',
                                buttonPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Form(
                                          key: _globalKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller: meterController,
                                                decoration:
                                                kTextFormFieldDecoration
                                                    .copyWith(
                                                    labelText:
                                                    'Current Meter Reading',
                                                    hintText: ''),
                                                validator:
                                                validateEndReading,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                child: buildDropdownSearch(
                                                    'Select your nearest terminal',
                                                    terminalsList,
                                                    'Terminal'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          RoundedButton(
                                              buttonColor: Colors.blue,
                                              buttonText: 'Proceed',
                                              buttonPressed: () async {
                                                if (_globalKey.currentState!
                                                    .validate()) {
                                                  currentTrip.readingAtEnd =
                                                      double.parse(
                                                          meterController.text
                                                              .trim());

                                                  setState(() {
                                                    currentTrip.status =
                                                    'ending';
                                                    fair = ((currentTrip
                                                        .readingAtEnd -
                                                        currentTrip
                                                            .readingAtStart) *
                                                        getFairConstant())
                                                        .toString();
                                                    isEnding = true;
                                                  });

                                                  updateDriver();
                                                  updateVehicle();
                                                  await saveReading();

                                                  Navigator.pop(context);
                                                }
                                              },
                                              minWidth: 100,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                minWidth: 100,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RoundedButton(
                                  buttonPressed: (){
                                    setState(() {
                                      isLoading = true;
                                    });

                                    print('cus username : $customerUserName');
                                    print('dri username : $driverUserName');

                                    createChatRoomAndStartConversation(customerUserName, driverUserName );

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  buttonText: 'Chat',
                                  buttonColor: Colors.lightBlueAccent,
                                  minWidth: 110,
                                ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                RoundedButton(
                                  buttonColor: Colors.green,
                                  buttonText: 'Start',
                                  buttonPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Form(
                                            key: _globalKey,
                                            child: TextFormField(
                                              controller: meterController,
                                              decoration: kTextFormFieldDecoration
                                                  .copyWith(
                                                  labelText:
                                                  'Current Meter Reading',
                                                  hintText: ''),
                                              validator: validateEndReading,
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (_globalKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    startReading =
                                                        double.parse(
                                                            meterController
                                                                .text
                                                                .trim());
                                                    isStarted = true;
                                                  });

                                                  setState(() {
                                                    currentTrip
                                                        .readingAtStart =
                                                        startReading;
                                                    currentTrip.status =
                                                    'current';
                                                  });

                                                  await saveReading();

                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: const Text(
                                                'Go',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  minWidth: 100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : isEnding
                        ? Center(
                            child: RoundedButton(
                                buttonColor: Colors.lightBlueAccent,
                                buttonText: 'Show Fair',
                                buttonPressed:  () {
                                  getFair();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Container(
                                          height: 50,
                                          // child: Padding(
                                          // padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                              child: Text(
                                                fair,
                                                style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue),
                                              )),
                                          // ),
                                        ),
                                        actions: [
                                          RoundedButton(
                                              buttonColor: Colors.lightBlueAccent,
                                              buttonText: 'Close',
                                              buttonPressed: () {

                                                setState(() {
                                                  isEnding = false;
                                                });

                                                Navigator.pop(context);
                                              },
                                              minWidth: 80),
                                        ],
                                      );
                                    },
                                  );
                                },
                                minWidth: 120),
                          )
                        : NoDataDisplayWidget(),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        completedTrips.isNotEmpty
                            ? getWidgets(completedTrips)
                            : Padding(
                                padding: const EdgeInsets.only(top: 220),
                                child: NoDataDisplayWidget(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: Container(
          width: 250,
          child: DriAppDrawer(),
        ),
      ),
    );
  }

  DropdownSearch<String> buildDropdownSearch(
      String hint, List<String> list, String label) {
    return DropdownSearch(
      validator: (value) {
        if (value == null) {
          return 'Field required';
        } else {
          return null;
        }
      },
      showSearchBox: true,
      autoFocusSearchBox: true,
      dropdownSearchDecoration: const InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.lightBlueAccent,
          ),
        ),
      ),
      hint: hint,
      mode: Mode.DIALOG,
      showSelectedItem: true,
      items: list,
      loadingBuilder: (context, searchEntry) => const Center(
          child: Text(
        'Loading...',
        style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 30,
            fontWeight: FontWeight.bold),
      )),
      label: label,
      showClearButton: true,
      onChanged: (value) {
        setState(() {
          selectedTerminal = value!;
          print('selectedTerminal : $selectedTerminal');
        });
      },
      clearButtonSplashRadius: 20,
    );
  }

  onSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()));
          break;
        }
      case 1:
        {
          await FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          break;
        }
    }
  }

  createChatRoomAndStartConversation(String secondUser, String firstUser) {

    DatabaseMethods databaseMethods = DatabaseMethods();

    String chatRoomId = getChatRoomId(secondUser, firstUser);
    List<String> users = [secondUser, firstUser];
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'chatroomId': chatRoomId
    };
    databaseMethods.createChatRoom(chatRoomId, chatRoomMap,firstUser);
    //TODO:add uuid
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChattingScreen(
          chatRoomId: chatRoomId,
          driUserName: secondUser, cusUserName: firstUser, userType: 'driver', uuid: uuid,
        )));
  }

  getChatRoomId(String a, String b) {
    if (a.compareTo(b) == 1) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

}

Widget getWidgets(List<Trip> rides) {
  List<Widget> list = [];
  for (var i = 0; i < rides.length; i++) {
    var num = i + 1;
    list.add(DriCustomCard(
        category: rides[i].vehicle!.category,
        vehicle: rides[i].vehicle!.vMake,
        status: rides[i].status,
        fromTerminal: rides[i].terminal!.name,
        cusEmail: rides[i].customer!.email,
        text: 'Ride $num'));
  }
  return new Column(children: list);
}
