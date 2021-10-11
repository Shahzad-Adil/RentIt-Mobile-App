import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:rentit_app/entities/constants.dart';


class DatabaseMethods {


  // getUsersByName(String userName) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('name', isEqualTo: userName)
  //       .get();
  // }

  // getUsersByEmail(String email) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: email)
  //       .get();
  // }

  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .add(messageMap)
        .catchError((e) {
      print(e);
    });
  }

  Future getLastMessage(String chatRoomId, String username) async {

    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('timeStamp',descending: true)
        .limit(1)
        .get();
  }

  getConversationMessages(String chatRoomId,String username) async {
    QuerySnapshot chats = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .where('sendBy', isEqualTo: username)
        .where('read',isEqualTo: 'unread').get();
    print(chats.docs.length);
    for(int i=0; i<chats.docs.length;i++){
      FirebaseFirestore.instance.collection('ChatRoom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(chats.docs[i].id)
          .update({'read': 'read'});
    }
    Stream<QuerySnapshot> querySnapshot =  await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('timeStamp')
        .snapshots();
    return querySnapshot;
  }
  Future getNotifications()async{
    print('wnenk');
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where('users', arrayContains: 'kUserName')
        .get();


  }
  getChatRooms(String username) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where('users', arrayContains: username)
        .snapshots();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection('users').add(userMap);
  }
  uploadDocInfo(userMap) {
    FirebaseFirestore.instance.collection('doctors').add(userMap);
  }

  createChatRoom(String chatroomId, chatRoomMap, String cusUserName) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatroomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<Response> sendNotification(List<String> tokenIds, String contents, String heading) async{

    print ('in send methd...');

    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>
      {
        "app_id": kAppId,//kAppId is the App Id that one get from the OneSignal When the application is registered.

        // "include_player_ids": tokenIdList,//tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // "include_player_ids": tokenIds,

        "include_player_ids": tokenIds,

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color":"FF9976D2",

        "small_icon":"ic_launcher",

        "in_focus_display_options": 'Entities.InFocusDisplayOption.NOTIFICATION',

        // "large_icon":"https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",

        "headings": {"en": heading},

        "contents": {"en": contents},


      }),
    );

  }

}