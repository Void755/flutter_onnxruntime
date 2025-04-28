// Copyright (c) MASIC AI
// All rights reserved.
//
// This source code is licensed under the license found in the
// LICENSE file in the root directory of this source tree.

#ifndef FLUTTER_ONNXRUNTIME_TENSOR_MANAGER_H_
#define FLUTTER_ONNXRUNTIME_TENSOR_MANAGER_H_

#include "pch.h"

namespace flutter_onnxruntime {

// Manages OrtValue objects (tensors) with safe memory management
class TensorManager {
public:
  TensorManager();
  ~TensorManager();

  // Disallow copy and assign
  TensorManager(const TensorManager &) = delete;
  TensorManager &operator=(const TensorManager &) = delete;

  // Create a tensor from Float32List data
  std::string createFloat32Tensor(const std::vector<float> &data, const std::vector<int64_t> &shape);

  // Create a tensor from Int32List data
  std::string createInt32Tensor(const std::vector<int32_t> &data, const std::vector<int64_t> &shape);

  // Create a tensor from Int64List data
  std::string createInt64Tensor(const std::vector<int64_t> &data, const std::vector<int64_t> &shape);

  // Create a tensor from Uint8List data
  std::string createUint8Tensor(const std::vector<uint8_t> &data, const std::vector<int64_t> &shape);

  // Create a tensor from Boolean data
  std::string createBoolTensor(const std::vector<bool> &data, const std::vector<int64_t> &shape);

  // Convert between tensor formats
  std::string convertTensor(const std::string &tensor_id, const std::string &target_type);

  // Convert float32 tensor to another type
  std::string convertFloat32To(const std::string &tensor_id, const std::string &target_type);

  // Convert int32 tensor to another type
  std::string convertInt32To(const std::string &tensor_id, const std::string &target_type);

  // Convert int64 tensor to another type
  std::string convertInt64To(const std::string &tensor_id, const std::string &target_type);

  // Convert uint8 tensor to another type
  std::string convertUint8To(const std::string &tensor_id, const std::string &target_type);

  // Convert bool tensor to another type
  std::string convertBoolTo(const std::string &tensor_id, const std::string &target_type);

  // Store a tensor with a specific ID (used for output tensors)
  void storeTensor(const std::string &tensor_id, Ort::Value &&tensor);

  // Get data from a tensor
  flutter::EncodableValue getTensorData(const std::string &tensor_id);

  // Release a tensor
  bool releaseTensor(const std::string &tensor_id);

  // Get the OrtValue for a tensor ID
  Ort::Value *getTensor(const std::string &tensor_id);

  // Get the type of a tensor
  std::string getTensorType(const std::string &tensor_id);

  // Get the shape of a tensor
  std::vector<int64_t> getTensorShape(const std::string &tensor_id);

  // Generate a unique tensor ID
  std::string generateTensorId();

  // Get the element type string
  const char *get_element_type_string(ONNXTensorElementDataType element_type);

  // Clone a tensor
  std::unique_ptr<Ort::Value> cloneTensor(const std::string &tensor_id);

private:
  // Map of tensor IDs to OrtValue objects
  std::unordered_map<std::string, std::unique_ptr<Ort::Value>> tensors_;

  // Map of tensor IDs to their data types
  std::unordered_map<std::string, std::string> tensor_types_;

  // Map of tensor IDs to their shapes
  std::unordered_map<std::string, std::vector<int64_t>> tensor_shapes_;

  // Memory for tensor data that needs to persist
  std::unordered_map<std::string, std::vector<uint8_t>> tensor_data_buffers_;

  // Mutex for thread safety
  std::mutex tensor_mutex_;

  // Memory info for CPU memory
  Ort::MemoryInfo memory_info_{nullptr};

  // Create an OrtValue helper
  std::unique_ptr<Ort::Value> createOrtValue(const void *data, const std::vector<int64_t> &shape,
                                             ONNXTensorElementDataType element_type);
};

} // namespace flutter_onnxruntime

#endif // FLUTTER_ONNXRUNTIME_TENSOR_MANAGER_H_