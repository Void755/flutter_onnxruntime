// Copyright (c) MASIC AI
// All rights reserved.
//
// This source code is licensed under the license found in the
// LICENSE file in the root directory of this source tree.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:flutter_onnxruntime/src/flutter_onnxruntime_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterOnnxruntimePlatform with MockPlatformInterfaceMixin implements FlutterOnnxruntimePlatform {
  // Tracks method calls for verification
  String? lastSourceType;
  dynamic lastSourceData;
  List<int>? lastShape;
  String? lastValueIdForConversion;
  String? lastValueIdForRelease;
  String? lastValueIdForData;

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> createSession(String modelPath, {Map<String, dynamic>? sessionOptions}) {
    return Future.value({
      'sessionId': 'test_session_id',
      'inputNames': ['input1'],
      'outputNames': ['output1'],
    });
  }

  @override
  Future<Map<String, dynamic>> runInference(
    String sessionId,
    Map<String, dynamic> inputs, {
    Map<String, dynamic>? runOptions,
  }) {
    return Future.value({
      'outputs': {
        'output1': [1.0, 2.0, 3.0, 4.0],
        'output1_shape': [2, 2],
      },
    });
  }

  @override
  Future<Map<String, dynamic>> createOrtValue(String sourceType, dynamic data, List<int> shape) {
    // Track the call parameters
    lastSourceType = sourceType;
    lastSourceData = data;
    lastShape = shape;

    // Return a mock OrtValue map
    String dataType = sourceType;

    return Future.value({
      'valueId': 'test_value_id_${DateTime.now().millisecondsSinceEpoch}',
      'dataType': dataType,
      'shape': shape,
    });
  }

  @override
  Future<Map<String, dynamic>> convertOrtValue(String valueId, String targetType) {
    // Track the call
    lastValueIdForConversion = valueId;

    return Future.value({
      'valueId': 'converted_$valueId',
      'dataType': targetType,
      'shape': [2, 2],
    });
  }

  @override
  Future<Map<String, dynamic>> getOrtValueData(String valueId) {
    // Track the call
    lastValueIdForData = valueId;

    // Return data in a format that works for all types
    return Future.value({
      'data': [1.0, 2.0, 3.0, 4.0],
      'shape': [2, 2],
    });
  }

  @override
  Future<void> releaseOrtValue(String valueId) {
    lastValueIdForRelease = valueId;
    return Future.value();
  }

  @override
  Future<void> closeSession(String sessionId) => Future.value();

  @override
  Future<Map<String, dynamic>> getMetadata(String sessionId) {
    return Future.value({});
  }

  @override
  Future<List<Map<String, dynamic>>> getInputInfo(String sessionId) {
    return Future.value([]);
  }

  @override
  Future<List<Map<String, dynamic>>> getOutputInfo(String sessionId) {
    return Future.value([]);
  }

  @override
  Future<List<String>> getAvailableProviders() => Future.value(['CPU']);
}

class MockFlutterOnnxruntimePlatformWithShapedData extends MockFlutterOnnxruntimePlatform {
  @override
  Future<Map<String, dynamic>> getOrtValueData(String valueId) {
    // Track the call
    lastValueIdForData = valueId;

    // Return data in a format that represents a 2D array
    return Future.value({
      'data': [1.0, 2.0, 3.0, 4.0],
      'shape': [2, 2],
    });
  }
}

void main() {
  late MockFlutterOnnxruntimePlatform mockPlatform;
  final FlutterOnnxruntimePlatform initialPlatform = FlutterOnnxruntimePlatform.instance;

  setUp(() {
    mockPlatform = MockFlutterOnnxruntimePlatform();
    FlutterOnnxruntimePlatform.instance = mockPlatform;
  });

  tearDown(() {
    FlutterOnnxruntimePlatform.instance = initialPlatform;
  });

  group('OrtValue creation with fromList', () {
    test('fromList with Float32List should create OrtValue correctly', () async {
      final testData = Float32List.fromList([1.0, 2.0, 3.0, 4.0]);
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'float32');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.float32);
      expect(tensor.id, isNotEmpty);
    });

    test('fromList with Int32List should create OrtValue correctly', () async {
      final testData = Int32List.fromList([1, 2, 3, 4]);
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'int32');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.int32);
    });

    test('fromList with Int64List should create OrtValue correctly', () async {
      final testData = Int64List.fromList([1, 2, 3, 4]);
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'int64');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.int64);
    });

    test('fromList with Uint8List should create OrtValue correctly', () async {
      final testData = Uint8List.fromList([1, 2, 3, 4]);
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'uint8');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.uint8);
    });

    test('fromList with List<bool> should create OrtValue correctly', () async {
      final testData = [true, false, true, false];
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'bool');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.bool);
    });

    test('fromList with List<String> should create OrtValue correctly', () async {
      final testData = ['test1', 'test2', 'test3', 'test4'];
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'string');
      expect(mockPlatform.lastSourceData, testData);
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.string);
    });

    test('fromList with List<double> should convert to Float32List', () async {
      final testData = [1.0, 2.0, 3.0, 4.0];
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'float32');
      expect(mockPlatform.lastSourceData, isA<Float32List>());
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.float32);
    });

    test('fromList with List<int> within int32 range should convert to Int32List', () async {
      final testData = [1, 2, 3, 4];
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'int32');
      expect(mockPlatform.lastSourceData, isA<Int32List>());
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.int32);
    });

    test('fromList with List<int> exceeding int32 range should convert to Int64List', () async {
      final testData = [1, 2147483648, 3, 4]; // 2147483648 exceeds int32 range
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'int64');
      expect(mockPlatform.lastSourceData, isA<Int64List>());
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.int64);
    });

    test('fromList with List<num> with mixed integers and decimals should convert to Float32List', () async {
      final testData = [1, 2, 3.5, 4];
      final testShape = [2, 2];

      final tensor = await OrtValue.fromList(testData, testShape);

      // Verify correct parameter forwarding
      expect(mockPlatform.lastSourceType, 'float32');
      expect(mockPlatform.lastSourceData, isA<Float32List>());
      expect(mockPlatform.lastShape, testShape);

      // Verify OrtValue properties
      expect(tensor.shape, testShape);
      expect(tensor.dataType, OrtDataType.float32);
    });

    test('fromList with empty list should throw ArgumentError', () async {
      final testData = [];
      final testShape = [0];

      expect(() => OrtValue.fromList(testData, testShape), throwsArgumentError);
    });

    test('fromList with unsupported type should throw ArgumentError', () async {
      final testData = [DateTime.now(), DateTime.now()]; // Unsupported type
      final testShape = [2];

      expect(() => OrtValue.fromList(testData, testShape), throwsArgumentError);
    });
  });

  group('OrtValue conversion', () {
    test('to() should convert to a different data type', () async {
      // Create an OrtValue first
      final tensor = await OrtValue.fromList(Float32List.fromList([1.0, 2.0, 3.0, 4.0]), [2, 2]);

      // Convert to a different type
      final convertedTensor = await tensor.to(OrtDataType.int32);

      // Verify the conversion call
      expect(mockPlatform.lastValueIdForConversion, tensor.id);

      // Verify the new tensor
      expect(convertedTensor.id, isNot(tensor.id));
      expect(convertedTensor.dataType, OrtDataType.int32);
      expect(convertedTensor.shape, [2, 2]);
    });
  });

  group('OrtValue data extraction', () {
    test('asList() should return data in multi-dimensional format based on shape', () async {
      // Use the mock that returns shaped data
      final shapedMockPlatform = MockFlutterOnnxruntimePlatformWithShapedData();
      FlutterOnnxruntimePlatform.instance = shapedMockPlatform;

      // Create an OrtValue
      final tensor = await OrtValue.fromList(Float32List.fromList([1.0, 2.0, 3.0, 4.0]), [2, 2]);

      // Get data as a shaped list
      final data = await tensor.asList();

      // Verify the call
      expect(shapedMockPlatform.lastValueIdForData, tensor.id);

      // Verify the returned data is multi-dimensional according to shape
      expect(data, isA<List>());
      expect(data.length, 2); // 2 rows
      expect(data[0], isA<List>());
      expect(data[0].length, 2); // 2 columns
      expect(data[0][0], 1.0);
      expect(data[0][1], 2.0);
      expect(data[1][0], 3.0);
      expect(data[1][1], 4.0);

      // Restore the original mock
      FlutterOnnxruntimePlatform.instance = mockPlatform;
    });

    test('asFlattenedList() should return flattened data', () async {
      // Create an OrtValue
      final tensor = await OrtValue.fromList(Float32List.fromList([1.0, 2.0, 3.0, 4.0]), [2, 2]);

      // Get data as flattened list
      final data = await tensor.asFlattenedList();

      // Verify the call
      expect(mockPlatform.lastValueIdForData, tensor.id);

      // Verify the returned data is flat
      expect(data, isA<List>());
      expect(data.length, 4);
      expect(data[0], 1.0);
      expect(data[1], 2.0);
      expect(data[2], 3.0);
      expect(data[3], 4.0);
    });
  });

  group('OrtValue memory management', () {
    test('dispose() should release native resources', () async {
      // Create an OrtValue
      final tensor = await OrtValue.fromList(Float32List.fromList([1.0, 2.0, 3.0, 4.0]), [2, 2]);

      final valueId = tensor.id;

      // Dispose the tensor
      await tensor.dispose();

      // Verify release was called with the correct ID
      expect(mockPlatform.lastValueIdForRelease, valueId);
    });
  });

  group('OrtValue creation from map', () {
    test('fromMap should create OrtValue with correct properties', () {
      final map = {
        'valueId': 'test_id',
        'dataType': 'float32',
        'shape': [2, 2],
      };

      final tensor = OrtValue.fromMap(map);

      expect(tensor.id, 'test_id');
      expect(tensor.dataType, OrtDataType.float32);
      expect(tensor.shape, [2, 2]);
    });

    test('fromMap should handle missing or invalid properties', () {
      final map = {
        'valueId': 'test_id',
        // Missing dataType
        'shape': [], // Empty shape
      };

      expect(() => OrtValue.fromMap(map), throwsArgumentError);
    });

    test('fromMap with invalid dataType should throw ArgumentError', () {
      final map = {
        'valueId': 'test_id',
        'dataType': 'invalid_type',
        'shape': [2, 2],
      };

      expect(() => OrtValue.fromMap(map), throwsArgumentError);
    });
  });
}
