import 'package:flutter/material.dart';
import 'package:yaba_objectdetection_template/home.dart';
import 'package:yaba_objectdetection_template/camera.dart';
import 'package:yaba_objectdetection_template/image_uploader.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/home',
    routes: {
      '/home': (context) => const Home(),
      '/realtime': (context) => const CameraScreen(),
      '/image': (context) => const ImageUploaderScreen(),
    },
  ));
}

