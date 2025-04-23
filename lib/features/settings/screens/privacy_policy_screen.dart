import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سياسة الخصوصية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '''
مقدمة
نحن في تطبيق علم إيدو نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية. تشرح هذه السياسة كيفية جمعنا واستخدامنا وحماية معلوماتك.

المعلومات التي نجمعها
- معلومات الحساب: الاسم، البريد الإلكتروني، كلمة المرور
- معلومات الاستخدام: تفاعلك مع المحتوى التعليمي
- معلومات الجهاز: نوع الجهاز، نظام التشغيل

كيف نستخدم معلوماتك
- تقديم خدماتنا التعليمية
- تحسين تجربة المستخدم
- التواصل معك بخصوص التحديثات والمحتوى الجديد

حماية البيانات
نتخذ إجراءات أمنية مناسبة لحماية معلوماتك من الوصول غير المصرح به أو التعديل أو الإفصاح.

حقوقك
لديك الحق في:
- الوصول إلى بياناتك
- تصحيح بياناتك
- حذف حسابك
- طلب نسخة من بياناتك

التواصل
إذا كان لديك أي أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا عبر:
البريد الإلكتروني: support@alemedu.com
              ''',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
