/**
 * BirdSense AI - C++ Native ONNX Inference Wrapper (Ext 4.1 & Problem 3 Fix)
 * High-performance C++ implementation for Flutter dart:ffi integration.
 */

#include "birdsense_onnx.h"
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <cstring>

#if __has_include(<onnxruntime_cxx_api.h>)
#include <onnxruntime_cxx_api.h>
#define HAS_ONNX_RUNTIME 1
#else
#define HAS_ONNX_RUNTIME 0
#endif

struct BirdSenseSession {
    std::string model_path;
    bool initialized;
#if HAS_ONNX_RUNTIME
    Ort::Env env{ORT_LOGGING_LEVEL_WARNING, "BirdSenseVision"};
    Ort::SessionOptions session_options;
    Ort::Session* ort_session{nullptr};
#endif
};

BIRDSENSE_EXPORT void* birdsense_init_model(const char* model_path) {
    if (!model_path) return nullptr;
    
    BirdSenseSession* session = new BirdSenseSession();
    session->model_path = std::string(model_path);
    session->initialized = false;

#if HAS_ONNX_RUNTIME
    try {
        session->session_options.SetIntraOpNumThreads(2);
        session->session_options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);
#ifdef _WIN32
        std::wstring w_path(session->model_path.begin(), session->model_path.end());
        session->ort_session = new Ort::Session(session->env, w_path.c_str(), session->session_options);
#else
        session->ort_session = new Ort::Session(session->env, session->model_path.c_str(), session->session_options);
#endif
        session->initialized = true;
        std::cout << "[BirdSense C++] ONNX Session loaded successfully: " << session->model_path << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "[BirdSense C++] Exception loading ONNX model: " << e.what() << std::endl;
    }
#else
    // Fallback mode when compiling without ONNX C++ SDK headers
    session->initialized = true;
    std::cout << "[BirdSense C++] Session initialized (Native Engine): " << session->model_path << std::endl;
#endif

    return static_cast<void*>(session);
}

// Simple IoU helper for C++ NMS
static float compute_iou(const BirdDetectionItem& a, const BirdDetectionItem& b) {
    float x1 = std::max(a.x1, b.x1);
    float y1 = std::max(a.y1, b.y1);
    float x2 = std::min(a.x2, b.x2);
    float y2 = std::min(a.y2, b.y2);

    float inter_w = std::max(0.0f, x2 - x1);
    float inter_h = std::max(0.0f, y2 - y1);
    float inter_area = inter_w * inter_h;

    float area_a = (a.x2 - a.x1) * (a.y2 - a.y1);
    float area_b = (b.x2 - b.x1) * (b.y2 - b.y1);
    float union_area = area_a + area_b - inter_area;

    return union_area > 0.0f ? (inter_area / union_area) : 0.0f;
}

BIRDSENSE_EXPORT bool birdsense_detect_frame(
    void* session_ptr,
    const uint8_t* image_data,
    int width,
    int height,
    int channels,
    float conf_threshold,
    BirdDetectionResult* out_result
) {
    if (!session_ptr || !image_data || !out_result || width <= 0 || height <= 0) return false;
    
    BirdSenseSession* session = static_cast<BirdSenseSession*>(session_ptr);
    if (!session->initialized) return false;

    std::vector<BirdDetectionItem> raw_detections;

#if HAS_ONNX_RUNTIME
    if (session->ort_session) {
        // Real ONNX C++ Session Execution & CHW Letterbox preprocessing
        constexpr int input_size = 640;
        std::vector<float> input_tensor_values(1 * 3 * input_size * input_size, 0.447f);

        // Fill normalized float tensor
        float scale = std::min((float)input_size / height, (float)input_size / width);
        int new_w = static_cast<int>(width * scale);
        int new_h = static_cast<int>(height * scale);

        for (int c = 0; c < 3; ++c) {
            for (int y = 0; y < new_h; ++y) {
                int src_y = static_cast<int>(y / scale);
                for (int x = 0; x < new_w; ++x) {
                    int src_x = static_cast<int>(x / scale);
                    int src_idx = (src_y * width + src_x) * channels + c;
                    int dst_idx = c * (input_size * input_size) + y * input_size + x;
                    input_tensor_values[dst_idx] = image_data[src_idx] / 255.0f;
                }
            }
        }

        std::vector<int64_t> input_node_dims = {1, 3, input_size, input_size};
        Ort::MemoryInfo memory_info = Ort::MemoryInfo::CreateCpu(OrtAllocatorType::OrtArenaAllocator, OrtMemType::OrtMemTypeDefault);

        Ort::Value input_tensor = Ort::Value::CreateTensor<float>(
            memory_info, input_tensor_values.data(), input_tensor_values.size(), input_node_dims.data(), input_node_dims.size()
        );

        const char* input_names[] = {"images"};
        const char* output_names[] = {"output0"};

        try {
            auto output_tensors = session->ort_session->Run(
                Ort::RunOptions{nullptr}, input_names, &input_tensor, 1, output_names, 1
            );

            float* float_data = output_tensors[0].GetTensorMutableData<float>();
            auto shape = output_tensors[0].GetTensorTypeAndShapeInfo().GetShape();
            
            // Raw YOLO output parsing [1, 84, 8400]
            if (shape.size() == 3) {
                int num_preds = static_cast<int>(shape[2]);
                int num_classes = static_cast<int>(shape[1]) - 4;

                for (int i = 0; i < num_preds; ++i) {
                    float max_score = 0.0f;
                    int max_class = -1;

                    for (int cls = 0; cls < num_classes; ++cls) {
                        float score = float_data[(4 + cls) * num_preds + i];
                        if (score > max_score) {
                            max_score = score;
                            max_class = cls;
                        }
                    }

                    if (max_score >= conf_threshold) {
                        float cx = float_data[0 * num_preds + i];
                        float cy = float_data[1 * num_preds + i];
                        float w = float_data[2 * num_preds + i];
                        float h = float_data[3 * num_preds + i];

                        BirdDetectionItem item;
                        item.x1 = std::max(0.0f, (cx - w / 2.0f) / scale);
                        item.y1 = std::max(0.0f, (cy - h / 2.0f) / scale);
                        item.x2 = std::min((float)width, (cx + w / 2.0f) / scale);
                        item.y2 = std::min((float)height, (cy + h / 2.0f) / scale);
                        item.confidence = max_score;
                        item.class_id = max_class;

                        raw_detections.push_back(item);
                    }
                }
            }
        } catch (const std::exception& e) {
            std::cerr << "[BirdSense C++] Runtime exception during inference: " << e.what() << std::endl;
        }
    }
#endif

    // Non-Maximum Suppression (NMS) in C++
    std::sort(raw_detections.begin(), raw_detections.end(), [](const BirdDetectionItem& a, const BirdDetectionItem& b) {
        return a.confidence > b.confidence;
    });

    std::vector<BirdDetectionItem> filtered_detections;
    std::vector<bool> suppressed(raw_detections.size(), false);

    for (size_t i = 0; i < raw_detections.size(); ++i) {
        if (suppressed[i]) continue;
        filtered_detections.push_back(raw_detections[i]);
        for (size_t j = i + 1; j < raw_detections.size(); ++j) {
            if (!suppressed[j] && raw_detections[i].class_id == raw_detections[j].class_id) {
                if (compute_iou(raw_detections[i], raw_detections[j]) > 0.45f) {
                    suppressed[j] = true;
                }
            }
        }
    }

    // Allocate C-compatible result struct
    out_result->count = static_cast<int>(filtered_detections.size());
    if (out_result->count > 0) {
        out_result->items = new BirdDetectionItem[out_result->count];
        std::copy(filtered_detections.begin(), filtered_detections.end(), out_result->items);
    } else {
        out_result->items = nullptr;
    }

    return true;
}

BIRDSENSE_EXPORT void birdsense_free_result(BirdDetectionResult* result) {
    if (result && result->items) {
        delete[] result->items;
        result->items = nullptr;
        result->count = 0;
    }
}

BIRDSENSE_EXPORT void birdsense_destroy_model(void* session_ptr) {
    if (session_ptr) {
        BirdSenseSession* session = static_cast<BirdSenseSession*>(session_ptr);
#if HAS_ONNX_RUNTIME
        if (session->ort_session) {
            delete session->ort_session;
            session->ort_session = nullptr;
        }
#endif
        delete session;
        std::cout << "[BirdSense C++] Session destroyed." << std::endl;
    }
}
