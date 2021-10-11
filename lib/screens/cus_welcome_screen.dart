import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/component/app_drawer.dart';
import 'package:rentit_app/component/map_widget.dart';
import 'package:rentit_app/component/rounded_button.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/providers/current_variable_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';
import 'package:rentit_app/screens/rent_a_vehicle.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');

}

const AndroidNotificationChannel  channel =  AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class CusWelcomeScreen extends StatefulWidget {
  @override
  _CusWelcomeScreenState createState() => _CusWelcomeScreenState();
}

class _CusWelcomeScreenState extends State<CusWelcomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final showSpinner = false;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> getToken() async {
    await _firebaseMessaging.getToken().then((token) => print('|||||||||||||||||||||||||$token'));
  }

  Future<void> notiPlugin () async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  List<Trip> allTrips = [];


  Future<void> getCurrentUserRides() async {
    User? user = FirebaseAuth.instance.currentUser;

    print('-----------------------------');
    print('Inside Method');
    print(user!.email);
    print('-----------------------------');

    allTrips = await Provider.of<TripProvider>(context, listen: false).getListTrip();

    print(allTrips);


    for (var tripp in allTrips) {
      print(tripp.customer!.email);
      print(tripp.optionDriver);
      if (tripp.customer!.email == user.email) {

          if (tripp.status == 'accepted') {
            Provider.of<CurrentVariable>(context,listen: false).update('accepted');

        } else if (tripp.status == 'current') {
            Provider.of<CurrentVariable>(context,listen: false).update('current');

          } else if (tripp.status == 'pending') {
            Provider.of<CurrentVariable>(context,listen: false).update('pending');

          } else if (tripp.status == 'ending') {
            Provider.of<CurrentVariable>(context,listen: false).update('ending');

          }
      }
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    notiPlugin();
    getCurrentUserRides();



    var initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentVariable>(
        builder: (context, currentVariable, Widget? child) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('RentIt'),
          ),
          // body: Center(child: Text('${user!.email}')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: MapWidget(),
              ),
              if((currentVariable.current=='cancelled' ) || (currentVariable.current=='completed' )  )
                Expanded(
                  flex: 1,
                    child: Container(
                      color: Colors.blueGrey,
                      child: RoundedButton(
                        buttonColor: Colors.cyan,
                        buttonText: 'Rent a car',
                        buttonPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RentAVehicle()));
                        }, minWidth: 100,
                      ),
                    ),
                ),
            ],
          ),
          drawer:
          Container(
            width: 250,
            child: AppDrawer(),
          ),
        )
        );
      }
    );

  }
}

