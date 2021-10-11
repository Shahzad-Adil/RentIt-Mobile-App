import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as Http;
import 'package:rentit_app/component/rounded_button.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/screens/profile_screen.dart';

class EditProfile extends StatefulWidget {


  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {


  var imageNumber;
  late File _image;
  final _storage = FirebaseStorage.instance;
  final imagePicker = ImagePicker();


   Customer customer = Customer(id: -1,name: 'null', description: 'null', cnic: 'null', email: 'null',
                        password: 'null', phone: 'null', userName: 'null');
   Driver driver = Driver(id: -1,name: 'null', description: 'null', cnic: 'null', email: 'null',
       password: 'null', phone: 'null', userName: 'null', terminal: null);

  bool isCustomerFound=false;
  bool isDriverFound=false;

  List<Customer> custom=[];
  List<Driver> drive=[];




  late String imageUrl = '';

  bool isLoading = false;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();


  String? validateName(String? value) {
    if(value!.isNotEmpty){
      if (value.length < 3) {
        return 'Name should be of minimum 3 characters';
      }
    }
  }


  void getLoggedinUserDetails()
  {
    custom=Provider.of<CustomerProvider>(context,listen: false).listCustomer;
    drive=Provider.of<DriverProvider>(context, listen: false).listDrivers;

    User? u =FirebaseAuth.instance.currentUser;

    for(var a in custom )
    {
      if(a.email==u!.email)
      {
        isCustomerFound=true;
        customer=a;
        return;
      }
    }

    for(var a in drive )
    {
      if(a.email==u!.email)
      {
        driver=a;
        return;
      }
    }
  }

  String? validateUsername(String? value) {
    if (value!.isNotEmpty) {
      if (value.length < 6) {
        return 'Username should be of minimum 6 characters';
      }
    }
  }


  String? validatePhone(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value!.isNotEmpty) {
      if (!regExp.hasMatch(value)) {
        return 'Please enter valid mobile number';
      }
    }
  }

  String? validatePassword(String? value) {
    if (value!.isNotEmpty) {
        if (value.length < 6) {
        return 'Minimum Password length is 6';
      }
    }
  }

  getUrl () async {
    setState(() {
      isLoading = true;
    });
    User? u = FirebaseAuth.instance.currentUser;
    final urlInstance = await FirebaseFirestore.instance.collection('urls')
        .where('email' , isEqualTo: u!.email).get();

    setState(() {
      imageUrl = urlInstance.docs[0].get('url');
      isLoading = false;
    });
  }

  updateUrl() async {
    User? u = FirebaseAuth.instance.currentUser;
    final urlInstance = await FirebaseFirestore.instance.collection('urls')
        .where('email' , isEqualTo: u!.email).get();

    String id = urlInstance.docs[0].id;
    await FirebaseFirestore.instance.collection('urls').doc(id).update({'url' : imageUrl});

  }

  void updateDriver(Map<String, dynamic> mapUpdate) async {

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
  void updateCustomer(Map<String, dynamic> mapUpdate) async {

    print('data');
    return await Http.put(Uri.parse('$kIpAddress:7070/api/customers'),
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



  @override
  void initState() {

    super.initState();
    getUrl();
    getLoggedinUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
             Form(
               key: _globalKey,
               child: Padding(
               padding: const EdgeInsets.all(5.0),
               child: Column(
                 children: [
                   const SizedBox(
                     height: 12,
                   ),

                   imageUrl.isNotEmpty ? CircleAvatar(
                         radius: 80,
                         backgroundImage: NetworkImage(imageUrl),
                       )
                   : const CircleAvatar(
                     radius: 80,
                     backgroundImage: AssetImage('images/pic2.png'),
                   ),
                   const SizedBox(
                     height: 5,
                   ),
                   GestureDetector(
                     child: const Text(
                       'Upload new image',
                       style: TextStyle(
                         color: Colors.indigo,
                       ),
                     ),
                     onTap: (){
                       getImage();
                     },
                   ),
                   const SizedBox(
                     height: 20,
                   ),
                   TextFormField(
                     controller: nameController,
                     decoration: kTextFormFieldDecoration.copyWith(
                         labelText: 'Name',
                         hintText: 'Minimum 3 characters'),
                     validator: validateName,
                   ),
                   const SizedBox(
                     height: 10,
                   ),
                   TextFormField(
                     controller: userNameController,
                     decoration: kTextFormFieldDecoration.copyWith(
                         labelText: 'Username',
                         hintText: 'Minimum 6 characters'),
                     validator: validateUsername,
                   ),
                   const SizedBox(
                     height: 10,
                   ),

                   TextFormField(
                     controller: phoneController,
                     decoration: kTextFormFieldDecoration.copyWith(
                         labelText: 'Phone',
                         hintText: 'Enter valid phone number'),
                     validator: validatePhone,
                   ),
                   const SizedBox(
                     height: 10,
                   ),
                   TextFormField(
                     controller: passwordController,
                     decoration: kTextFormFieldDecoration.copyWith(
                         labelText: 'Password',
                         hintText: 'Minimum 6 characters'),
                     validator: validatePassword,
                   ),
                   const SizedBox(
                     height: 10,
                   ),
                   TextFormField(
                     controller: descriptionController,
                     decoration: kTextFormFieldDecoration.copyWith(
                         labelText: 'Description',
                         hintText: 'Enter your description'),
                    // initialValue: 'abc',
                   ),
                   const SizedBox(
                     height: 15,
                   ),
                   RoundedButton(
                     buttonColor: Colors.lightBlueAccent,
                     buttonText: 'Save',
                     buttonPressed: () async {
                        if (_globalKey.currentState!.validate()) {
                          print('Updating............................');

                          await updateUrl();

                          if(isCustomerFound)
                            {
                              if(nameController.text.isNotEmpty)
                                customer.name=nameController.text;
                              if(phoneController.text.isNotEmpty)
                                customer.phone=phoneController.text;
                              if(userNameController.text.isNotEmpty)
                                customer.userName=userNameController.text;
                              if(passwordController.text.isNotEmpty)
                                customer.password=passwordController.text;
                              if(descriptionController.text.isNotEmpty)
                                customer.description=descriptionController.text;

                              updateCustomer(customer.convettoJson());

                            }
                          else
                            {
                              if(nameController.text.isNotEmpty)
                                driver.name=nameController.text;
                              if(phoneController.text.isNotEmpty)
                                driver.phone=phoneController.text;
                              if(userNameController.text.isNotEmpty)
                                driver.userName=userNameController.text;
                              if(passwordController.text.isNotEmpty)
                                driver.password=passwordController.text;
                              if(descriptionController.text.isNotEmpty)
                                driver.description=descriptionController.text;


                              updateDriver(driver.converttoJson());

                            }

                          Navigator.pushReplacement( context, MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()));
                        }
                     },
                     minWidth: 100,
                   ),
                 ],
               ),
             ),),
            ],
          ),
        ),
      ),
    ));
  }

  Future getImage() async{
    final image = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    await Future.delayed(const Duration(seconds: 2), (){});
    setState(() {
      _image = File(image!.path);
      imageNumber = DateTime.now().millisecondsSinceEpoch;

    });

    if(image != null){
      setState(() {
        isLoading = true;
      });
      var snapshot = await _storage.ref()
          .child('images/image$imageNumber').putFile(_image);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
      print('url....................$url');
      setState(() {
        isLoading = false;
      });
    }
  }

}
