import 'dart:typed_data';
import 'package:apa/app/modules/gerakan/controllers/gerakan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DeteksiController extends GetxController {
  final Map<String, Interpreter> interpreters = {};
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  var isCameraInitialized = false.obs;
  var predictedLabel = 'unknown'.obs;
  bool isDetecting = false;
  var activeModelFile = ''.obs;

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

  String getModelFileByExercise(String exerciseName) {
    final lower = exerciseName.toLowerCase().replaceAll(' ', '_');
    return modelMap.keys.firstWhere(
      (file) => file.toLowerCase().contains(lower),
      orElse: () => '',
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadAllModels().then((_) async {
      final exerciseName = Get.arguments as String? ?? '';
      final modelFile = getModelFileByExercise(exerciseName);
      debugPrint('📁 Argument exercise: $exerciseName');
      debugPrint('📁 Model file selected: $modelFile');
      if (modelFile.isNotEmpty) {
        activeModelFile.value = modelFile;
        await startCamera();
      } else {
        debugPrint('⚠️ Model tidak ditemukan untuk: $exerciseName');
      }
    });
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
        final interpreter =
            await Interpreter.fromAsset('assets/models/$modelFile');
        interpreters[modelFile] = interpreter;
        debugPrint('✅ Loaded model: $modelFile');
      } catch (e) {
        debugPrint('❌ Failed to load $modelFile: $e');
      }
    }
  }

  Future<void> startCamera() async {
    if (activeModelFile.value == '') return;
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
    if (cameras.isEmpty) cameras = await availableCameras();
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
        imageFormatGroup: ImageFormatGroup.yuv420, // fallback
      );
      await cameraController!.initialize();
      await cameraController!.startImageStream(processCameraImage);
      isCameraInitialized.value = true;
      debugPrint('📷 Camera initialized and streaming...');
    } catch (e) {
      debugPrint('❌ Camera error: $e');
    }
  }

  void processCameraImage(CameraImage image) async {
    if (isDetecting || cameraController == null || interpreters.isEmpty) return;
    isDetecting = true;

    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      final rotation = InputImageRotationValue.fromRawValue(
            cameraController!.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      if (format == null) {
        debugPrint('❌ Unsupported image format');
        isDetecting = false;
        return;
      }

      final allBytes = image.planes.expand((plane) => plane.bytes).toList();
      final inputImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(allBytes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);
      debugPrint('🧍‍♀️ Detected poses: ${poses.length}');

      if (poses.isNotEmpty) {
        final keypoints = <double>[];
        for (var type in PoseLandmarkType.values) {
          final landmark = poses.first.landmarks[type];
          keypoints.addAll(landmark != null
              ? [landmark.x, landmark.y, landmark.z]
              : [0.0, 0.0, 0.0]);
        }

        debugPrint('📌 Keypoints: ${keypoints.length}');
        if (keypoints.length == 99) {
          final interpreter = interpreters[activeModelFile.value];
          if (interpreter == null) {
            debugPrint('❌ Interpreter not found for ${activeModelFile.value}');
            isDetecting = false;
            return;
          }

          final inputShape = interpreter.getInputTensor(0).shape;
          debugPrint('🔢 Input shape: $inputShape');
          final input = [keypoints];
          final output = List.generate(1, (_) => List.filled(1, 0.0));
          interpreter.run(input, output);

          final confidence = output[0][0];
          final gerakanController = Get.find<GerakanController>();

          if (confidence > 0.8) {
            final predicted = modelMap[activeModelFile.value]!;
            predictedLabel.value = predicted;
            debugPrint('🎯 Predicted: $predicted (Confidence: $confidence)');

            final exercise = gerakanController.exercises
                .firstWhereOrNull((e) => e.name == predicted);
            if (exercise != null && !exercise.isCompleted) {
              gerakanController.startCounting(predicted);
            }
          } else {
            debugPrint('❓ Confidence too low: $confidence');
            predictedLabel.value = 'unknown';
            Get.find<GerakanController>().stopCounting();
          }
        } else {
          debugPrint('⚠️ Keypoint count mismatch: ${keypoints.length}');
        }
      }
    } catch (e) {
      debugPrint('❌ Detection error: $e');
    } finally {
      isDetecting = false;
    }
  }
}
