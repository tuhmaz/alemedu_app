import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/arab_countries.dart';
import '../../../core/constants/colors.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _bioController = TextEditingController();
  final _socialLinksController = TextEditingController();
  String? _selectedGender;
  String? _selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _jobTitleController.text = profile.jobTitle ?? '';
      _bioController.text = profile.bio ?? '';
      _socialLinksController.text = profile.socialLinks ?? '';
      _selectedGender = profile.gender;
      
      // تحقق من أن الدولة موجودة في القائمة
      if (profile.country != null) {
        final countryExists = arabCountries.any((country) => country.code == profile.country);
        _selectedCountry = countryExists ? profile.country : null;
      } else {
        _selectedCountry = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _socialLinksController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<ProfileProvider>().updateProfile(
        context: context,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        gender: _selectedGender,
        country: _selectedCountry?.isEmpty ?? true ? null : _selectedCountry,
        bio: _bioController.text.trim(),
        socialLinks: _socialLinksController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<ProfileProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'فشل تحديث الملف الشخصي'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الاسم
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'البريد الإلكتروني غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // رقم الهاتف
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                      return 'الرجاء إدخال رقم هاتف صحيح';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // المسمى الوظيفي
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(
                  labelText: 'المسمى الوظيفي',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),

              // الجنس
              DropdownButtonFormField<String>(
                value: _selectedGender == '' ? null : _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'الجنس',
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر الجنس')),
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 16),

              // الدولة
              DropdownButtonFormField<String>(
                value: _selectedCountry == '' ? null : _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'الدولة',
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('اختر الدولة'),
                  ),
                  ...arabCountries.map((country) {
                    return DropdownMenuItem(
                      value: country.code,
                      child: Text(country.nameAr),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                },
                isExpanded: true,
              ),
              const SizedBox(height: 16),

              // النبذة الشخصية
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'نبذة شخصية',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // روابط التواصل الاجتماعي
              TextFormField(
                controller: _socialLinksController,
                decoration: const InputDecoration(
                  labelText: 'حساب فيسبوك',
                  prefixIcon: Icon(Icons.facebook),
                  hintText: 'https://facebook.com/username',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.startsWith('https://facebook.com/')) {
                      return 'يجب أن يبدأ الرابط بـ https://facebook.com/';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // زر الحفظ
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
