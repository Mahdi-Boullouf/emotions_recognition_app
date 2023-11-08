import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/models/model.tflite',
      labels: 'assets/models/labels.txt',
    );
  }

  _detectImage(BuildContext context, String image) async {
    var predection = await Tflite.runModelOnImage(
      path: image,
      numResults: 4,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    if (predection!.isNotEmpty) {
      double confidence = double.parse(
              predection[0]['confidence'].toStringAsFixed(2).toString()) *
          100;

      String label = predection[0]['label'].substring(2);

      Flushbar(
        duration: const Duration(seconds: 2),
        message: label + " confidence : " + confidence.toString() + "%",
        isDismissible: true,
        margin: const EdgeInsets.all(14),
      ).show(context);
    }
    print(predection);
  }

  _loadImageFromCamera(
    BuildContext context,
  ) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    await _detectImage(context, image.path);
  }

  _loadImageFromGallery(
    BuildContext context,
  ) async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    _detectImage(context, image.path);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Emotions Recoginition'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png'),
            FilledButton(
                onPressed: () {
                  _loadImageFromCamera(context);
                },
                child: const Text('Camera')),
            FilledButton(
                onPressed: () => _loadImageFromGallery(context),
                child: const Text('Choose Image')),
            SizedBox(
              height: 20,
            ),
            const Text(
              'By Mahdi Boullouf',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
