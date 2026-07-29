/**
 * BirdSense AI - C Native API Header for ONNX Inference Engine (Ext 4.1)
 * Enables Flutter integration via dart:ffi on Android, iOS, Windows, and Linux.
 */

#ifndef BIRDSENSE_ONNX_H
#define BIRDSENSE_ONNX_H

#include <stdint.h>
#include <stdbool.h>

#ifdef _WIN32
#define BIRDSENSE_EXPORT __declspec(dllexport)
#else
#define BIRDSENSE_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    float x1;
    float y1;
    float x2;
    float y2;
    float confidence;
    int class_id;
} BirdDetectionItem;

typedef struct {
    int count;
    BirdDetectionItem* items;
} BirdDetectionResult;

/**
 * Initializes the ONNX model session.
 * @param model_path Path to the .onnx model file.
 * @return Handle pointer to session or NULL if failed.
 */
BIRDSENSE_EXPORT void* birdsense_init_model(const char* model_path);

/**
 * Executes inference on an uncompressed RGB/BGR image frame buffer.
 * @param session Handle returned by birdsense_init_model.
 * @param image_data Pointer to image byte array.
 * @param width Image width in pixels.
 * @param height Image height in pixels.
 * @param channels Number of color channels (3 for RGB/BGR).
 * @param conf_threshold Minimum detection confidence threshold.
 * @param out_result Pointer to receive output detection results.
 * @return True if inference succeeded, false otherwise.
 */
BIRDSENSE_EXPORT bool birdsense_detect_frame(
    void* session,
    const uint8_t* image_data,
    int width,
    int height,
    int channels,
    float conf_threshold,
    BirdDetectionResult* out_result
);

/**
 * Frees memory allocated for detection results.
 */
BIRDSENSE_EXPORT void birdsense_free_result(BirdDetectionResult* result);

/**
 * Destroys the model session and releases C++ resources.
 */
BIRDSENSE_EXPORT void birdsense_destroy_model(void* session);

#ifdef __cplusplus
}
#endif

#endif // BIRDSENSE_ONNX_H
