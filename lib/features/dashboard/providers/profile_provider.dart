import 'package:flutter/material.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        throw ApiException(
          message: 'لم يتم العثور على معرف المستخدم',
          statusCode: 401,
        );
      }

      final response = await _apiService.get('/dashboard/users/$userId');
      
      if (response['status'] == true && response['data']?['user'] != null) {
        final userData = response['data']['user'];
        
        // تحقق من وجود الصورة الشخصية
        if (userData['avatar'] == null || userData['avatar'].toString().isEmpty) {
          print('⚠️ لا توجد صورة شخصية');
          userData['avatar'] = 'https://alemedu.com/assets/img/avatars/1.png';
        }
        
        _profile = ProfileModel.fromJson(userData);
      } else {
        _error = 'لا توجد بيانات للمستخدم';
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'حدث خطأ غير متوقع';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required BuildContext context,
    String? name,
    String? email,
    String? phone,
    String? jobTitle,
    String? gender,
    String? country,
    String? bio,
    String? socialLinks,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId == null) {
        throw ApiException(
          message: 'لم يتم العثور على معرف المستخدم',
          statusCode: 401,
        );
      }

      // تأكد من إرسال البيانات الإلزامية
      if (_profile == null) {
        throw ApiException(
          message: 'لم يتم العثور على بيانات الملف الشخصي',
          statusCode: 404,
        );
      }

      // تحضير البيانات للإرسال
      final data = {
        'name': name ?? _profile!.name,
        'email': email ?? _profile!.email,
        'phone': phone ?? _profile!.phone,
        'job_title': jobTitle ?? _profile!.jobTitle,
        'gender': gender ?? _profile!.gender,
        'country': country ?? _profile!.country,
        'bio': bio ?? _profile!.bio,
        'social_links': socialLinks ?? _profile!.socialLinks,
      };

      
      final response = await _apiService.put('/dashboard/users/$userId', data);

      if (response['status'] == true && response['data']?['user'] != null) {
        _profile = ProfileModel.fromJson(response['data']['user']);
        notifyListeners();
        return true;
      }

      _error = response['message'] ?? 'فشل تحديث الملف الشخصي';
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      _error = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(String newPhotoUrl) async {
    try {
      if (_profile == null) {
        throw ApiException(
          message: 'لم يتم العثور على بيانات الملف الشخصي',
          statusCode: 404,
        );
      }

      // تحديث الصورة في النموذج المحلي
      _profile = ProfileModel(
        id: _profile!.id,
        name: _profile!.name,
        email: _profile!.email,
        phone: _profile!.phone,
        jobTitle: _profile!.jobTitle,
        gender: _profile!.gender,
        country: _profile!.country,
        bio: _profile!.bio,
        socialLinks: _profile!.socialLinks,
        status: _profile!.status,
        lastActivity: _profile!.lastActivity,
        avatar: newPhotoUrl,
        createdAt: _profile!.createdAt,
        updatedAt: _profile!.updatedAt,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(BuildContext context, File photo) async {
    try {
      print('📏 التحقق من حجم الصورة');
      final fileSize = await photo.length();
      
      if (fileSize > 5 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حجم الصورة كبير جداً. يجب أن يكون أقل من 5 ميجابايت'),
            ),
          );
        }
        return false;
      }

      print('🔑 جلب معرف المستخدم');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;      
      
      if (userId == null) {
        throw ApiException(
          message: 'لم يتم العثور على معرف المستخدم',
          statusCode: 401,
        );
      }

      print('🔄 عرض مؤشر التحميل');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(width: 16),
                Text('جاري تحديث الصورة...'),
              ],
            ),
            duration: Duration(seconds: 30),
            backgroundColor: Colors.blue,
          ),
        );
      }

      print('📤 بدء رفع الصورة');
      final response = await _apiService.uploadFile(
        '/dashboard/users/$userId/update-profile-photo',
        photo,
        'profile_photo',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      if (response != null && response['status'] == true && response['data']?['user'] != null) {
        final userData = response['data']['user'] as Map<String, dynamic>;
        final newPhotoUrl = userData['avatar'] as String?;
        
        if (newPhotoUrl != null) {
          await updateProfilePhoto(newPhotoUrl);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الصورة الشخصية بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return true;
        }
      }
      
      throw ApiException(
        message: 'فشل في تحديث الصورة الشخصية',
        statusCode: 500,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? jobTitle,
    String? gender,
    String? country,
    String? bio,
    String? socialLinks,
    String? status,
    String? lastActivity,
    String? avatar,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? _profile!.id,
      name: name ?? _profile!.name,
      email: email ?? _profile!.email,
      phone: phone ?? _profile!.phone,
      jobTitle: jobTitle ?? _profile!.jobTitle,
      gender: gender ?? _profile!.gender,
      country: country ?? _profile!.country,
      bio: bio ?? _profile!.bio,
      socialLinks: socialLinks ?? _profile!.socialLinks,
      status: status ?? _profile!.status,
      lastActivity: lastActivity ?? _profile!.lastActivity,
      avatar: avatar ?? _profile!.avatar,
      createdAt: createdAt ?? _profile!.createdAt,
      updatedAt: updatedAt ?? _profile!.updatedAt,
    );
  }
}
