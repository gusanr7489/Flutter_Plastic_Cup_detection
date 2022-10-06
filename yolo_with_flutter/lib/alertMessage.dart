import 'package:camera_picture/main.dart';
import 'package:flutter/material.dart';

void detectSuccessDialog() {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Text("다회용컵이 인식되었습니다."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("투입구에 컵을 투입하여 반납을 진행해주세요."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      });
}

void catchCupDialog() {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Text("반납 진행 중입니다."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("손을 잠시만 인식시켜 주세요."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      });
}

void showHandDialog() {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Text("반납이 완료되었습니다."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("감사합니다."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(navigatorKey.currentContext!);
              },
              child: const Text("확인"),
            ),
          ],
        );
      });
}