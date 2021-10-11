import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/screens/cus_welcome_screen.dart';
import 'package:rentit_app/screens/login_screen.dart';
import 'package:rentit_app/screens/my_dashboard.dart';
import 'package:rentit_app/screens/profile_screen.dart';

class AppDrawer extends StatefulWidget {


  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  
  String url = '';

  bool isLoading = false;

  List<Customer> custom=[];
  List<Driver> drive=[];
  
  String name = '';


  void getLoggedinUserDetails()
  {
    custom=Provider.of<CustomerProvider>(context,listen: false).listCustomer;
    drive=Provider.of<DriverProvider>(context, listen: false).listDrivers;

    User? u =FirebaseAuth.instance.currentUser;

    for(var a in custom )
    {
      if(a.email==u!.email)
      {
        setState(() {
          name=a.name;
        });
       
        return;
      }
    }

    for(var a in drive)
    {
      if(a.email==u!.email)
      {
        setState(() {
          name=a.name;
        });
        return;
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
      url = urlInstance.docs[0].get('url');
      isLoading = false;
    });

  }
  
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUrl();
    getLoggedinUserDetails();
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ?  const Center(child: CircularProgressIndicator()) : Drawer(
      child: ListView(

        padding: EdgeInsets.zero,
        children: [

          const SizedBox(
            height: 8,
          ),
  
          if(url.isEmpty)
            _createHeader('',''),
          
          if(url.isNotEmpty)
            _createHeader(url,name),

          _createDrawerItem(icon: Icons.home, text: 'Home',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>CusWelcomeScreen()))),

          _createDrawerItem(icon: Icons.category, text: 'My Dashboard',
              onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context)=>const MyDashboard(stat: '',)))),

          _createDrawerItem(icon: Icons.account_circle, text: 'My Profile',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))),

          Divider(),

          ListTile(
            title: Row(
              children: const <Widget>[
                Icon(Icons.logout_rounded),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Logout'),
                )
              ],
            ),
          onTap: ()  async {
            await  FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          },
          ),

        ],
      ),
    );
  }
}


Widget _createHeader(String url, String name) {
  return DrawerHeader(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 15),

      child: Stack(children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              if(url.isNotEmpty)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(url),
                ),
              if(url.isEmpty)  
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/pic2.png'),
                ),
              const SizedBox(
                height: 5,
              ),
               Text(name,
                style: const TextStyle(
                    color: Colors.deepPurple,
                    letterSpacing: 2
                ),),
            ],
          ),
        ),
      ]));
}


Widget _createDrawerItem(
    { required IconData icon, required String text, required GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}