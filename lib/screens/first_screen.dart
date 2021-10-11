import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FirstScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // return Row(
    //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     Text('Customer'),
    //     // SizedBox(width: 10,),
    //     Text('Driver'),
    //   ],
    // );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Center(
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text('Customer', style: TextStyle(
                    //   color: Colors.white,
                    //   fontSize: 25
                    // ),),

                    TextLiquidFill(
                      text: 'CUSTOMER',
                      waveColor: Colors.deepPurple,
                      boxBackgroundColor: Colors.lightBlue,
                      textStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                      boxHeight: 150.0,
                      boxWidth: 150,
                    ),
                    // SizedBox(width: 10,),
                    VerticalDivider(
                      color: Colors.white30,
                      width: 1,
                      thickness: 1,
                    ),
                    // TextLiquidFill(
                    //   text: 'DRIVER',
                    //   waveColor: Colors.deepPurple,
                    //   waveDuration: Duration(seconds: 5),
                    //
                    //   boxBackgroundColor: Colors.lightBlue,
                    //   textStyle: TextStyle(
                    //     fontSize: 25.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   boxHeight: 150.0,
                    //   boxWidth: 150,
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText('Sign In',
                                  textStyle: TextStyle(fontSize: 16)),
                            ],
                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                          //
                          // SizedBox(
                          //   height: 12,
                          // ),

                          Divider(
                            color: Colors.white,
                          ),

                          AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText('Sign Up',
                                  textStyle: TextStyle(fontSize: 16)),
                            ],
                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(
                  color: Colors.white,
                  height: 3,
                  // thickness: 1,

                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text('Customer', style: TextStyle(
                    //   color: Colors.white,
                    //   fontSize: 25
                    // ),),

                    TextLiquidFill(
                      text: 'DRIVER',
                      waveColor: Colors.deepPurple,
                      boxBackgroundColor: Colors.lightBlue,
                      textStyle: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                      boxHeight: 150.0,
                      boxWidth: 150,
                    ),
                    // SizedBox(width: 10,),
                    VerticalDivider(
                      color: Colors.white30,
                      width: 1,
                      thickness: 1,
                    ),
                    // TextLiquidFill(
                    //   text: 'DRIVER',
                    //   waveColor: Colors.deepPurple,
                    //   waveDuration: Duration(seconds: 5),
                    //
                    //   boxBackgroundColor: Colors.lightBlue,
                    //   textStyle: TextStyle(
                    //     fontSize: 25.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   boxHeight: 150.0,
                    //   boxWidth: 150,
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText('Sign In',
                                  textStyle: TextStyle(fontSize: 16)),
                            ],
                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                          //
                          // SizedBox(
                          //   height: 12,
                          // ),

                          Divider(
                            color: Colors.white,
                          ),

                          AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText('Sign Up',
                                  textStyle: TextStyle(fontSize: 16)),
                            ],
                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
