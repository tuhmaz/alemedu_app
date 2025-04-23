import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alemedu_app/features/dashboard/providers/profile_provider.dart';
import 'package:alemedu_app/features/auth/providers/auth_provider.dart';
import 'package:alemedu_app/features/dashboard/screens/edit_profile_screen.dart';
import 'package:alemedu_app/features/messages/screens/messages_screen.dart';
import 'package:alemedu_app/features/notifications/providers/notification_provider.dart';
import 'package:alemedu_app/features/notifications/screens/notifications_screen.dart';
import 'package:alemedu_app/features/messages/providers/message_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/arab_countries.dart';

// Utility function to fix malformed image URLs
String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://alemedu.com/assets/img/avatars/1.png';
  }
  
  // Check if the URL is malformed (contains storage/https://)
  if (url.contains('storage/https://')) {
    // Extract the actual URL part after 'storage/'
    final parts = url.split('storage/');
    if (parts.length > 1) {
      print('🔧 Fixed malformed URL: ${parts[1]}');
      return parts[1]; // Return the actual URL part
    }
  }
  
  // Handle normal URLs
  if (url.startsWith('http')) {
    return url;
  } else {
    return 'https://alemedu.com${url}';
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _ProfilePage(),
    const MessagesScreen(),
    const NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load notifications when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(color: Colors.white),
        ),
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
                        child: Container(
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
                            '${messageProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                        child: Container(
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
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile(context);
    });
  }

  Future<void> _pickAndUploadImage() async {
    print('🖼️ بدء عملية اختيار الصورة');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) {
        print('⚠️ لم يتم اختيار صورة');
        return;
      }

      final imageFile = File(image.path);
      final fileSize = await imageFile.length();
      print('📏 حجم الصورة: $fileSize بايت');
      
      // Get the provider
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
              Text('جاري رفع الصورة...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: Colors.blue,
        ),
      );
      
      print('📤 بدء رفع الصورة');
      await provider.uploadProfilePhoto(context, imageFile);
      print('✅ تم رفع الصورة بنجاح');
      
    } catch (e, stackTrace) {
      print('❌ خطأ في عملية اختيار/رفع الصورة:');
      print('خطأ: $e');
      print('تتبع الخطأ: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء رفع الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchSocialLink(String url) async {
    try {
      print('🔗 فتح الرابط: $url');
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('❌ لا يمكن فتح الرابط: $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح الرابط'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ خطأ في فتح الرابط: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح الرابط: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openSocialLinks(String? links) async {
    if (links == null || links.isEmpty) {
      print('⚠️ لا توجد روابط تواصل اجتماعي');
      return;
    }

    try {
      print('📱 فتح روابط التواصل الاجتماعي');
      final url = links.startsWith('http') ? links : 'https://facebook.com/$links';
      await _launchSocialLink(url);
    } catch (e) {
      print('❌ خطأ في فتح روابط التواصل الاجتماعي: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        final isLoading = profileProvider.isLoading;
        final error = profileProvider.error;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
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
          return const Center(
            child: Text('لا توجد بيانات للملف الشخصي'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                      child: Image(
                        image: CachedNetworkImageProvider(
                          fixImageUrl(profile.avatar),
                          headers: const {
                            'Accept': 'image/*',
                          },
                        ),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ خطأ في تحميل الصورة: $error');
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: _pickAndUploadImage,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileInfoCard(
                title: 'الاسم',
                value: profile.name,
                icon: Icons.person,
              ),
              const SizedBox(height: 8),
              _ProfileInfoCard(
                title: 'البريد الإلكتروني',
                value: profile.email,
                icon: Icons.email,
              ),
              if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'رقم الهاتف',
                  value: profile.phone!,
                  icon: Icons.phone,
                ),
              ],
              if (profile.jobTitle != null && profile.jobTitle!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'المسمى الوظيفي',
                  value: profile.jobTitle!,
                  icon: Icons.work,
                ),
              ],
              if (profile.gender != null) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'الجنس',
                  value: profile.gender == 'male' ? 'ذكر' : 'أنثى',
                  icon: Icons.person_outline,
                ),
              ],
              if (profile.country != null && profile.country!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'الدولة',
                  value: getCountryNameAr(profile.country!),
                  icon: Icons.location_on,
                ),
              ],
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'نبذة شخصية',
                  value: profile.bio!,
                  icon: Icons.info_outline,
                ),
              ],
              if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ProfileInfoCard(
                  title: 'حساب فيسبوك',
                  value: profile.socialLinks!,
                  icon: Icons.facebook,
                  onTap: () => _openSocialLinks(profile.socialLinks),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'تعديل الملف الشخصي',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ProfileInfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, color: iconColor ?? AppColors.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    return const MessagesScreen();
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('صفحة الإشعارات'),
    );
  }
}
