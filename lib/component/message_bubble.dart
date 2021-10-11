
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble({ required this.message, required this.sender, required this.isMe, required this.timeStamp,  required this.read});
  final String message;
  final String sender;
  final bool isMe;
  final String timeStamp,read;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.only(
          left: widget.isMe ? 60.0 : 17.0,
          right: widget.isMe ? 17.0 : 60.0,
        ),
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: Uri.parse(widget.message).isAbsolute?const EdgeInsets.symmetric(horizontal: 5, vertical: 5):const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: widget.isMe
                  ? const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0))
                  : const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
              gradient: LinearGradient(colors: [
                // widget.isMe ? Color(0xFF054640) : Color(0xFF212e36),
                widget.isMe ? Colors.blueAccent : Colors.blueGrey,
                widget.isMe ? const Color(0xFF043d36) : Colors.black45,

                // widget.isMe ? Color(0xFF043d36) : Color(0xFF212e36)
              ]),
            ),
            child :  RichText(
              text: TextSpan(
                  text: widget.message,
                  style: GoogleFonts.roboto(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9)),
                  children: [
                    const TextSpan(text: '  '),

                    TextSpan(
                        text: widget.timeStamp,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        )),
                    const TextSpan(text: '  '),
                    if(widget.isMe)
                      WidgetSpan(
                        child: Icon(Icons.check_circle_outline,
                          color: widget.read == 'read' ? Colors.blue : Colors.white,),
                      ),


                  ]),
            )
        )
    );

    // );
  }


}