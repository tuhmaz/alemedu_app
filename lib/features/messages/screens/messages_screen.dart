import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/message_model.dart';
import '../providers/message_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;
import 'message_details_screen.dart';
import 'create_message_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<int> _selectedMessages = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // جلب الرسائل عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageProvider = context.read<MessageProvider>();
      messageProvider.fetchMessages();
      messageProvider.fetchSentMessages();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleMessageSelection(int messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(messageId);
        _isSelectionMode = true;
      }
    });
  }

  void _deleteSelectedMessages() async {
    final messageProvider = context.read<MessageProvider>();
    final success = await messageProvider.deleteSelectedMessages(_selectedMessages);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الرسائل المحددة بنجاح')),
      );
      setState(() {
        _selectedMessages.clear();
        _isSelectionMode = false;
      });
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    final messageProvider = context.read<MessageProvider>();
    final success = await messageProvider.deleteMessage(messageId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الرسالة بنجاح')),
      );
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'الوارد'),
              Tab(text: 'المرسل'),
            ],
          ),
        ],
      ),
      actions: _isSelectionMode
        ? [
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.primaryColor),
              onPressed: _deleteSelectedMessages,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.primaryColor),
              onPressed: () {
                setState(() {
                  _selectedMessages.clear();
                  _isSelectionMode = false;
                });
              },
            ),
          ]
        : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            if (messageProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (messageProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      messageProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        messageProvider.fetchMessages();
                        messageProvider.fetchSentMessages();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildMessagesList(messageProvider.messages),
                _buildMessagesList(messageProvider.sentMessages),
              ],
            );
          },
        ),
        floatingActionButton: !_isSelectionMode ? FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateMessageScreen(),
              ),
            );
          },
          child: const Icon(Icons.edit, color: Colors.white),
        ) : null,
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('لا توجد رسائل'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final messageProvider = context.read<MessageProvider>();
        await messageProvider.fetchMessages();
        await messageProvider.fetchSentMessages();
      },
      color: AppColors.primaryColor,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: messages.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final message = messages[index];
          final bool isSelected = _selectedMessages.contains(message.id);

          return Dismissible(
            key: Key('message_${message.id}'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
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
            },
            onDismissed: (direction) {
              _deleteMessage(message.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: message.read ? Colors.grey[200] : AppColors.primaryColor,
                child: Icon(
                  Icons.mail,
                  color: message.read ? Colors.grey : Colors.white,
                ),
              ),
              title: Text(
                message.subject,
                style: TextStyle(
                  fontWeight: message.read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageDate(message.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isImportant)
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
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
                        _deleteMessage(message.id);
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageDetailsScreen(
                      message: message,
                      isSent: _tabController.index == 1,
                    ),
                  ),
                );
              },
              onLongPress: () => _toggleMessageSelection(message.id),
              selected: isSelected,
            ),
          );
        },
      ),
    );
  }

  String _formatMessageDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return timeago.format(date, locale: 'ar');
    } else if (difference.inDays < 7) {
      final dayName = intl.DateFormat('EEEE', 'ar').format(date);
      return dayName;
    } else {
      return intl.DateFormat('yyyy/MM/dd', 'ar').format(date);
    }
  }
}
