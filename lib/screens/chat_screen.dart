
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rentit_app/component/db_methods.dart';
import 'package:rentit_app/component/message_bubble.dart';
import 'package:rentit_app/entities/constants.dart';
import 'dri_dashboard.dart';
import 'my_dashboard.dart';


class ChattingScreen extends StatefulWidget {
  final String driUserName;
  final String chatRoomId;
  final String cusUserName;
  final String uuid;
  final String userType;

  const ChattingScreen({  required this.driUserName, required this.chatRoomId,  required this.cusUserName, required this.userType, required this.uuid}) ;


  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  TextEditingController messageTextEditingController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  late Stream<QuerySnapshot> chatMessagesStream;

  @override
  void initState() {
    getMessages();


    super.initState();
  }
  bool isLoading = false;
  getMessages() async {
    setState(() {
      isLoading = true;
    });
    await databaseMethods
        .getConversationMessages(widget.chatRoomId,widget.driUserName)
        .then((value) {
      setState(() {
        chatMessagesStream = value;
        isLoading = false;
      });
    });
  }

   late String messageText;
  sendMessage(String message) async {
    List<String> list = [widget.uuid];
    print('list item ${widget.uuid}');

    if (message.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': message,
        'sendBy': widget.cusUserName,
        'timeStamp': DateTime.now(),
        'time': DateFormat.jm().format(DateTime.now()),
        'read' : 'unread'
      };
      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);

      var r = await databaseMethods.sendNotification(list,
          message, 'New Message arrived');
      print(r.statusCode);
      print('...................................................');
      print(r.body);
      print('...................................................');

      print(r.headers);
      print('...................................................');

      print(r.request);
      print('...................................................');

      setState(() {
        messageTextEditingController.clear();
      });
    }
  }


  // FileType _pickingType = FileType.custom;
  var filePath;
  


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          widget.userType == 'customer' ?
          Navigator.push(context, MaterialPageRoute(builder: (context)=> MyDashboard(stat: 'status',)))
              :
          Navigator.push(context , MaterialPageRoute(builder: (context)=>DriDashboard()));
          return false;
        },
        child: Scaffold(
          // return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(

            toolbarHeight: 60,
            leadingWidth: 20,
            title: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 40,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Text(
                  widget.driUserName,
                  style:
                  GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          body: isLoading?Container(child: const Center(
            child: CircularProgressIndicator(),
          ),):SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                StreamBuild(
                  chatMessageStream: chatMessagesStream,
                  customerUserName: widget.cusUserName,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 8.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.0),
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8.0,
                                ),

                                Expanded(
                                  child: TextField(
                                    cursorColor: const Color(0xFF00b19c),
                                    cursorHeight: 28,
                                    controller: messageTextEditingController,
                                    maxLines: null,
                                    onChanged: (val) {
                                      messageText = val;
                                    },

                                    decoration: kTextFormFieldDecoration.copyWith(
                                      hintText: '',
                                      labelText: 'Message',

                                    ),
                                  ),
                                ),


                                const SizedBox(
                                  width: 10.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          messageTextEditingController.clear();
                          sendMessage(messageText);
                          setState(() {
                            messageText = '';
                          });
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.send,
                            color: Color(0xFFfdffff),
                            size: 17,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
    // );
  }
}

class StreamBuild extends StatelessWidget {
  final Stream<QuerySnapshot> chatMessageStream;
  final String customerUserName;
  const StreamBuild({ required this.chatMessageStream, required this.customerUserName}) ;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: const Center(child: CircularProgressIndicator()),
          );
        } else {
          final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messagesBubbles = [];
          for (var message in messages) {
            final messageText = message.get('message');
            final sender = message.get('sendBy');
            final currentUser = customerUserName;
            final timeStamp = message.get('time');
            final read = message.get('read');
            print(timeStamp);

            final messageBubble = MessageBubble(
                timeStamp: timeStamp,
                message: messageText,
                sender: sender,
                isMe: currentUser == sender,
                read: read
            );
            messagesBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messagesBubbles,
            ),
          );
        }
      },
    );
  }
}
