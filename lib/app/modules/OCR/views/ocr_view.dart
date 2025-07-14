import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ocr_controller.dart';

class OcrView extends GetView<OcrController> {
  const OcrView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OcrView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'OcrView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
