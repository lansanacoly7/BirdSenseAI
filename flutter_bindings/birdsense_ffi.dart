// BirdSense AI - Flutter Dart FFI Native Bindings (Ext 4.1 & Problem 3 Fix)
// Connects Flutter Mobile UI to C++ Native ONNX Inference Engine for zero-latency offline detection.

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Dart-facing Detection Model
class BirdDetection {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double confidence;
  final int classId;

  BirdDetection({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.confidence,
    required this.classId,
  });

  @override
  String toString() => 'BirdDetection(classId: $classId, confidence: ${(confidence * 100).toStringAsFixed(1)}%, box: [$x1, $y1, $x2, $y2])';
}

// FFI C Struct Definitions
base class CBirdDetectionItem extends ffi.Struct {
  @ffi.Float()
  external double x1;

  @ffi.Float()
  external double y1;

  @ffi.Float()
  external double x2;

  @ffi.Float()
  external double y2;

  @ffi.Float()
  external double confidence;

  @ffi.Int32()
  external int classId;
}

base class CBirdDetectionResult extends ffi.Struct {
  @ffi.Int32()
  external int count;

  external ffi.Pointer<CBirdDetectionItem> items;
}

// C Function Signatures
typedef NativeInitModel = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8> modelPath);
typedef DartInitModel = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8> modelPath);

typedef NativeDetectFrame = ffi.Uint8 Function(
  ffi.Pointer<ffi.Void> session,
  ffi.Pointer<ffi.Uint8> imageData,
  ffi.Int32 width,
  ffi.Int32 height,
  ffi.Int32 channels,
  ffi.Float confThreshold,
  ffi.Pointer<CBirdDetectionResult> outResult,
);

typedef DartDetectFrame = int Function(
  ffi.Pointer<ffi.Void> session,
  ffi.Pointer<ffi.Uint8> imageData,
  int width,
  int height,
  int channels,
  double confThreshold,
  ffi.Pointer<CBirdDetectionResult> outResult,
);

typedef NativeFreeResult = ffi.Void Function(ffi.Pointer<CBirdDetectionResult> result);
typedef DartFreeResult = void Function(ffi.Pointer<CBirdDetectionResult> result);

typedef NativeDestroyModel = ffi.Void Function(ffi.Pointer<ffi.Void> session);
typedef DartDestroyModel = void Function(ffi.Pointer<CBirdDetectionResult> session);

/// BirdSenseNativeFFI provides Dart bindings to execute C++ YOLO ONNX inference.
class BirdSenseNativeFFI {
  late ffi.DynamicLibrary _lib;
  late DartInitModel _initModel;
  late DartDetectFrame _detectFrame;
  late DartFreeResult _freeResult;
  late DartDestroyModel _destroyModel;

  ffi.Pointer<ffi.Void>? _session;

  BirdSenseNativeFFI({String? libraryPath}) {
    final path = libraryPath ?? _getDefaultLibraryPath();
    _lib = ffi.DynamicLibrary.open(path);

    _initModel = _lib.lookupFunction<NativeInitModel, DartInitModel>('birdsense_init_model');
    _detectFrame = _lib.lookupFunction<NativeDetectFrame, DartDetectFrame>('birdsense_detect_frame');
    _freeResult = _lib.lookupFunction<NativeFreeResult, DartFreeResult>('birdsense_free_result');
    _destroyModel = _lib.lookupFunction<NativeDestroyModel, DartDestroyModel>('birdsense_destroy_model');
  }

  static String _getDefaultLibraryPath() {
    if (Platform.isWindows) return 'birdsense_vision.dll';
    if (Platform.isLinux) return 'libbirdsense_vision.so';
    if (Platform.isAndroid) return 'libbirdsense_vision.so';
    if (Platform.isMacOS || Platform.isIOS) return 'birdsense_vision.framework/birdsense_vision';
    throw UnsupportedError('Unsupported platform for BirdSense Native FFI');
  }

  bool loadModel(String modelPath) {
    final nativePath = modelPath.toNativeUtf8();
    _session = _initModel(nativePath);
    calloc.free(nativePath);
    return _session != null && _session != ffi.nullptr;
  }

  /// Executes C++ native detection on a raw Uint8List image buffer.
  List<BirdDetection> detectFrame({
    required Uint8List imageBytes,
    required int width,
    required int height,
    int channels = 3,
    double confidenceThreshold = 0.25,
  }) {
    if (_session == null || _session == ffi.nullptr) {
      throw StateError('Model is not initialized. Call loadModel() first.');
    }

    // Allocate native memory for input image bytes
    final nativeImage = calloc<ffi.Uint8>(imageBytes.length);
    final pointerList = nativeImage.asTypedList(imageBytes.length);
    pointerList.setAll(0, imageBytes);

    // Allocate native memory for output result struct
    final outResult = calloc<CBirdDetectionResult>();

    try {
      final success = _detectFrame(
        _session!,
        nativeImage,
        width,
        height,
        channels,
        confidenceThreshold,
        outResult,
      );

      final List<BirdDetection> detections = [];
      if (success != 0 && outResult.ref.count > 0 && outResult.ref.items != ffi.nullptr) {
        for (var i = 0; i < outResult.ref.count; i++) {
          final item = outResult.ref.items[i];
          detections.add(BirdDetection(
            x1: item.x1,
            y1: item.y1,
            x2: item.x2,
            y2: item.y2,
            confidence: item.confidence,
            classId: item.classId,
          ));
        }
      }

      // Free C++ allocated result array
      _freeResult(outResult);
      return detections;
    } finally {
      calloc.free(nativeImage);
      calloc.free(outResult);
    }
  }

  void destroy() {
    if (_session != null && _session != ffi.nullptr) {
      _destroyModel(_session!);
      _session = null;
    }
  }
}
