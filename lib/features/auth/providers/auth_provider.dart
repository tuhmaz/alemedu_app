import 'dart:async';

import 'package:alemedu_app/core/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:alemedu_app/core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  String? _error;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error; // Added to the getter

  Future<void> loadStoredToken() async {
    final token = await _storage.read(key: 'token');
    _token = token;
    if (_token != null) {
      ApiService().addTokenToHeaders(_token!);
    }
  }

  Future<Map<String, dynamic>?> _handleRequest(
      Future<Map<String, dynamic>?> Function() request) async {
    try {
      final response = await request();
      return response;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error: $e');
        print(stack);
      }

      if (e is UnauthorizedException) {
        final refreshedToken = await _refreshToken();
        if (refreshedToken != null) {
          _apiService.addTokenToHeaders(refreshedToken);
          return await request();
        }
      } else {
        rethrow;
      }
      rethrow;
    }
  }

  Future<String?> _refreshToken() async {
    final response = await _apiService.post('/refresh', {'token': _token});
    if (response != null &&
        response['status'] == true &&
        response['data'] != null) {
      final data = response['data'];
      final newToken = data['token'];
      _token = newToken;
      await _storage.write(key: 'token', value: newToken);
      return newToken;
    }
    return null;
  }

  Future<bool> signInWithGoogle() async {
    _error = null;
    notifyListeners();

    _isLoading = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _error = 'تم إلغاء تسجيل الدخول عبر Google';
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      String serverClientId =
          "629802140732-27a6f8bel525n2vdj6o375o5s1s9rrrk.apps.googleusercontent.com";
      // إرسال البيانات إلى الخادم
      // معالجة URL الصورة الشخصية لتجنب مشكلة التخزين المزدوج
      String? photoUrl = googleUser.photoUrl;
      if (photoUrl != null && photoUrl.startsWith('https://')) {
        photoUrl = "EXTERNAL_URL:$photoUrl";
      }
      final Map<String, dynamic>? response = await _handleRequest(() async =>
          await _apiService.post('/login/google', {
            'id_token': googleAuth.idToken,
            'access_token': googleAuth.accessToken,
            'email': googleUser.email,
            'name': googleUser.displayName,
            'photo': photoUrl,
            'google_id': googleUser.id, // إضافة معرف جوجل
            'provider': 'google', // تحديد المزود
            'device_type': 'android', // نوع الجهاز
            'external_photo': true, // علامة للإشارة إلى أن الصورة خارجية,
            'server_client_id': serverClientId
          }));
      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null) {
          _token = data['token'];
          _apiService.addTokenToHeaders(_token!);
        }

        if (data['token'] != null && data['user'] != null) {
          _token = data['token'];

          await _storage.write(key: 'token', value: _token);
          _user = UserModel.fromJson(data['user']);
          await setCurrentUser(_user!);
          notifyListeners();
          return true;
        }
      }

      _error = response?['message'] ?? 'حدث خطأ أثناء تسجيل الدخول';
      notifyListeners();
      return false;
    } catch (e, stack) {
      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      if (kDebugMode) {
        print(e);
        print(stack);
      }
      notifyListeners();

      return false;
    } finally {
      _isLoading = false;
       notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();
    _isLoading = true;
    try {
      final Map<String, dynamic>? response = await _handleRequest(() async =>
          await _apiService.post('/login', {
            'email': email,
            'password': password,
          }));

      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null && data['user'] != null) {
          _token = data['token'];
          _apiService.addTokenToHeaders(_token!);
          await _storage.write(key: 'token', value: _token);
          _user = UserModel.fromJson(data['user']);

          await setCurrentUser(_user!);

          notifyListeners();
          return true;
        } else {
          if (kDebugMode) {
            print('Token or user data not found in the response: $data');
          }
        }
      } 
     
      _error = response?['message'] ?? 'خطأ في البريد الإلكتروني أو كلمة المرور';
      notifyListeners();
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error: $e');
        print(stack);
      }
      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } finally {
        _isLoading = false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _error = null;
    notifyListeners();

      _isLoading = true;
    try {
      final Map<String, dynamic>? response = await _handleRequest(() async =>
          await _apiService.post('/auth/forgot-password', {
            'email': email,
          }));
      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
          
        notifyListeners();
        return true;
      }
        _error = response?['message'] ?? 'فشل ارسال رسالة اعادة تعيين كلمة المرور';
        notifyListeners();
        return false;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error: $e');
        print(stack);
      }
      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } finally {
       _isLoading = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _error = null;
    notifyListeners();
     _isLoading = true;
    try {
      final Map<String, dynamic>? response = await _handleRequest(() async =>
          await _apiService.post('/register', {
            'name': name,
            'email': email,
            'password': password,
            'password_confirmation': password,
          }));
      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null && data['user'] != null) {
          _token = data['token'];
          _apiService.addTokenToHeaders(_token!);

          await _storage.write(key: 'token', value: _token);
          _user = UserModel.fromJson(data['user']);
          await setCurrentUser(_user!);
          notifyListeners();
          return true;
        }
      }
      _error = response?['message'] ?? 'فشل التسجيل. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error: $e');
        print(stack);
      }
      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

      notifyListeners();
      return false;
    } finally {
       _isLoading = false;
    }
  }

  Future<void> setCurrentUser(UserModel user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<void> loadStoredUser() async {
    await loadStoredToken();
    final storedUser = await _storage.read(key: 'user');
    if (storedUser != null) {
      _user = UserModel.fromJson(jsonDecode(storedUser));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    _apiService.removeTokenFromHeaders();
    _token = null;
    notifyListeners();
  }
}
