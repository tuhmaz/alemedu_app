import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/message_model.dart';
import '../providers/message_provider.dart';
import 'package:timeago/timeago.dart';
import 'create_message_screen.dart';

class MessageDetailsScreen extends StatefulWidget {
  final MessageModel message;
  final bool isSent;

  const MessageDetailsScreen({
    super.key,
    required this.message,
    required this.isSent,
  });

  @override
  State<MessageDetailsScreen> createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.message.read && !widget.isSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MessageProvider>().markMessageAsRead(widget.message.id);
      });
    }
  }

  Future<void> _deleteMessage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final messageProvider = context.read<MessageProvider>();
      final success = await messageProvider.deleteMessage(widget.message.id);
      
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الرسالة بنجاح')),
          );
          Navigator.of(context).pop(); // Return to previous screen
        }
      }
    }
  }

  Future<void> _toggleImportant(BuildContext context) async {
    final messageProvider = context.read<MessageProvider>();
    await messageProvider.toggleImportant(widget.message.id);
  }

  Future<void> _replyToMessage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMessageScreen(
          replyToMessage: widget.message,
          initialSubject: 'رد: ${widget.message.subject}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: Text(
          widget.isSent ? 'رسالة مرسلة' : 'رسالة واردة',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.message.isImportant ? Icons.star : Icons.star_border,
              color: widget.message.isImportant ? Colors.amber : Colors.grey,
            ),
            onPressed: () => _toggleImportant(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteMessage(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // موضوع الرسالة
            Text(
              widget.message.subject,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // معلومات الرسالة
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  format(DateTime.parse(widget.message.createdAt), locale: 'ar'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // محتوى الرسالة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.message.body,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !widget.isSent ? FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => _replyToMessage(context),
        child: const Icon(Icons.reply),
      ) : null,
    );
  }
}
