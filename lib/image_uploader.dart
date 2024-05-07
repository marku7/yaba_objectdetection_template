import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ImageUploaderScreen extends StatefulWidget {
  const ImageUploaderScreen({super.key});

  @override
  State<ImageUploaderScreen> createState() => _ImageUploaderScreen();
}

class _ImageUploaderScreen extends State<ImageUploaderScreen> {
  late List _recognitions;
  final ImagePicker _picker = ImagePicker();
  late XFile _image;
  String result = '';
  File? _selectedImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  Future loadModel() async{
    await Tflite.loadModel(
        model: "assets/mode_unquant.tflite",
        labels: "assets/labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false
    );
  }

  Future pickImage(ImageSource source) async {
    var pickedFile = await _picker.pickImage(source: source);
    XFile? xfilePick = pickedFile;
    if (xfilePick != null) {
      _selectedImage = File(xfilePick.path);
    }
    recognizeImageBinary(pickedFile!);
  }


  Future recognizeImageBinary(XFile image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var imageBytes = await image.readAsBytes();
    img.Image? oriImage = img.decodeJpg(imageBytes);
    img.Image resizedImage = img.copyResize(oriImage!, height: 224, width: 224);
    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
      // binary: imageToByteListUint8(resizedImage, 224),
      numResults: 6,
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions!;
    });
    setState(() {
      result = _recognitions[0]['label'];
    });
    print(_recognitions);
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }


  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List((1 * inputSize * inputSize * 3));
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }


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
  title: const Text('Upload Image'),
),

      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            const SizedBox(height: 50),
            const Text('Choose Image from: '),
            ElevatedButton(
                onPressed: () {pickImage(ImageSource.camera);},
                child: Text('Camera')
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () {pickImage(ImageSource.gallery);},
                child: Text('File Manager')
            )
          ],
        ),
      ),
    );
  }
}
