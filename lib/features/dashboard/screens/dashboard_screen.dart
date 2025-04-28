import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alemedu_app/features/dashboard/providers/profile_provider.dart';
import 'package:alemedu_app/features/auth/providers/auth_provider.dart';
import 'package:alemedu_app/features/dashboard/screens/edit_profile_screen.dart';
import 'package:alemedu_app/features/messages/screens/messages_screen.dart';
import 'package:alemedu_app/features/notifications/providers/notification_provider.dart';
import 'package:alemedu_app/features/notifications/screens/notifications_screen.dart';
import 'package:alemedu_app/features/messages/providers/message_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/arab_countries.dart';

String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://alemedu.com/assets/img/avatars/1.png';
  }
  if (url.contains('storage/https://')) {
    final parts = url.split('storage/');
    if (parts.length > 1) {
      return parts[1];
    }
  }
  if (url.startsWith('http')) {
    return url;
  } else {
    return 'https://alemedu.com$url';
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _ProfilePage(),
    MessagesScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('لوحة التحكم', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Consumer2<MessageProvider, NotificationProvider>(
        builder: (context, messageProvider, notificationProvider, child) {
          final unreadCount = notificationProvider.notifications
              .where((notification) => !notification.isRead)
              .length;

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'الملف الشخصي',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.message),
                    if (messageProvider.hasUnreadMessages)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: _buildBadge(messageProvider.unreadCount),
                      ),
                  ],
                ),
                label: 'الرسائل',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: _buildBadge(unreadCount),
                      ),
                  ],
                ),
                label: 'الإشعارات',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 12,
        minHeight: 12,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

String getCountryNameAr(String countryCode) {
  final country = arabCountries.firstWhere(
    (country) => country.code == countryCode,
    orElse: () => const ArabCountry(code: '', nameAr: 'غير محدد', nameEn: 'Not specified'),
  );
  return country.nameAr;
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().fetchProfile(context);
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final imageFile = File(image.path);
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.uploadProfilePhoto(context, imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final profile = profileProvider.profile;
            final isLoading = profileProvider.isLoading;
            final error = profileProvider.error;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => profileProvider.fetchProfile(context),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (profile == null) {
              return const Center(child: Text('لا توجد بيانات للملف الشخصي'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: fixImageUrl(profile.avatar),
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                      _buildCameraButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoCard(title: 'الاسم', value: profile.name, icon: Icons.person),
                  _ProfileInfoCard(title: 'البريد الإلكتروني', value: profile.email, icon: Icons.email),
                  if (profile.phone?.isNotEmpty ?? false) _ProfileInfoCard(title: 'رقم الهاتف', value: profile.phone!, icon: Icons.phone),
                  if (profile.jobTitle?.isNotEmpty ?? false) _ProfileInfoCard(title: 'المسمى الوظيفي', value: profile.jobTitle!, icon: Icons.work),
                  if (profile.gender != null) _ProfileInfoCard(title: 'الجنس', value: profile.gender == 'male' ? 'ذكر' : 'أنثى', icon: Icons.person_outline),
                  if (profile.country?.isNotEmpty ?? false) _ProfileInfoCard(title: 'الدولة', value: getCountryNameAr(profile.country!), icon: Icons.location_on),
                  if (profile.bio?.isNotEmpty ?? false) _ProfileInfoCard(title: 'نبذة شخصية', value: profile.bio!, icon: Icons.info_outline),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل الملف الشخصي'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  ),
                ],
              ),
            );
          },
        ),
        if (_isUploading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: _pickAndUploadImage,
        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileInfoCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
