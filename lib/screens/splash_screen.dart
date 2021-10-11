import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/providers/vehicle_provider.dart';
import 'package:rentit_app/screens/driver_welcome_screen.dart';
import 'package:rentit_app/screens/registeration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'cus_welcome_screen.dart';
import 'dri_dashboard.dart';
import 'login_screen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

   static const String id = 'Splash';

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with AfterLayoutMixin {

  User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;

  List<Customer> customers=[];
  List<Driver> drivers=[];
  List<Vehicle> vehicles=[];

  Future<void> loadData()
  async {
      customers=await Provider.of<CustomerProvider>(context, listen: false).getListCustomer();
      drivers=await Provider.of<DriverProvider>(context, listen: false).getListDriver();
      vehicles=await Provider.of<VehicleProvider>(context, listen: false).getListVehicle();

  }

  bool validateCustomer(User user)
  {
    print('in validate cus');
    print(customers.length);

    for(var a in customers)
    {
      print('1');
      print(a.email);
      if(a.email== user.email)
      {
        print('2');
        return true;
      }
    }
    print('3');
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
  void initState() {
    // TODO: implement initState
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(
        child: SpinKitCircle(
          color: Colors.indigo,
          size: 50,
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstScreen();

  Future checkFirstScreen() async {
    await loadData();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool _seen = (sharedPreferences.getBool('seen') ?? false);
    if(_seen){
      if(user == null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
      else{
        if(user!.emailVerified){
          nextScreen();
        }
      }
    }
    else{
      sharedPreferences.setBool('seen', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));    }
  }

  void nextScreen() async {

  print('in next screen');
    if(customers.isNotEmpty) {
      if (validateCustomer(user!)) {
        setState(() {
          _isLoading = false;
        });
        print('cus validated');

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CusWelcomeScreen()));
      }
    }
    if(drivers.isNotEmpty) {
      if (validateDriver(user!)) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DriverWelcomeScreen()));
      }
    }
  }
}
