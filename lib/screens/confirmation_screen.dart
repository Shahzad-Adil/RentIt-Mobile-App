import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as Http;
import 'package:rentit_app/component/request_details_container.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/helper%20classes/vehicle.dart';
import 'package:rentit_app/providers/current_variable_provider.dart';
import 'package:rentit_app/providers/trip_post_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';
import 'my_dashboard.dart';

class ConfirmationScreen extends StatefulWidget {


  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {


   late Trip trip;

   @override
   void didChangeDependencies()
   {
     super.didChangeDependencies();
     trip=Provider.of<TripPostProvider>(context).getTrip();
   }


   @override
   void initState()
   {
     super.initState();
   }


   bool _isLoading = false;

  Future<int> sendDataOne (Map<String, dynamic> abc) async {

    print(abc['customer']['name']);

    return await Http.post(Uri.parse('$kIpAddress:7070/api/trips'),
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
        print('-----------------------------------------------------------------------');
        print('eroor sending the whole Data');
        return -1;
      }
    });
  }


   void updateVehicle(Map<String, dynamic> abc) async {

     return await Http.put(Uri.parse('$kIpAddress:7070/api/vehicles'),
         headers: <String, String>{
           'Content-Type': 'application/json',
         },
         body: jsonEncode(abc))
         .then((value) {
       if (value.statusCode == 200) {
         print('-----------------------------Update Completed----------------------');
       } else {
         print(value.statusCode);
         print(value.body);
         print('error sending the whole Data');
       }
       return;
     });


   }

  Future <void> updateDriver() async {
     Map<String, dynamic> mapUpdate = trip.driver!.converttoJson();

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



  @override
  Widget build(BuildContext context) {
    trip=Provider.of<TripPostProvider>(context, listen: false).getTrip();
    return Padding(
      padding: MediaQuery.maybeOf(context)!.viewInsets,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFF757575),
              child: Container(
                padding: const EdgeInsets.all(25.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Request',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RequestDetailsContainer(
                      terminal: trip.terminal!.name,
                      vehicle: trip.vehicle!.vMake,
                      category: trip.vehicle!.category,
                      isDriver: trip.optionDriver, status: trip.status,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            ' Edit ',
                            style: TextStyle(
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent,
                          ),
                          onPressed: () async {


                            setState(() {
                              _isLoading = true;
                            });

                            Vehicle? veh= trip.vehicle;

                            veh!.status=false;

                            Map<String, dynamic> abc=veh.converttoJson();





                            print('----------------------------------------------');
                            print('------------------${trip.customer!.name}------------------------------');
                            print('------------------------------------------------');


                                 await  sendDataOne(trip.convertoJson());

                            updateVehicle(abc);

                           if(trip.optionDriver)
                             {
                               trip.driver!.driverOnTrip=true;
                               await updateDriver();
                             }
                            setState(() {
                              _isLoading = false;
                            });
                           Provider.of<CurrentVariable>(context,listen: false).update('pending');
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyDashboard(stat: '',)));
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }


}
