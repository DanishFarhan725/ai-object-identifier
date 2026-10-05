// lib/screens/object_detection_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:object_detect/screens/signin.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class ObjectDetectionPage extends StatefulWidget {
  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  late Interpreter interpreter;
  List<String> labels = [];
  String result = "";
  File? _image;

  @override
  void initState() {
    super.initState();
    loadModelAndLabels();
  }

  Future<void> loadModelAndLabels() async {
    interpreter = await Interpreter.fromAsset('assets/identifier.tflite');
    final labelData = await rootBundle.loadString('assets/labels.txt');
    labels = labelData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() => _image = File(picked.path));
      await predict(File(picked.path));
    }
  }

  Future<void> predict(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    img.Image resized = img.copyResize(image!, width: 150, height: 150);

    var input = List.generate(1, (_) => List.generate(150, (y) =>
        List.generate(150, (x) {
          final pixel = resized.getPixelSafe(x, y);
          final r = pixel.r.toDouble() / 255.0;
          final g = pixel.g.toDouble() / 255.0;
          final b = pixel.b.toDouble() / 255.0;
          return [r, g, b];
        })));

    var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);
    interpreter.run(input, output);

    final confidences = output[0];
    int maxIndex = 0;
    double maxConfidence = confidences[0];

    for (int i = 1; i < confidences.length; i++) {
      if (confidences[i] > maxConfidence) {
        maxConfidence = confidences[i];
        maxIndex = i;
      }
    }

    setState(() {
      result = "${labels[maxIndex]}\nConfidence: ${(maxConfidence * 100).toStringAsFixed(2)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar:AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF185A9D),
        centerTitle: true,
        title: const Text('Object Detector', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              )
                  : Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No image selected'),
                ),
              ),
              if (result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 30.0,bottom: 30.0),
                  child: Center(
                    child: Text(
                      result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185A9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185A9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text('Pick from Gallery', style: TextStyle(color: Colors.white)),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
