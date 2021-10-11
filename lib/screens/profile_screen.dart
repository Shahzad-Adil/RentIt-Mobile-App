import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/screens/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String url = '';

  bool isLoading = false;

  String name = '';
  String description = '';
  String email = '';
  String phone = '';
  String cnic = '';
  String username = '';

  bool isCustomerFound = false;
  bool isDriverFound = false;

  List<Customer> custom = [];
  List<Driver> drive = [];

  late Customer customer;
  late Driver driver;

  getUrl() async {
    setState(() {
      isLoading = true;
    });
    User? u = FirebaseAuth.instance.currentUser;
    final urlInstance = await FirebaseFirestore.instance
        .collection('urls')
        .where('email', isEqualTo: u!.email)
        .get();

    setState(() {
      url = urlInstance.docs[0].get('url');
      isLoading = false;
    });
  }

  void getLoggedinUserDetails() {
    custom = Provider.of<CustomerProvider>(context, listen: false).listCustomer;
    drive = Provider.of<DriverProvider>(context, listen: false).listDrivers;

    User? u = FirebaseAuth.instance.currentUser;

    for (var a in custom) {
      if (a.email == u!.email) {
        name = a.name;
        email = a.email;
        cnic = a.cnic;
        description = a.description;
        phone = a.phone;
        username = a.userName;

        isCustomerFound = true;
        return;
      }
    }

    for (var a in drive) {
      if (a.email == u!.email) {
        name = a.name;
        email = a.email;
        cnic = a.cnic;
        description = a.description;
        phone = a.phone;
        username = a.userName;
        isDriverFound = true;
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUrl();
    getLoggedinUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(url),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'SourceSansPro',
                        color: Colors.deepPurple,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'SourceSansPro',
                        color: Colors.deepPurple,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomContainer(
                      icon: Icons.account_circle,
                      text: username,
                    ),
                    CustomContainer(text: email, icon: Icons.email),
                    CustomContainer(text: phone, icon: Icons.phone),
                    CustomContainer(text: cnic, icon: Icons.wysiwyg),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                                color: Colors.lightBlueAccent, fontSize: 15),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.edit,
                            color: Colors.deepPurple,
                            size: 15,
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfile()));
                      },
                    ),
                  ],
                ),
              ),
            ),
    ));
  }
}

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
              width: 180,
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 16.0, color: Colors.white, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
