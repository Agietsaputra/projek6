import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DeteksiController extends GetxController {
  late Interpreter interpreter;
  List<String> labels = [];

  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  final isCameraInitialized = false.obs;
  final predictedLabel = 'unknown'.obs;

  final PoseDetector poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  bool isDetecting = false;

  @override
  void onInit() {
    super.onInit();
    loadModel();
  }

  @override
  void onClose() {
    stopCamera();
    interpreter.close();
    poseDetector.close();
    super.onClose();
  }

  /// Load CNN model dan label dari asset
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/models/pose_cnn_model.tflite');

      final labelData = await rootBundle.loadString('assets/labels/label.txt');
      labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      debugPrint('✅ CNN Model dan label berhasil dimuat (${labels.length})');
    } catch (e) {
      debugPrint('❌ Gagal memuat model CNN: $e');
    }
  }

  Future<void> startCamera() async {
    try {
      cameras = await availableCameras();
      await initializeCamera(selectedCameraIndex);
    } catch (e) {
      debugPrint('❌ Tidak dapat mengakses kamera: $e');
    }
  }

  Future<void> stopCamera() async {
    try {
      await cameraController?.stopImageStream();
      await cameraController?.dispose();
    } catch (_) {}
    cameraController = null;
    isCameraInitialized.value = false;
    predictedLabel.value = 'unknown';
  }

  Future<void> switchCamera() async {
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    await stopCamera();
    await initializeCamera(selectedCameraIndex);
  }

  Future<void> initializeCamera(int index) async {
    try {
      final camera = cameras[index];
      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await cameraController!.initialize();
      await cameraController!.startImageStream(processCameraImage);
      isCameraInitialized.value = true;
    } catch (e) {
      debugPrint('❌ Error inisialisasi kamera: $e');
    }
  }

  /// Proses frame kamera untuk deteksi pose dan prediksi CNN
  void processCameraImage(CameraImage image) async {
    if (isDetecting) return;
    isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final rotation = InputImageRotationValue.fromRawValue(
            cameraController!.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) {
        debugPrint("❌ Format tidak didukung: ${image.format.raw}");
        return;
      }

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        final List<double> keypoints = [];

        for (var type in PoseLandmarkType.values) {
          final landmark = poses.first.landmarks[type];
          keypoints.addAll(landmark != null ? [landmark.x, landmark.y] : [0.0, 0.0]);
        }

        // Untuk CNN input shape (11, 6, 1) → reshape ke [1, 11, 6, 1]
        if (keypoints.length == 66) {
          final reshaped = List.generate(11, (i) {
            return List.generate(6, (j) {
              final idx = i * 6 + j;
              return idx < keypoints.length ? keypoints[idx] : 0.0;
            });
          });

          final input = [reshaped.map((row) => row.map((e) => [e]).toList()).toList()]; // [1,11,6,1]

          final outputTensor = interpreter.getOutputTensor(0);
          final output = List.generate(
            1,
            (_) => List.filled(outputTensor.shape[1], 0.0),
          );

          interpreter.run(input, output);

          final predictions = output[0];
          final maxIndex =
              predictions.indexWhere((e) => e == predictions.reduce(max));

          if (maxIndex >= 0 && maxIndex < labels.length) {
            predictedLabel.value = labels[maxIndex];
            debugPrint("✅ Prediksi CNN: ${predictedLabel.value}");
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Pose detection error: $e");
    } finally {
      isDetecting = false;
    }
  }
}
