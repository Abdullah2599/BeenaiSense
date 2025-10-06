import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:flutter/services.dart';

class TFLiteDetector {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const int inputSize = 320;
  static const double confidenceThreshold = 0.4;
  static const double iouThreshold = 0.5;
  static bool _isInitialized = false;

  // Initialize the model
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(
        'assets/yolo11n_object365_float32.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      
      // Load labels
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      _isInitialized = true;
      print('✅ TFLite model loaded: ${_labels?.length} classes');
      print('📦 Input tensor shape: ${_interpreter!.getInputTensor(0).shape}');
      print('📦 Input tensor type: ${_interpreter!.getInputTensor(0).type}');
      print('📦 Output tensor shape: ${_interpreter!.getOutputTensor(0).shape}');
      print('📦 Output tensor type: ${_interpreter!.getOutputTensor(0).type}');

      return true;
    } catch (e) {
      print('❌ TFLite initialization failed: $e');
      return false;
    }
  }

  static List<List<double>> _transposeOutput(List<List<double>> matrix) {
  int rows = matrix.length;
  int cols = matrix[0].length;
  List<List<double>> transposed = List.generate(cols, (_) => List.filled(rows, 0.0));
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      transposed[j][i] = matrix[i][j];
    }
  }
  return transposed;
}


  // Run detection on image file
  static Future<List<Map<String, dynamic>>> detectObjects(File imageFile) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return [];
    }

    try {
      // Load and decode image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return [];

      // Preprocess image
      final input = _preprocessImage(image);

      // Prepare output buffer
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var outputType = _interpreter!.getOutputTensor(0).type;
      
      // Output shape is typically [1, 8400, 84] for YOLO11
      // 84 = 4 (bbox) + 80 (classes) for COCO, adjust for Objects365
      var output = List.filled(
        outputShape[0] * outputShape[1] * outputShape[2], 
        0.0
      ).reshape(outputShape);

      // Run inference
      // Run inference
_interpreter!.run(input, output);

// Transpose output if needed (e.g. [1, 369, 2100] → [2100, 369])
if (outputShape[1] == 369 && outputShape[2] == 2100) {
  print('🔁 Transposing output from [1, 369, 2100] → [2100, 369]');
  output[0] = _transposeOutput(output[0]);
}


      // Post-process results
      return _postProcess(output[0], image.width, image.height);
    } catch (e) {
      print('❌ TFLite detection error: $e');
      return [];
    }
  }

  // Preprocess image to model input
static List<List<List<List<double>>>> _preprocessImage(img.Image image) {
  // Resize to input size
  img.Image resized = img.copyResize(
    image,
    width: inputSize,
    height: inputSize,
    interpolation: img.Interpolation.linear,
  );

  // Normalize to [0, 1]
  var input = List.generate(
    1,
    (_) => List.generate(
      inputSize,
      (y) => List.generate(
        inputSize,
        (x) {
          final pixel = resized.getPixel(x, y);

          // For package:image >= 4.0.0, Pixel has .r, .g, .b properties
          final r = pixel.r.toDouble() / 255.0;
          final g = pixel.g.toDouble() / 255.0;
          final b = pixel.b.toDouble() / 255.0;

          return [r, g, b];
        },
      ),
    ),
  );

  return input;
}


  // Post-process YOLO output
  static List<Map<String, dynamic>> _postProcess(
    List<dynamic> output, 
    int imgWidth, 
    int imgHeight
  ) {
    List<Map<String, dynamic>> detections = [];

    // YOLO11 output format: [num_boxes, 84]
    // First 4 values: x_center, y_center, width, height
    // Rest: class scores
    for (int i = 0; i < output.length; i++) {
      var box = output[i];
      
      // Extract box coordinates (normalized)
      double xCenter = box[0];
      double yCenter = box[1];
      double width = box[2];
      double height = box[3];

      // Extract class scores
      List<double> scores = [];
      for (int j = 4; j < box.length; j++) {
        scores.add(box[j].toDouble());
      }

      // Find max score and class
      double maxScore = scores.reduce((a, b) => a > b ? a : b);
      int classId = scores.indexOf(maxScore);

      // Filter by confidence
      if (maxScore > confidenceThreshold && classId < (_labels?.length ?? 0)) {
        // Convert to pixel coordinates
        double x1 = (xCenter - width / 2) * imgWidth;
        double y1 = (yCenter - height / 2) * imgHeight;
        double x2 = (xCenter + width / 2) * imgWidth;
        double y2 = (yCenter + height / 2) * imgHeight;

        detections.add({
          'label': _labels![classId],
          'confidence': maxScore,
          'box': [x1.toInt(), y1.toInt(), x2.toInt(), y2.toInt()],
        });
      }
    }

    // Apply NMS
    return _applyNMS(detections);
  }

  // Non-Maximum Suppression
  static List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> detections) {
    if (detections.isEmpty) return [];

    // Sort by confidence
    detections.sort((a, b) => 
      (b['confidence'] as double).compareTo(a['confidence'] as double)
    );

    List<Map<String, dynamic>> result = [];

    while (detections.isNotEmpty) {
      var best = detections.removeAt(0);
      result.add(best);

      detections.removeWhere((detection) {
        double iou = _calculateIoU(
          best['box'] as List<int>, 
          detection['box'] as List<int>
        );
        return iou > iouThreshold;
      });
    }

    return result;
  }

  // Calculate IoU
  static double _calculateIoU(List<int> box1, List<int> box2) {
    int x1 = box1[0].clamp(box2[0], box2[2]);
    int y1 = box1[1].clamp(box2[1], box2[3]);
    int x2 = box1[2].clamp(box2[0], box2[2]);
    int y2 = box1[3].clamp(box2[1], box2[3]);

    int intersectionArea = ((x2 - x1).clamp(0, double.infinity) * 
                           (y2 - y1).clamp(0, double.infinity)).toInt();

    int box1Area = (box1[2] - box1[0]) * (box1[3] - box1[1]);
    int box2Area = (box2[2] - box2[0]) * (box2[3] - box2[1]);

    int unionArea = box1Area + box2Area - intersectionArea;

    return unionArea > 0 ? intersectionArea / unionArea : 0.0;
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isInitialized = false;
  }
}

// Extension for reshaping lists
extension Reshape on List<double> {
  List<List<List<double>>> reshape(List<int> shape) {
    if (shape.length != 3) throw ArgumentError('Expected 3D shape');
    
    var result = List.generate(
      shape[0],
      (i) => List.generate(
        shape[1],
        (j) => List.generate(
          shape[2],
          (k) => this[i * shape[1] * shape[2] + j * shape[2] + k],
        ),
      ),
    );
    return result;
  }
}
