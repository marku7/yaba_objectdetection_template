import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import  'package:yaba_objectdetection_template/scanner_controller.dart';


class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/home');
        },
      ),
      title: const Text('Realtime Camera'),
    ),

        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 600,
                width: 400,
                child: GetBuilder<ScannerController>(
                  init: ScannerController(),
                  builder: (controller){
                    return controller.isCameraInitialized.value ?
                    CameraPreview(controller.cameraController) : const Center(
                      child: Text('Initializing camera....'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              GetBuilder<ScannerController>(
                builder: (controller) {
                  return Text(
                    controller.wasteResult.value ?? 'No trash/garbage detected',
                    style: const TextStyle(fontSize: 20),
                  );
                },
              ),
            ],
          ),
        )
    );
  }
}
