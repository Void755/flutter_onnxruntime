#ifndef TENSOR_MANAGER_H
#define TENSOR_MANAGER_H

#include <flutter_linux/flutter_linux.h>
#include <map>
#include <memory>
#include <mutex>
#include <onnxruntime_cxx_api.h>
#include <string>
#include <vector>

// Class to manage tensor data
class TensorManager {
public:
  TensorManager();
  ~TensorManager();

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

  // Store a tensor with a specific ID (used for output tensors)
  void storeTensor(const std::string &tensor_id, Ort::Value &&tensor);

  // Get data from a tensor
  FlValue *getTensorData(const std::string &tensor_id);

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

private:
  // Map of tensor IDs to OrtValue objects
  std::map<std::string, std::unique_ptr<Ort::Value>> tensors_;

  // Map of tensor IDs to their data types
  std::map<std::string, std::string> tensor_types_;

  // Map of tensor IDs to their shapes
  std::map<std::string, std::vector<int64_t>> tensor_shapes_;

  // Counter for generating unique tensor IDs
  int next_tensor_id_;

  // Mutex for thread safety
  std::mutex mutex_;

  // Memory info for CPU memory
  Ort::MemoryInfo memory_info_{nullptr};
};

#endif // TENSOR_MANAGER_H