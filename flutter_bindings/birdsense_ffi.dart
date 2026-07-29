// BirdSense AI - Flutter Dart FFI Native Bindings (Ext 4.1)
// Connects Flutter Mobile UI to C++ Native ONNX Inference Engine for zero-latency offline detection.

import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

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
typedef DartDestroyModel = void Function(ffi.Pointer<ffi.Void> session);

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

  void destroy() {
    if (_session != null && _session != ffi.nullptr) {
      _destroyModel(_session!);
      _session = null;
    }
  }
}
