import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/notification.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/providers/terminal_provider.dart';
import 'package:rentit_app/providers/vehicle_provider.dart';
import 'cus_welcome_screen.dart';
import '../component/rounded_button.dart';
import '../entities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dri_dashboard.dart';
import 'login_screen.dart';



class RegistrationScreen extends StatefulWidget {

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController cnic = TextEditingController();
  final TextEditingController username = TextEditingController();

  final GlobalKey<State<StatefulWidget>> _keyLoader = new GlobalKey<State>();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool isError = false;

  int _groupValue = 0;

  List<String> terminalsList = [];

  List<Terminal> lisTerminals=[];
  List<Vehicle> listVehicles=[];
  List<Driver> listDrivers=[];


  bool isDriver = false;

  String selectedTerminal = '';

  String? validateEmail(String? email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern.toString());
    if (!regExp.hasMatch(email!)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value!.length == 0) {
      return 'Please fill this field';
    } else if (value.length < 6) {
      return 'Minimum Password length is 6';
    }
  }

  String? validatePhone(String? value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value!.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String? validateCnic(String? value) {
    String patttern = r'(([0-9])$)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      return 'Please enter mobile number';
    } else if (value.length != 13) {
      return 'CNIC should be of 13 digits';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid Cnic without -';
    }
    return null;
  }

  String? validateName(String? value) {
    String patttern = r'(([a-zA-Z])$)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      return 'Please fill this field';
    } else if (value.isEmpty) {
      return 'Please enter a name';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid name';
    }
  }

  String? validateUsername(String? value) {
    if (value!.isEmpty) {
      return 'Please fill this field';
    } else if (value.length < 6) {
      return 'Username should be of minimum 6 characters';
    }
  }

  Future<int> sendDataOne(Map<String, dynamic> abc) async {
    await Http.post(Uri.parse('$kIpAddress:7070/api/customers'),
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
        print('eroor sending the whole Data');
        return -1;
      }
    });
    return -1;
  }

    Future<int> sendDataDriver(Map<String, dynamic> abc) async {
      await Http.post(Uri.parse('$kIpAddress:7070/api/drivers'),
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
          print('eroor sending the whole Data');
          return -1;
        }
      });
    return -1;
  }

  Future<int> sendNotification(Map<String, dynamic> abc) async {
    await Http.post(Uri.parse('$kIpAddress:7070/api/notifications'),
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
        print('eroor sending the whole Data');
        return -1;
      }
    });
    return -1;
  }

  String validateCustomerRequest(var c) {
    isError=false;
    List<Customer> list = c.listCustomer;

    print(list.length);
    String alpha = 'good';
    for (var c in list) {

      if (c.email == email.text.trim()) {

        isError = true;
        alpha = 'UserName should be Unique';
        break;
      }
      if (c.userName == username.text.trim()) {

        isError = true;
        alpha = 'UserName should be Unique';
        break;
      } else if (c.cnic == cnic.text.trim()) {

        isError = true;
        alpha = 'Cnic Should be Unique. Enter a unique Cnic';
        break;
      } else if (c.phone == phone.text.trim()) {

        isError = true;
        alpha = 'Phone Number Should be Unique. Enter a unique Phone Number';
        break;
      }
    }
    return alpha;
  }

  String validateDriverRequest(var d) {
    isError=false;

    List<Driver> list = d.listDrivers;
    String alpha = 'good';
    for (var c in list) {
      if (c.email == email.text.trim()) {

        isError = true;
        alpha = 'Email Address should be Unique';
        break;
      }
      if (c.userName == username.text.trim()) {
        isError = true;
        alpha = 'UserName should be Unique';
        break;
      } else if (c.cnic == cnic.text.trim()) {

        isError = true;
        alpha = 'Cnic Should be Unique. Enter a unique Cnic';
        break;
      } else if (c.phone == phone.text.trim()) {

        isError = true;
        alpha = 'Phone Number Should be Unique. Enter a unique Phone Number';
        break;

      }
    }
    return alpha;
  }


  void setTerminal() async
  {
    lisTerminals=await Provider.of<TerminalProvider>(context, listen:false).getListTerminal();
     listVehicles=await Provider.of<VehicleProvider>(context, listen: false).getListVehicle();
    listDrivers=await Provider.of<DriverProvider>(context, listen: false).getListDriver();

    if(lisTerminals.isNotEmpty)
      {
        for(var a in lisTerminals)
          {
            terminalsList.add(a.name);

          }
      }

  }

  @override
  void initState()
  {
    setTerminal();
    super.initState();

  }

  Terminal getSelectedTerminal( String nameTerminal)
  {
    for(var a in lisTerminals)
      {
        if(a.name==nameTerminal)
          {
            return a;
          }
      }
    throw 'Runtime Exception';

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _globalKey,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Container(
                              child: Hero(
                                tag: 'logo',
                                child: Container(
                                  height: 170,
                                  child: Image.asset("images/signup.png"),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: name,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'Name',
                                  hintText: 'Minimum 1 character'),
                              validator: validateName,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: username,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'Username',
                                  hintText: 'Minimum 6 characters'),
                              validator: validateUsername,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: email,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'Email',
                                  hintText: 'Enter valid email'),
                              validator: validateEmail,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: cnic,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'CNIC',
                                  hintText: 'Enter without dashes'),
                              validator: validateCnic,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: phone,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'Phone',
                                  hintText: 'Enter valid phone number'),
                              validator: validatePhone,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: password,
                              decoration: kTextFormFieldDecoration.copyWith(
                                  labelText: 'Password',
                                  hintText: 'Minimum 6 characters'),
                              validator: validatePassword,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.all(1.5),
                              padding: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0, color: Colors.lightBlueAccent),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12.0)),
                              ),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select the user type',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      CustomRadioButton(
                                        title: 'Driver',
                                        value: 1,
                                        groupValue: _groupValue,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            isDriver = true;
                                          });
                                        },
                                      ),
                                      CustomRadioButton(
                                        title: 'Customer',
                                        value: 0,
                                        groupValue: _groupValue,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            isDriver = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if(isDriver)
                              const SizedBox(
                                height: 10,
                              ),

                            if(isDriver)
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: buildDropdownSearch(
                                    'Select your nearest terminal',
                                    terminalsList,
                                    'Terminal'
                                ),
                              ),

                            const SizedBox(
                              height: 15,
                            ),
                            RoundedButton(
                              buttonColor: Colors.lightBlueAccent,
                              buttonText: 'Register',
                              buttonPressed: () async {
                                if (_globalKey.currentState!.validate()) {
                                  try {

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    //FCM Token
                                    final token= await  FirebaseMessaging.instance.getToken();

                                    print(token);

                                    CustomNotification notify=CustomNotification(email:email.text.trim()
                                    , token: token, id: 1);

                                    await sendNotification(notify.convertoJson());


                                    if (_groupValue == 0) {
                                      var cust = Provider.of<CustomerProvider>(
                                          context,
                                          listen: false);
                                      await cust.getListCustomer();


                                      Customer c = Customer(
                                          name: name.text.trim(),
                                          email: email.text.trim(),
                                          userName: username.text.trim(),
                                          cnic: cnic.text.trim(),
                                          password: password.text.trim(),
                                          phone: phone.text.trim(),
                                          description: 'alpha', id: 1);

                                      String error =
                                          validateCustomerRequest(cust);

                                      if (isError == false) {
                                        final UserCredential userCred =
                                            await _auth
                                                .createUserWithEmailAndPassword(
                                                    email: email.text.trim(),
                                                    password:
                                                        password.text.trim());
                                        final User? u = userCred.user;

                                        u!.sendEmailVerification();

                                        //Save default profile image url in firebase database
                                        await _firestore.collection('urls').add({
                                          'email' : u.email,
                                          'url' : 'https://firebasestorage.googleapis.com/v0/b/rentit-db.appspot.com/o/images%2Fimage1633118163655?alt=media&token=8c3c11db-ccab-4af9-92c8-06c835b9503e',
                                        });

                                        //UUID for chat
                                        final uuid = await u.getIdToken();
                                        print('in reg screen : uuid : $uuid');
                                        await _firestore.collection('tokens').add({
                                          'email' : u.email,
                                          'tokenId' : uuid,
                                        });

                                        await sendDataOne(c.convertoJson());


                                        await cust.getListCustomer();

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        Navigator.of(context).pop();

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));

                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             CusWelcomeScreen()));
                                      } else {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(error),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else if (_groupValue == 1) {


                                      Terminal tt = getSelectedTerminal(selectedTerminal);

                                      Driver c = Driver(
                                          name: name.text.trim(),
                                          email: email.text.trim(),
                                          userName: username.text.trim(),
                                          password: password.text.trim(),
                                          cnic: cnic.text.trim(),
                                          phone: phone.text.trim(),
                                          description: 'alpha',
                                          driverOnTrip: false, id: 1, terminal: tt,  );

                                      var driv = Provider.of<DriverProvider>(
                                          context,
                                          listen: false);

                                      await driv.getListDriver();

                                      String error =
                                          validateDriverRequest(driv);
                                      if (isError == false) {
                                        final UserCredential userCred =
                                            await _auth
                                                .createUserWithEmailAndPassword(
                                                    email: email.text.trim(),
                                                    password:
                                                        password.text.trim());
                                        final User? u = userCred.user;
                                        u!.sendEmailVerification();

                                        //Save default profile image url in firebase database
                                        await _firestore.collection('urls').add({
                                          'email' : u.email,
                                          'url' : 'https://firebasestorage.googleapis.com/v0/b/rentit-db.appspot.com/o/images%2Fimage1633118163655?alt=media&token=8c3c11db-ccab-4af9-92c8-06c835b9503e',
                                        });

                                        //UUID for chat
                                        final uuid = await u.getIdToken();
                                        print('in reg screen : uuid : $uuid');
                                        await _firestore.collection('tokens').add({
                                          'email' : u.email,
                                          'tokenId' : uuid,
                                        });

                                        await sendDataDriver(c.convertoJson());



                                        await driv.getListDriver();

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        Navigator.of(context).pop();

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));

                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             DriWelcomeScreen()));
                                      } else {

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(error),
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
                                      }
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } on Exception catch (e) {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(e.toString()),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              }, minWidth: 100,
                            ),
                            RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text: 'Already registered? ',
                                    style: TextStyle(
                                      color: Colors.green,
                                    )),
                                TextSpan(
                                    text: 'Sign In',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));
                                      }),
                              ]),
                            ),
                            const SizedBox(
                              height: 25,
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

  DropdownSearch<String>     buildDropdownSearch(String hint, List<String> list, String label) {
    return DropdownSearch(
      validator: (value) {
        if (value == null)
          return 'Field required';
        else return null;

      },
      showSearchBox: true,
      autoFocusSearchBox: true,

      dropdownSearchDecoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent,),
        ),
      ),
      hint: hint,
      mode: Mode.DIALOG,
      showSelectedItem: true,
      items: list,
      loadingBuilder: (context, searchEntry) => Center(child: Text('Loading...',
        style: TextStyle(color: Colors.deepPurple, fontSize: 30, fontWeight: FontWeight.bold ),)),
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

}

class CustomRadioButton extends StatelessWidget {
  final value;
  final title;
  final onChanged;
  final groupValue;

  const CustomRadioButton(
      { this.value, this.onChanged, this.title, this.groupValue})
      ;

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
