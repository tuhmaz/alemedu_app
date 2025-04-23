import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    try {
      // The correct API key provided by the server
      const correctApiKey = 'gfOTaGfOcVZigVyN3Go5ZHwr606mmzlPs6gfet0Nsd6d5wBykGGsI9rf1zZ0UYsZ';
      
      // Try to get API key from both secure storage and shared preferences
      final apiKey = await storage.read(key: _apiKeyStorageKey);
      final prefs = await SharedPreferences.getInstance();
      
      // Check if API key exists in shared preferences
      if (prefs.containsKey('apiKey')) {
        final prefsApiKey = prefs.getString('apiKey');
        print('🔑 Found API key in shared preferences: ${prefsApiKey?.substring(0, min(prefsApiKey?.length ?? 0, 5))}...');
        
        // If the key in shared preferences is valid, use it
        if (prefsApiKey != null && prefsApiKey.isNotEmpty) {
          // Also store it in secure storage for consistency
          await storage.write(key: _apiKeyStorageKey, value: prefsApiKey);
          return prefsApiKey;
        }
      }
      
      // If API key is found in secure storage
      if (apiKey != null) {
        print('🔑 Found API key in secure storage: ${apiKey.substring(0, min(apiKey.length, 5))}...');
        
        // Store it in shared preferences too
        await prefs.setString('apiKey', apiKey);
        return apiKey;
      } else {
        print('⚠️ API Key not found in storage, storing the correct key');
        
        // Store the correct key in both storages for future use
        await storage.write(key: _apiKeyStorageKey, value: correctApiKey);
        await prefs.setString('apiKey', correctApiKey);
        
        return correctApiKey;
      }
    } catch (e) {
      print('⚠️ Error getting API key: $e');
      
      // Fallback to the correct API key in case of any errors
      const correctApiKey = 'gfOTaGfOcVZigVyN3Go5ZHwr606mmzlPs6gfet0Nsd6d5wBykGGsI9rf1zZ0UYsZ';
      
      // Try to store it in shared preferences as a last resort
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('apiKey', correctApiKey);
      } catch (e) {
        print('❌ Failed to store API key in shared preferences: $e');
      }
      
      return correctApiKey;
    }
  }

  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    try {
      final token = await getToken();
      final apiKey = await getApiKey();  // سيقوم بالتحقق من الصلاحية تلقائياً
      
      print('💬 إنشاء الهيدرز للطلب');
      print('🔑 API Key: ${apiKey.substring(0, min(apiKey.length, 5))}...');
      if (token != null) {
        print('🔒 Token: ${token.substring(0, min(token.length, 5))}...');
      }
      
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
      print('🌐 POST request to: $baseUrl$endpoint');
      print('📤 Request data: $data');
      
      final headers = await getHeaders();
      print('📤 Request headers: $headers');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      // خاص بتسجيل الدخول: إذا كان الخطأ 401 وكان الطلب هو تسجيل الدخول، فلا نعتبره انتهاء صلاحية الجلسة
      // بل نعتبره خطأ في بيانات تسجيل الدخول
      if (response.statusCode == 401) {
        print('🔒 Unauthorized: 401 error');
        
        // محاولة تحليل رسالة الخطأ من الاستجابة
        try {
          final responseData = json.decode(response.body);
          if (endpoint == '/login' || endpoint == '/login/google') {
            print('💬 خطأ في تسجيل الدخول: ${responseData['message']}');
            // إرجاع البيانات بدلاً من رمي استثناء لتسجيل الدخول
            return responseData;
          } else {
            throw UnauthorizedException(responseData['message'] ?? 'انتهت صلاحية الجلسة');
          }
        } catch (e) {
          // إذا فشل تحليل الاستجابة، نستخدم الرسالة الافتراضية
          if (endpoint == '/login' || endpoint == '/login/google') {
            return {
              'status': false,
              'message': 'خطأ في البريد الإلكتروني أو كلمة المرور'
            };
          } else {
            throw UnauthorizedException('انتهت صلاحية الجلسة');
          }
        }
      }
      
      final responseData = json.decode(response.body);
      print('📥 Parsed response data: $responseData');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Request successful with status: ${response.statusCode}');
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
