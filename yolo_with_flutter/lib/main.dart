import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:camera_picture/globalVal.dart';
import 'package:camera_picture/server.dart';
import 'package:camera_picture/startPage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

late Future<void> _initializeControllerFuture;
late CameraController _controller;
late Count_Detected_Cup count_detected_cup;
final navigatorKey = GlobalKey<NavigatorState>();
late final cameraPick ;
Future<void> captureOneFPS() async {
  await _initializeControllerFuture;
  // Attempt to take a picture and get the file `image`
  // where it was saved.
  var stopWatch = Stopwatch();
  stopWatch.start();
  final image = await _controller.takePicture();
  stopWatch.stop();
  log('Time is ${stopWatch.elapsed}');

  //This method throw image to server and get the results
  final response = await postRequest(image.path);

  return;
}

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  //const timeDuration = Duration(milliseconds: 300);
  //Timer.periodic(timeDuration, (Timer t) => captureOneFPS());

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  cameraPick = firstCamera;
  log('Glory');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Count_Detected_Cup()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData.dark(),
        routes: {
          '/' : (BuildContext context) => MyHomePage(),
          // Pass the appropriate camera to the TakePictureScreen widget.
          '/start' : (BuildContext context) => TakePictureScreen(camera: firstCamera),
        },
        navigatorKey: navigatorKey,

      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.low,
    );
    _controller.setExposureMode(ExposureMode.auto);
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    count_detected_cup = Provider.of<Count_Detected_Cup>(context, listen: false);
    count_detected_cup.clear();
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            const timeDuration = Duration(milliseconds: 300);
            Timer.periodic(timeDuration, (Timer t) => captureOneFPS());
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
