import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class MyHomePage extends StatefulWidget {


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'img/techno.png',
              fit: BoxFit.contain,
              height: 60,
            )
          ]),
        backgroundColor: Colors.white,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          height: 400,
          width: 500,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.lightBlue,
              width: 4,
            ),
            color: Colors. white,
          ),
          child: Column(
           children: [
             Container(
               padding: const EdgeInsets.only(top:90),
               height: 250,
               child: const Text(
                 '반납을 원하시는 경우\n아래 버튼을 클릭해주세요.',
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
               ),
             ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: cameraPick)));
                print('Button clicked');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
                minimumSize: const Size(150, 80),
              ),
              child: const Text('CAMERA', style: TextStyle(color: Colors.black)),
            ),
           ],
          )

        ),
      ),
    );
  }
}
