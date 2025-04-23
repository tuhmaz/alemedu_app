import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://alemedu.com/api';
  final storage = const FlutterSecureStorage();
  static const String _apiKeyStorageKey = 'api_key';
  static const String _validApiKey = 'gfOTaGfOcVZigVyN3Go5ZHwr606mmzlPs6gfet0Nsd6d5wBykGGsI9rf1zZ0UYsZ';

  // تهيئة ApiService والتحقق من وجود API Key
  Future<void> initialize() async {
    final storedApiKey = await storage.read(key: _apiKeyStorageKey);
    if (storedApiKey == null) {
      // تخزين API Key بشكل آمن عند أول استخدام
      await storage.write(key: _apiKeyStorageKey, value: _validApiKey);
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // التحقق من صلاحية API Key
  Future<bool> validateApiKey(String apiKey) async {
    return apiKey == _validApiKey;
  }

  Future<String> getApiKey() async {
    final apiKey = await storage.read(key: _apiKeyStorageKey);
    if (apiKey == null) {
      throw UnauthorizedException('API Key غير موجود');
    }
    
    final isValid = await validateApiKey(apiKey);
    if (!isValid) {
      throw UnauthorizedException('API Key غير صالح');
    }
    
    return apiKey;
  }

  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    try {
      final token = await getToken();
      final apiKey = await getApiKey();  // سيقوم بالتحقق من الصلاحية تلقائياً
      
      final headers = {
        if (!isMultipart) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'X-API-KEY': apiKey,
      };
      return headers;
    } catch (e) {
      if (e is UnauthorizedException) {
        // يمكنك هنا تنفيذ إجراءات إضافية مثل تسجيل الخروج
        rethrow;
      }
      throw ApiException(
        message: 'خطأ في التحقق من الصلاحية',
        statusCode: 401,
      );
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      if (response.statusCode == 401) {
        throw UnauthorizedException('انتهت صلاحية الجلسة');
      }
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'حدث خطأ في العملية',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'حدث خطأ في الاتصال بالخادم',
        statusCode: 500,
      );
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('🌐 Making GET request to: $baseUrl$endpoint');
      final headers = await getHeaders();
      print('📤 Request headers: $headers');
      
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
      }
      print('🔗 Full URL: $uri');
      
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      print('📥 Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          print('📥 Parsed response data: $responseData');
          return responseData;
        } catch (e) {
          print('💥 JSON parse error: $e');
          print('📥 Raw response body: ${response.body}');
          throw ApiException(
            message: 'خطأ في تنسيق البيانات من الخادم',
            statusCode: response.statusCode,
          );
        }
      } else {
        print('❌ Error response: ${response.body}');
        try {
          final errorData = json.decode(response.body);
          throw ApiException(
            message: errorData['message'] ?? 'حدث خطأ في العملية',
            statusCode: response.statusCode,
          );
        } catch (e) {
          throw ApiException(
            message: 'حدث خطأ في العملية',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      print('💥 API Error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'حدث خطأ في الاتصال بالخادم',
        statusCode: 500,
      );
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'حدث خطأ في العملية',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'حدث خطأ في الاتصال بالخادم',
        statusCode: 500,
      );
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      print('🔄 PATCH request to: $baseUrl$endpoint');
      final headers = await getHeaders();
      print('📤 Request headers: $headers');
      
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return responseData;
      } else {
        print('❌ Error response: $responseData');
        throw ApiException(
          message: responseData['message'] ?? 'حدث خطأ في العملية',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 API Error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'حدث خطأ في الاتصال بالخادم',
        statusCode: 500,
      );
    }
  }

  Future<dynamic> uploadFile(String endpoint, File file, String fieldName) async {
    try {
      print('🔑 جلب الهيدرز');
      final headers = await getHeaders(isMultipart: true);
      print('📤 الهيدرز: $headers');

      print('🌐 إنشاء طلب الرفع');
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🔗 الرابط الكامل: $uri');
      
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(
          fieldName,
          file.path,
        ));
      
      print('🚀 إرسال الطلب');
      final streamedResponse = await request.send();
      print('📥 استلام الاستجابة');
      final response = await http.Response.fromStream(streamedResponse);
      print('📊 كود الاستجابة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ تم رفع الملف بنجاح');
        return responseData;
      } else {
        print('❌ فشل رفع الملف');
        print('⚠️ رسالة الخطأ: ${responseData['message']}');
        throw ApiException(
          message: responseData['message'] ?? 'حدث خطأ غير متوقع',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ خطأ في رفع الملف: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>?> delete(String endpoint) async {
    print('🗑️ DELETE طلب: $endpoint');
    try {
      final headers = await getHeaders();
      print('🔑 الهيدرز: $headers');
      
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      print('📥 استجابة الخادم: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('غير مصرح');
      } else {
        final errorBody = json.decode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'حدث خطأ غير متوقع',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ خطأ في طلب DELETE: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentUserData() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      return json.decode(userData);
    }
    // إرجاع بيانات مستخدم افتراضية إذا لم تكن متوفرة
    return {
      'id': 0,
      'name': 'مستخدم',
      'email': '',
      'avatar': null,
    };
  }
}
