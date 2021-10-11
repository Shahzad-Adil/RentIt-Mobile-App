import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/screens/registeration_screen.dart';
import '../entities/constants.dart';
import '../component/rounded_button.dart';
import 'cus_welcome_screen.dart';
import 'driver_welcome_screen.dart';

class LoginScreen extends StatefulWidget {




  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final GlobalKey<State<StatefulWidget>> _keyLoader = GlobalKey<State>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _auth = FirebaseAuth.instance;

  int _groupValue=0;

  bool isLoading = false;
  bool cusValidation=false;
  bool driverValidation=false;

  List<Customer> customers=[];
  List<Driver> drivers=[];


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
    if (value!.isEmpty) {
      return 'Please fill this field';
    } else if (value.length < 6) {
      return 'Minimum Password length is 6';
    }
  }


 void loadData() async
  {
    customers=await Provider.of<CustomerProvider>(context, listen: false).getListCustomer();
    drivers=await Provider.of<DriverProvider>(context, listen: false).getListDriver();

  }


  @override
  void initState() {

    loadData();

    super.initState();
  }

  bool validateCustomer(User user)
  {
    for(var a in customers)
    {
      if(a.email== user.email)
        {
          return true;
        }
    }
    return false;
  }

  bool validateDriver(User user)
  {
    for(var a in drivers)
    {
      if(a.email== user.email)
      {
        return true;
      }
    }
    return false;
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _globalKey,
                child: Column(
                  children: [
                    Container(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          height: 200,
                          child: Image.asset("images/signin.png"),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: email,
                      decoration: kTextFormFieldDecoration.copyWith(labelText: 'Email',hintText: ''),
                      validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: password,
                      decoration: kTextFormFieldDecoration.copyWith(labelText: 'Password', hintText: ''),
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
                                onChanged: (newValue) => setState(
                                        () => _groupValue = newValue),
                              ),
                              CustomRadioButton(
                                title: 'Customer',
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
                    RoundedButton(
                      buttonText: 'Sign In',
                      buttonColor: Colors.lightBlueAccent,
                      buttonPressed: () async {
                        if (_globalKey.currentState!.validate()) {
                          try {
                            // LoadingSpinner.showLoadingDialog(context, _keyLoader);
                            setState(() {
                              isLoading = true;
                            });
                            final UserCredential userCred =
                            await _auth.signInWithEmailAndPassword(
                                email: email.text.trim(),
                                password: password.text.trim());
                            final User? u = userCred.user;

                            if (u != null) {

                              if(u.emailVerified) {

                                final idToken = await u.getIdToken();
                                print('###################################$idToken');

                                final token = await FirebaseMessaging.instance.getToken();

                                print('@@@@@@@@@@@@@@@@@@@@$token');

                                if (_groupValue == 0) {
                                  if (validateCustomer(u)) {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            CusWelcomeScreen()));
                                  }
                                  else {
                                    throw 'error';
                                  }
                                }
                                else if (_groupValue == 1) {
                                  if (validateDriver(u)) {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            DriverWelcomeScreen()));
                                  }
                                  else {
                                    throw 'error';
                                  }
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Email is not verified!')));
                              }
                              setState(() {
                                isLoading = false;
                              });
                            }

                          } on Exception catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('User not found or lack of internet connection'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: (){
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
                            text: 'New User? ',
                            style: TextStyle(
                              color: Colors.green,
                            )),
                        TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=>RegistrationScreen()));

                              }),
                      ],),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
