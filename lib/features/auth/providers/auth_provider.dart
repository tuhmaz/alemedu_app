import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '629802140732-27a6f8bel525n2vdj6o375o5s1s9rrrk.apps.googleusercontent.com',
  );
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    print('🔍 بدء عملية تسجيل الدخول عبر Google');
    print('🔧 استخدام معرف العميل: ${_googleSignIn.serverClientId}');

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      print('🔄 محاولة فتح نافذة تسجيل الدخول عبر Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ تم إلغاء عملية تسجيل الدخول من قبل المستخدم');
        _error = 'تم إلغاء تسجيل الدخول عبر Google';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      print('✅ تم تسجيل الدخول بنجاح عبر Google');
      print('👤 معلومات المستخدم:');
      print('   - الاسم: ${googleUser.displayName}');
      print('   - البريد الإلكتروني: ${googleUser.email}');
      print('   - معرف المستخدم: ${googleUser.id}');
      print('   - الصورة: ${googleUser.photoUrl ?? "غير متوفرة"}');

      print('🔑 جاري الحصول على رموز المصادقة...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('🔐 تم الحصول على الرموز:');
      print('   - idToken: ${googleAuth.idToken?.substring(0, 20)}... (مختصر)');
      print('   - accessToken: ${googleAuth.accessToken?.substring(0, 20)}... (مختصر)');

      // إرسال البيانات إلى الخادم
      print('📤 إرسال البيانات إلى الخادم على المسار: /login/google');
      final response = await _apiService.post('/login/google', {
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo': googleUser.photoUrl,
      });
      print('📥 استجابة الخادم:');
      print(response);



      if (response != null && 
          response['status'] == true && 
          response['data'] != null) {
        print('✅ استجابة الخادم ناجحة، حالة: ${response['status']}');
        final data = response['data'];
        if (data['token'] != null && data['user'] != null) {
          print('✅ تم العثور على التوكن وبيانات المستخدم');
          print('🔑 التوكن: ${data['token'].substring(0, 20)}... (مختصر)');
          print('👤 بيانات المستخدم: ${data['user']}');
          
          await _storage.write(key: 'token', value: data['token']);
          print('💾 تم تخزين التوكن في التخزين الآمن');
          
          _user = UserModel.fromJson(data['user']);
          print('🔄 تم إنشاء كائن المستخدم: ${_user?.name}');
          
          await setCurrentUser(_user!);
          print('✅ تم حفظ بيانات المستخدم');

          _isLoading = false;
          notifyListeners();
          print('🎉 تم تسجيل الدخول بنجاح!');
          return true;
        } else {
          print('⚠️ لم يتم العثور على التوكن أو بيانات المستخدم في الاستجابة');
          print('📄 محتوى البيانات: $data');
        }
      } else {
        print('❌ فشل في استجابة الخادم');
        print('📄 محتوى الاستجابة: $response');
      }

      _error = response?['message'] ?? 'حدث خطأ أثناء تسجيل الدخول';
      print('❌ تم تعيين رسالة الخطأ: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      print('❌❌❌ حدث خطأ غير متوقع:');
      print('🔴 نوع الخطأ: ${e.runtimeType}');
      print('🔴 رسالة الخطأ: $e');
      print('🔴 تتبع الخطأ:');
      print(stack);

      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {

      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      });



      if (response != null && 
          response['status'] == true && 
          response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null && data['user'] != null) {

          await _storage.write(key: 'token', value: data['token']);
          _user = UserModel.fromJson(data['user']);
          await setCurrentUser(_user!);

          notifyListeners();
          return true;
        }
      }


      _error = response?['message'] ?? 'خطأ في البريد الإلكتروني أو كلمة المرور';
      notifyListeners();
      return false;
    } catch (e) {

      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {

      final response = await _apiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });



      if (response != null && 
          response['status'] == true && 
          response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null && data['user'] != null) {

          await _storage.write(key: 'token', value: data['token']);
          _user = UserModel.fromJson(data['user']);
          await setCurrentUser(_user!);

          notifyListeners();
          return true;
        }
      }


      _error = response?['message'] ?? 'فشل التسجيل. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } catch (e) {

      _error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrentUser(UserModel user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<void> loadStoredUser() async {
    final storedUser = await _storage.read(key: 'user');
    if (storedUser != null) {
      _user = UserModel.fromJson(jsonDecode(storedUser));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    notifyListeners();
  }
}
