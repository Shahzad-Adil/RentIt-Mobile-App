
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:core';
import 'package:provider/provider.dart';

import 'package:rentit_app/component/rounded_button.dart';

import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/providers/terminal_provider.dart';
import 'package:rentit_app/providers/trip_post_provider.dart';
import 'package:rentit_app/providers/vehicle_provider.dart';
import 'confirmation_screen.dart';

class RentAVehicle extends StatefulWidget {
  @override
  _RentAVehicleState createState() => _RentAVehicleState();
}

class _RentAVehicleState extends State<RentAVehicle> {
  List<String> terminalsList = [];
  List<String> vehiclesList = [];

  List<Terminal> listTerminals = [];
  List<Vehicle> listVehicles = [];

  bool isDvrFound = false;

  List<String> driverOptions = [
    'Yes',
    'No',
  ];

  List<String> categories = ['mini', 'go', 'pro'];

  bool _isLoading = false;
  bool _isLoadingVehicle = false;


  List<Driver> dvrList =[];

  @override
  void initState() {
    getTerminals();
    getVehicles();
    super.initState();

    getVehicle();
  }




  void getVehicle() async {
    listVehicles =
        await Provider.of<VehicleProvider>(context, listen: false).listVehicles;

    dvrList =
    await Provider.of<DriverProvider>(context, listen: false).getListDriver();
  }

  //get all terminals from database table 'terminals'
  // and save in a list 'terminalsList'

  void getTerminals() async {
    listTerminals =
        Provider.of<TerminalProvider>(context, listen: false).listTerminals;

    print('--------------------------------------------------------');
    print(listTerminals);
    for (var termi in listTerminals) {
      terminalsList.add(termi.name);
    }
  }

  Terminal? getTerminalSelected(String name) {
    listTerminals =
        Provider.of<TerminalProvider>(context, listen: false).listTerminals;

    for (var termi in listTerminals) {
      if (termi.name == name) {
        return termi;
      }
    }
    return null;
  }

  Future<Driver?> getDriver() async {


    Driver d;
    if (dvrList.isNotEmpty) {
      for (var ab in dvrList) {

        if (ab.terminal!.name == selectedTerminal) {
          if(!ab.driverOnTrip){
            d = ab;
            isDvrFound = true;
            print('------------------------------------------');
            print(ab.cnic);
            return d;
          }
        }
      }
    }
    return null;
  }

  Future<Customer?> getLoggedInUser() async {
    List<Customer> list =
        await Provider.of<CustomerProvider>(context, listen: false)
            .getListCustomer();
    User? user = FirebaseAuth.instance.currentUser;

    print(list.length);
    for (var a in list) {
      print(a.email);
      print(a.name);
      if (a.email == user!.email) {
        return a;
      }
    }
    return null;
  }

  Vehicle? getSpecificVehicles(String t, String vmake) {
    for (var vehicl in listVehicles) {
      if (vehicl.terminal.name == t) {
        if (vehicl.vMake == vmake) {
          return vehicl;
        }
      }
    }

    return null;
  }

  void getVehicles() async {
    listVehicles =
        await Provider.of<VehicleProvider>(context, listen: false).listVehicles;
    print(listVehicles);

    bool isFound = false;

    for (var veh in listVehicles) {
      if (veh.status == true) {
        if (veh.terminal.name == selectedTerminal) {
          if (veh.category == selectedCategory) {
            if (vehiclesList.isNotEmpty) {
              for (var a in vehiclesList) {
                if (a == veh.vMake) {
                  isFound = true;
                  break;
                }
              }
              if (!isFound) vehiclesList.add(veh.vMake);
            } else
              vehiclesList.add(veh.vMake);
          }
        }
      }
    }
  }

  String selectedTerminal = 'Select Terminal ';
  String selectedCategory = 'mini';
  String selectedVehicle = '';

  int _groupValue = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rent A Car'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        child: Column(
                          children: [
                            buildDropdownSearch(
                                'Select a terminal',
                                terminalsList,
                                'Terminal *',
                                'selectedTerminal'),
                            SizedBox(
                              height: 15,
                            ),
                            buildDropdownSearch('Select a category', categories,
                                'Category *', 'selectedCategory'),
                            SizedBox(
                              height: 15,
                            ),
                            _isLoadingVehicle
                                ? Center(child: CircularProgressIndicator())
                                : buildDropdownSearch(
                                    'Select a vehicle',
                                    vehiclesList,
                                    'Vehicle *',
                                    'selectedVehicle'),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black38,
                                  width: 1,
                                  // style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Do you need our driver?',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      CustomRadioButton(
                                        title: 'Yes',
                                        value: 1,
                                        groupValue: _groupValue,
                                        onChanged: (newValue) => setState(
                                            () => _groupValue = newValue),
                                      ),
                                      CustomRadioButton(
                                        title: 'No',
                                        value: 0,
                                        groupValue: _groupValue,
                                        onChanged: (newValue) => setState(
                                            () => _groupValue = newValue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            RoundedButton(
                              buttonColor: Colors.lightBlue,
                              buttonText: 'Submit Request',
                              buttonPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  Trip t = Trip(
                                    id: 1,
                                    tripDate:
                                        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                                    startTime:
                                        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
                                    endTime: '00:00:00',
                                    readingAtStart: 0.0,
                                    readingAtEnd: 0.0,
                                    description: 'No Specific Desc',
                                    status: 'pending',
                                    terminal:
                                        getTerminalSelected(selectedTerminal),
                                    vehicle: getSpecificVehicles(
                                        selectedTerminal, selectedVehicle),
                                    driver: _groupValue == 1
                                        ? await getDriver()
                                        : null,
                                    customer: await getLoggedInUser(),
                                    optionDriver:
                                        _groupValue == 1 ? true : false,
                                  );


                                  var a = Provider.of<TripPostProvider>(context,
                                      listen: false);

                                  a.setTrip(t);

                                  _groupValue == 0
                                      ? showModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              ConfirmationScreen(),
                                          isScrollControlled: true)
                                      : isDvrFound
                                          ? showModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  ConfirmationScreen(),
                                              isScrollControlled: true)
                                          : showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Error'),
                                                  content: Text(
                                                      'Driver Not Available at this terminal'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Close'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                  //   Navigator.pushNamed(context, MyDashboard.id);
                                }

                                // }
                              },
                              minWidth: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  DropdownSearch<String> buildDropdownSearch(
      String hint, List<String> list, String label, var selectedItem) {
    return DropdownSearch(
      validator: (value) {
        if (value == null)
          return 'Field required';
        else {
          if (selectedItem == 'selectedCategory') {
            if (selectedCategory.isEmpty) {
              return 'Field required';
            } else
              return null;
          }

          if (selectedItem == 'selectedTerminal') {
            if (selectedTerminal.isEmpty) {
              return 'Field required';
            } else
              return null;
          }

          if (selectedItem == 'selectedVehicle') {
            if (selectedVehicle.isEmpty) {
              return 'Field required';
            } else
              return null;
          } else
            return null;
        }
      },
      showSearchBox: true,
      autoFocusSearchBox: true,
      // selectedItem: selectedCity,
      hint: hint,
      selectedItem: selectedItem == 'selectedCategory'
          ? selectedCategory
          : selectedItem == 'selectedVehicle'
              ? selectedVehicle
              : selectedTerminal,
      mode: Mode.DIALOG,
      showSelectedItem: true,
      items: list,
      // emptyBuilder: (context, searchEntry) => Text('Not available now. Try Again'),
      loadingBuilder: (context, searchEntry) => Center(
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
          if (selectedItem == 'selectedTerminal') {
            selectedTerminal = value!;

            selectedVehicle = '';
            vehiclesList.clear();
            setState(() {
              _isLoadingVehicle = true;
            });
            getVehicles();

            setState(() {
              _isLoadingVehicle = false;
            });
          } else if (selectedItem == 'selectedCategory') {
            selectedCategory = value!;

            selectedVehicle = '';
            vehiclesList.clear();

            setState(() {
              _isLoadingVehicle = true;
            });

            getVehicles();

            setState(() {
              _isLoadingVehicle = false;
            });
          } else if (selectedItem == 'selectedVehicle')
            selectedVehicle = value!;
        });
      },
      clearButtonSplashRadius: 20,
      // selectedItem: "Tunisia",
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final value;
  final title;
  final onChanged;
  final groupValue;

  const CustomRadioButton(
      {this.value, this.onChanged, this.title, this.groupValue});

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }
}
