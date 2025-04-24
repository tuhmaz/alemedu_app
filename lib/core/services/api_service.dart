import 'dart:convert';
import 'dart:io';
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
  // Make ApiService singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Constants.
  static const String baseUrl = 'https://alemedu.com/api';
  static const String _apiKeyStorageKey = 'api_key';
  static const String _validApiKey = 'gfOTaGfOcVZigVyN3Go5ZHwr606mmzlPs6gfet0Nsd6d5wBykGGsI9rf1zZ0UYsZ';
  // Private fields.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  //get storage instance.
  FlutterSecureStorage get storage => _storage;

  String? _token; // Store the current token

  // Methods to manage the token
  void addTokenToHeaders(String token) {
    _token = token;
  }

  void removeTokenFromHeaders() {
    _token = null;
  }

  // تهيئة ApiService والتحقق من وجود API Key
  // This function is called only once at app start

  Future<void> initialize() async {    
    final storedApiKey = await _storage.read(key: _apiKeyStorageKey);
    if (storedApiKey == null || storedApiKey.isEmpty) {
      await _storage.write(key: _apiKeyStorageKey, value: _validApiKey);
    }
  }

    Future<String?> getToken() async {
      return _token ?? await _storage.read(key: 'token');
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
      final apiKey = await _storage.read(key: _apiKeyStorageKey);
      final prefs = await SharedPreferences.getInstance();

      // Check if API key exists in shared preferences
      if (prefs.containsKey('apiKey')) {
        final prefsApiKey = prefs.getString('apiKey');
        // If the key in shared preferences is valid , store it in secure storage for consistency, and use it
        if (prefsApiKey != null && prefsApiKey.isNotEmpty) {
          // Also store it in secure storage for consistency
          await _storage.write(key: _apiKeyStorageKey, value: prefsApiKey);
          return prefsApiKey;
        }
      }
      
      // If API key is found in secure storage, store it in shared preferences too, and use it.
      if (apiKey != null) {        
        // Store it in shared preferences too
        await prefs.setString('apiKey', apiKey);
        return apiKey;    
      } else {
        print('⚠️ API Key not found in storage, storing the correct key');

        // Store the correct key in both storages for future use
        await _storage.write(key: _apiKeyStorageKey, value: correctApiKey);
        await prefs.setString('apiKey', correctApiKey);
        
        return correctApiKey;
      }
    } catch (e) {
      print('⚠️ Error getting API key: $e');
      // Fallback to the correct API key in case of any errors.
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
      final String apiKey = await getApiKey(); // Check if the api key is valid or not.
      final Map<String, String> headers = {
        if (!isMultipart) 'Content-Type': 'application/json', // Add content type if it is not multipart.
        'Accept': 'application/json',
        'X-API-KEY': apiKey,
      };
      if(_token != null){
        headers['Authorization'] = 'Bearer $_token';
      }
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

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Handle UnauthorizedException (401) for login endpoints
      if (response.statusCode == 401) {
        try {
          final responseData = json.decode(response.body);          
          if (endpoint == '/login' || endpoint == '/login/google') { // Check if it's a login request
            return responseData; // Return error message
          } else {
            throw UnauthorizedException(responseData['message'] ?? 'انتهت صلاحية الجلسة'); // Throw UnauthorizedException for other endpoints
          }
        } catch (e) { // If failed to parse the body
          if (endpoint == '/login' || endpoint == '/login/google') { // Check if it's a login request
            return {'status': false,'message': 'خطأ في البريد الإلكتروني أو كلمة المرور'}; // Return default error message for login
          } else {
            throw UnauthorizedException('انتهت صلاحية الجلسة');
          }
        }
      }
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) { // Success
        return responseData;
      } else {
        throw ApiException( // Error
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

      final headers = await getHeaders();
      
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
      }

      final response = await http.get(
        uri,
        headers: headers,
      );
      
      print('📥 Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          throw ApiException(            
            message: 'خطأ في تنسيق البيانات من الخادم',            
            statusCode: response.statusCode,
          );
        }
      } else {
        print('❌ Error response: ${response.body}');
        try { // Try to parse error message
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
      
      final responseData = json.decode(response.body); // Parse response body.
      
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
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),        
      );
      
      print('📥 Response status code: ${response.statusCode}'); 
      print('📥 Response body: ${response.body}');
      
      final responseData = json.decode(response.body); // Parse response body.
      
      if (response.statusCode == 200) {
        return responseData;
      } else {
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
      final headers = await getHeaders(isMultipart: true);
      final uri = Uri.parse('$baseUrl$endpoint');      

      // Create and configure multipart request
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(
          fieldName,          file.path,
        ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse); // Get response.

      print('📊 كود الاستجابة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');
      
      final responseData = json.decode(response.body); // Parse response body.
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
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
    try {
      final headers = await getHeaders();

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
  //get the stored user data from local storage.
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
