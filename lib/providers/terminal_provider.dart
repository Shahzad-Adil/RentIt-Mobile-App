
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';
import 'package:rentit_app/entities/constants.dart';
import 'package:rentit_app/helper%20classes/terminal.dart';



class TerminalProvider extends ChangeNotifier {
  List<Terminal> listTerminals = [];

  void updateTerminal(int index, Terminal terminal) {
    listTerminals[index].name = terminal.name;
    listTerminals[index].description = terminal.description;
    notifyListeners();
  }

  int get taskCount {
    return listTerminals.length;
  }

  UnmodifiableListView<Terminal> get tasks {
    return UnmodifiableListView(listTerminals);
  }

  void addTerminal(Terminal t) {
    listTerminals.add(t);
    notifyListeners();
  }

  void deleteTerminal(Terminal t) {
    listTerminals.remove(t);
    notifyListeners();
  }

  Future getListTerminal() async {
    listTerminals.clear();
    print('data');
    return await Http.get(Uri.parse('$kIpAddress:7070/api/terminals'))
        .then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        final jsonData = jsonDecode(data.body);

        for (var item in jsonData) {

          final terminal = Terminal(
              longitude: item['longitude'],
              latitude: item['latitude'],
              name: item['name'],
              description: item['description'],
              id: item['id']);
          listTerminals.add(terminal);
        }
        for(var a in listTerminals)
        {
          print(a.name);
        }
        print(listTerminals.length);

      }

      notifyListeners();
      return listTerminals;
    });
  }
}