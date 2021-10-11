
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/helper%20classes/trip.dart';

class TripPostProvider extends ChangeNotifier
{

  late Trip trip;


  getTrip()
  {
    return trip;

  }

  setTrip(Trip p)
  {
    print('-------------------------------------------------------------');
    print(p.customer!.name);
    trip=p;
    notifyListeners();
  }

}