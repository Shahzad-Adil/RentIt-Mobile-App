import 'package:flutter/cupertino.dart';

class CurrentVariable extends ChangeNotifier
{
   String current='cancelled';

   void update(var status)
   {
     current=status;
     notifyListeners();
   }


}

