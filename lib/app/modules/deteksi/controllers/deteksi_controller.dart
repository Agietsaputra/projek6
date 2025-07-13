import 'dart:typed_data';
import 'dart:async';
import 'package:apa/app/modules/gerakan/controllers/gerakan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';


class DeteksiController extends GetxController {
  final gerakanController = Get.find<GerakanController>(); // ⬅️ Terhubung otomatis

  Map<String, Interpreter> interpreters = {};
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  var isCameraInitialized = false.obs;
  var predictedLabel = 'unknown'.obs;
  var activeModelFile = ''.obs;
  bool isDetecting = false;

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

  final holdDuration = 5;
  int holdingSeconds = 0;
  Timer? holdingTimer;

  @override
  void onInit() {
    super.onInit();
    final exerciseName = Get.arguments as String? ?? '';

    for (final entry in modelMap.entries) {
      final modelNameNormalized = entry.value.toLowerCase().replaceAll(' ', '');
      final inputName = exerciseName.toLowerCase().replaceAll(' ', '');
      if (modelNameNormalized == inputName) {
        activeModelFile.value = entry.key;
        loadSingleModel(entry.key).then((_) {
          if (interpreters[entry.key] != null) {
            startCamera();
          } else {
            debugPrint("❌ Interpreter null setelah load model");
          }
        });
        break;
      }
    }

    if (activeModelFile.value.isEmpty) {
      debugPrint("❌ Tidak ditemukan model untuk '$exerciseName'");
    }
  }

  @override
  void onClose() {
    stopCamera();
    for (var interpreter in interpreters.values) {
      interpreter.close();
    }
    poseDetector.close();
    holdingTimer?.cancel();
    super.onClose();
  }

  Future<void> loadSingleModel(String modelFile) async {
    try {
      final interpreter = await Interpreter.fromAsset('assets/models/$modelFile');
      interpreters[modelFile] = interpreter;
      debugPrint('✅ Loaded model: $modelFile');
    } catch (e) {
      debugPrint('❌ Failed to load model $modelFile: $e');
    }
  }

  Future<void> startCamera() async {
    if (activeModelFile.value.isEmpty) return;
    cameras = await availableCameras();
    await initializeCamera(selectedCameraIndex);
  }

  Future<void> stopCamera() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    cameraController = null;
    isCameraInitialized.value = false;
    predictedLabel.value = 'unknown';
    cancelHoldTimer();
  }

  Future<void> switchCamera() async {
    if (cameras.isEmpty) cameras = await availableCameras();
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
      debugPrint('❌ Camera init error: $e');
    }
  }

  List<List<List<List<double>>>> reshape1DTo4D(List<double> flat, int d1, int d2, int d3, int d4) {
    if (flat.length != d1 * d2 * d3 * d4) {
      throw ArgumentError("❌ Ukuran tidak cocok: ${flat.length} != ${d1 * d2 * d3 * d4}");
    }
    var index = 0;
    return List.generate(d1, (_) =>
        List.generate(d2, (_) =>
            List.generate(d3, (_) =>
                List.generate(d4, (_) => flat[index++])
            )
        )
    );
  }

  void processCameraImage(CameraImage image) async {
    if (isDetecting || activeModelFile.value.isEmpty || cameraController == null) return;
    isDetecting = true;

    try {
      final bytes = image.planes.expand((plane) => plane.bytes).toList();

      final inputImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(bytes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotationValue.fromRawValue(
              cameraController!.description.sensorOrientation) ?? InputImageRotation.rotation0deg,
          format: InputImageFormatValue.fromRawValue(image.format.raw)!,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final keypoints = <double>[];
        for (var type in PoseLandmarkType.values) {
          final landmark = poses.first.landmarks[type];
          keypoints.addAll(landmark != null ? [landmark.x, landmark.y] : [0.0, 0.0]);
        }

        if (keypoints.length == 66) {
          final interpreter = interpreters[activeModelFile.value];
          if (interpreter == null) return;

          final input = reshape1DTo4D(keypoints, 1, 11, 6, 1);
          final output = List.generate(1, (_) => List.filled(1, 0.0));

          interpreter.run(input, output);
          final confidence = output[0][0];
          final label = modelMap[activeModelFile.value]!;

          if (confidence > 0.8) {
            predictedLabel.value = '$label (${holdingSeconds}s)';
            startHoldTimer(label);

            // ✅ Update otomatis gerakan di controller
            gerakanController.updateFromPrediction(label);
          } else {
            predictedLabel.value = 'unknown';
            cancelHoldTimer();
          }
        } else {
          debugPrint("⚠️ Jumlah keypoint tidak sesuai: ${keypoints.length}");
        }
      }
    } catch (e) {
      debugPrint("❌ Detection error: $e");
    } finally {
      isDetecting = false;
    }
  }

  void startHoldTimer(String label) {
    holdingTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      holdingSeconds++;
      predictedLabel.value = '$label (${holdingSeconds}s)';

      if (holdingSeconds >= holdDuration) {
        predictedLabel.value = label;
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: true);
        });
      }
    });
  }

  void cancelHoldTimer() {
    holdingTimer?.cancel();
    holdingTimer = null;
    holdingSeconds = 0;
  }
}
