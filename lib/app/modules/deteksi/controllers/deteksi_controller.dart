import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DeteksiController extends GetxController {
  Map<String, Interpreter> interpreters = {};
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  var isCameraInitialized = false.obs;
  var predictedLabel = 'unknown'.obs;
  bool isDetecting = false;

  var activeModelFile = ''.obs; // awalnya kosong, harus dipilih dulu

  final poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  final modelMap = {
    'Walking_Lunge_model.tflite': 'Walking Lunge',
    'Standing_Hip_Circle_model.tflite': 'Standing Hip Circle',
    'Frankenstein_walk_model.tflite': 'Frankenstein Walk',
    'Calf_Raises_model.tflite': 'Calf Raises',
    'Butt_kick_model.tflite': 'Butt Kick',
  };

  @override
  void onInit() {
    super.onInit();
    loadAllModels();
    // jangan startCamera() otomatis
  }

  @override
  void onClose() {
    stopCamera();
    for (var interpreter in interpreters.values) {
      interpreter.close();
    }
    poseDetector.close();
    super.onClose();
  }

  Future<void> loadAllModels() async {
    for (var modelFile in modelMap.keys) {
      try {
        // Gunakan path 'assets/models/...' sesuai dengan pubspec.yaml
        final interpreter =
            await Interpreter.fromAsset('assets/models/$modelFile');
        interpreters[modelFile] = interpreter;
        debugPrint('✅ Loaded model: $modelFile');
      } catch (e) {
        debugPrint('❌ Failed to load model $modelFile: $e');
      }
    }
  }

  Future<void> startCamera() async {
    if (activeModelFile.value == '') {
      debugPrint('Pilih model dulu sebelum mulai kamera');
      return;
    }
    cameras = await availableCameras();
    await initializeCamera(selectedCameraIndex);
  }

  Future<void> stopCamera() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
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

  Future<void> initializeCamera(int cameraIndex) async {
    try {
      final selectedCamera = cameras[cameraIndex];
      cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await cameraController!.initialize();
      await cameraController!.startImageStream(processCameraImage);
      isCameraInitialized.value = true;
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void processCameraImage(CameraImage image) async {
    if (isDetecting || interpreters.isEmpty) return;
    isDetecting = true;

    try {
      List<int> allBytes = [];
      for (final plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final rotation = InputImageRotationValue.fromRawValue(
            cameraController!.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) {
        debugPrint("Unsupported format: ${image.format.raw}");
        isDetecting = false;
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
        for (var lmType in PoseLandmarkType.values) {
          final lm = poses.first.landmarks[lmType];
          keypoints.addAll(lm != null ? [lm.x, lm.y, lm.z] : [0.0, 0.0, 0.0]);
        }

        if (keypoints.length == 99) {
          final interpreter = interpreters[activeModelFile.value];
          if (interpreter == null) {
            predictedLabel.value = 'unknown';
            isDetecting = false;
            return;
          }

          final inputShape = interpreter.getInputTensor(0).shape;
          debugPrint('Input tensor shape: $inputShape');

          dynamic input;

          if (inputShape.length == 4) {
            // Model CNN butuh input 4D: [batch, height, width, channel]
            // Contoh dummy array dengan semua nol, kamu harus ganti dengan preprocessing gambar sebenarnya
            input = List.generate(
              inputShape[1],
              (_) => List.generate(
                inputShape[2],
                (_) => List.filled(inputShape[3], 0.0),
              ),
            );
            input = [input]; // batch size 1
            debugPrint('Using dummy 4D input for CNN model');
          } else if (inputShape.length == 2) {
            // Model Dense/Fully Connected, input 2D: [batch, features]
            input = [keypoints]; // langsung pakai keypoints pose
            debugPrint('Using 2D input vector for Dense model');
          } else {
            debugPrint(
                'Unsupported input tensor shape length: ${inputShape.length}');
            predictedLabel.value = 'unknown';
            isDetecting = false;
            return;
          }

          final output = List.generate(
              1, (_) => List.filled(1, 0.0)); // output shape [1,1]

          interpreter.run(input, output);

          final confidence = output[0][0];
          if (confidence > 0.8) {
            predictedLabel.value = modelMap[activeModelFile.value]!;
            debugPrint(
                "Detected: ${predictedLabel.value} (${(confidence * 100).toStringAsFixed(1)}%)");
          } else {
            predictedLabel.value = 'unknown';
            debugPrint(
                "Low confidence: ${(confidence * 100).toStringAsFixed(1)}%");
          }
        }
      }
    } catch (e) {
      debugPrint("Detection error: $e");
    } finally {
      isDetecting = false;
    }
  }
}
