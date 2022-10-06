import 'dart:io';
import 'package:camera_picture/alertMessage.dart';
import 'package:camera_picture/main.dart';
import 'package:camera_picture/startPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'globalVal.dart';
late double _previousYaxis;

//This is a class for json parse
class YoloResult {
  late String classes ;
  late double confidence ;
  late List<double>? box ;

  YoloResult({required this.classes, required this.confidence, this.box});

  YoloResult.fromJson(Map<String, dynamic> json) {
    classes = json['class'];
    confidence = json['confidence'];
    box = json['box'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class'] = classes;
    data['confidence'] = confidence;
    data['box'] = box;
    return data ;
  }

}

//This method response and request with server
postRequest(String imagePath) async {

  File imageFile = File(imagePath);
  //List<int> imageBytes = imageFile.readAsBytesSync();
  //String base64Image = base64Encode(imageBytes);
  //print("This is image to 64Image" + base64Image) ;

  //Uri url = Uri.parse('http://127.0.0.1:5000/multiply');

  //From this URL is IP address of connected server
  Uri url = Uri.parse('http://172.18.158.81:5000/image/by-application');
  final request = http.MultipartRequest("POST", url);
  final header = {"Content-type": "multipart/form-data"};

  //Add Image on bytestream.
  request.files.add(
    http.MultipartFile('images', imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
    filename: imagePath.split("/").last)
  );

  request.headers.addAll(header);

  //send request to server
  final response = await request.send();
  //get response from server on json
  http.Response res = await http.Response.fromStream(response) ;
  final resJson = json.decode(res.body) ;

  //log("AAAAAAAAAAAA        ${resJson['response'][0]['class']}     AAAAAAAAA");
  log("word is ${resJson['response']}");
  //This changes List<dynamic> into List<YoloResult> for looping items in list.
  List<YoloResult> temp = resJson['response'][0]['*'] == "empty" ? [] : (resJson['response'] as List).map((itemYolo) => YoloResult.fromJson(itemYolo)).toList();
  //print("@@@@@@@@ ${resJson['response'][0]['class']} @@@ + ${resJson['response'][0]['box']}");
  //print("###########" + temp[0].classes);

  //This method counts how many times cup captured <- 리스트에서 1번만 센다.
  if(!count_detected_cup.returnCup) {
    for (YoloResult it in temp) {
      if (count_detected_cup.count.toInt() == 3) {
        count_detected_cup.nextStep();
        detectSuccessDialog();
        break;
      }
      else if (it.classes == "reusable") {
        //If 'reusable cup is detected count.
        count_detected_cup.add();
        _previousYaxis = it.box![2];
        break;
      }
    }
  }
  else if(count_detected_cup.ydegree) {

    if(count_detected_cup.count.toInt() == 6) {
      //mmessage 초기화면.
      showHandDialog();
      count_detected_cup.clear();
      //Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
    else if(resJson['response'][0]["*"] == "empty") {
      count_detected_cup.add();
    }
  }
  else {
    for(YoloResult it in temp) {
      if(it.classes == "reusable")
        {
          if(it.box![2] < _previousYaxis)
          {
              count_detected_cup.checked();
          }
          _previousYaxis = it.box![2];
        }
    }
  }

}