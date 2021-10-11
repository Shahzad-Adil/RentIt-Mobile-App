import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rentit_app/helper%20classes/customer.dart';
import 'package:rentit_app/helper%20classes/driver.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';
import 'package:rentit_app/helper%20classes/trip.dart';
import 'package:rentit_app/providers/current_variable_provider.dart';
import 'package:rentit_app/providers/customer_provider.dart';
import 'package:rentit_app/providers/driver_provider.dart';
import 'package:rentit_app/providers/terminal_provider.dart';
import 'package:rentit_app/providers/trip_provider.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps Demo',
      debugShowCheckedModeBanner: false,
      home: MapWidget(),
    );
  }
}

class MapWidget extends StatefulWidget {

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(33.68781925804353, 73.047608210824),
    zoom: 11.5,
  );


  late GoogleMapController _googleMapController;
  List<Marker> markers = [];
  String current = 'false';
  late Marker currentMarker;

  bool isCustomerFound = false;
  bool isDriverFound = false;

  List<Customer> custom = [];
  List<Driver> drive = [];

   Terminal? dTerminal;

  Future<List<Trip>>getCurrentList() async
  {
    List<Trip> tripList =  await Provider.of<TripProvider>(
        context,
        listen: false).getListTrip();
    return tripList;

  }

  Future<void> checkCurrentRide() async {

    List<Trip> tripList= await getCurrentList();

    User? user = FirebaseAuth.instance.currentUser;


    var longitude;
    var latitude;

    print('tripList in map widget ${tripList.length}');

    if(isDriverFound){
      for(var t in tripList)
      {
        if(t.driver!.email==user!.email)
        {
          print('tripList : user matched');
          print(t.status);
          if(t.status=='current')
          {
            print('tripList : current');
            longitude=t.vehicle!.terminal.longitude;
            latitude=t.vehicle!.terminal.latitude;

            print('tripList : longitude : $longitude');
            print('tripList : latitude : $latitude');


            setState(() {
              currentMarker=Marker(
                markerId: MarkerId(t.vehicle!.terminal.id.toString()),
                infoWindow: InfoWindow(title: t.vehicle!.terminal.name),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                position: LatLng(latitude, longitude),
              );
              current='true';
              Provider.of<CurrentVariable>(context, listen: false).update('current');
              _initialCameraPosition = CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 11.5,
              );
            });
          }
        }
      }
    }
    if(isCustomerFound){
      for(var t in tripList)
      {
        if(t.customer!.email==user!.email)
        {
          print('tripList : user matched');
          print(t.status);
          if(t.status=='current')
          {
            print('tripList : current');
            longitude=t.vehicle!.terminal.longitude;
            latitude=t.vehicle!.terminal.latitude;

            print('tripList : longitude : $longitude');
            print('tripList : latitude : $latitude');


            setState(() {
              currentMarker=Marker(
                markerId: MarkerId(t.vehicle!.terminal.id.toString()),
                infoWindow: InfoWindow(title: t.vehicle!.terminal.name),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                position: LatLng(latitude, longitude),
              );
              current='true';
              Provider.of<CurrentVariable>(context, listen: false).update('current');
              _initialCameraPosition = CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 11.5,
              );
            });
          }
        }
      }
    }
  }

  Future<void> getMarkers() async {

    List<Terminal> terminals =await Provider.of<TerminalProvider>(context, listen: false).getListTerminal();


    for (var terminal in terminals) {
      setState(() {
        markers.add(Marker(
          markerId: MarkerId(terminal.id.toString()),
          infoWindow: InfoWindow(title: terminal.name),
          icon: isDriverFound ? dTerminal!=null ? terminal.id==dTerminal!.id ?
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          position: LatLng(terminal.latitude, terminal.longitude),
        ));
      });
    }
  }

  // Marker _origin = Marker(
  //   markerId: const MarkerId('origin'),
  //   infoWindow: const InfoWindow(title: 'Origin'),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //   position: LatLng(33.659202994622184, 73.02385996612809),
  // );
  //
  // Marker _destination = Marker(
  //   markerId: const MarkerId('destination'),
  //   infoWindow: const InfoWindow(title: 'Destination'),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //   position: LatLng(33.6750614538563, 73.03501795563196),
  // );

  void getLoggedinUserDetails() {
    custom = Provider.of<CustomerProvider>(context, listen: false).listCustomer;
    drive = Provider.of<DriverProvider>(context, listen: false).listDrivers;

    User? u = FirebaseAuth.instance.currentUser;

    for (var a in custom) {
      if (a.email == u!.email) {
        // name = a.name;
        // email = a.email;
        // cnic = a.cnic;
        // description = a.description;
        // phone = a.phone;
        // username = a.userName;

        setState(() {
          isCustomerFound = true;
        });
        return;
      }
    }

    for (var a in drive) {
      if (a.email == u!.email) {
        setState(() {
          isDriverFound = true;
          dTerminal = a.terminal!;
        });
        return;
      }
    }
  }

  @override
  void initState()  {

    super.initState();
    getLoggedinUserDetails();
    checkCurrentRide();
    getMarkers();

  }

  @override
  void dispose() {

    super.dispose();
    _googleMapController.dispose();
  }

  Future<void> locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng latLng = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 12);

    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    print(cameraPosition);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: (controller) {
            _googleMapController = controller;
            locatePosition();
          },
          markers:
          {
            if (current == 'false')
              for (int i = 0; i < markers.length; i++) markers[i],
            if (current == 'true') currentMarker,
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
