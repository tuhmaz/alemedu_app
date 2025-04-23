import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/message_model.dart';
import '../providers/message_provider.dart';

class CreateMessageScreen extends StatefulWidget {
  final MessageModel? replyToMessage;
  final String? initialSubject;

  const CreateMessageScreen({
    super.key,
    this.replyToMessage,
    this.initialSubject,
  });

  @override
  State<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;
  int? _selectedUserId;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with reply data if available
    if (widget.replyToMessage != null) {
      _selectedUserId = widget.replyToMessage!.senderId;
      // Load user name after fetching users
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _loadUsers();
        if (mounted) {
          final messageProvider = context.read<MessageProvider>();
          final sender = messageProvider.allUsers.firstWhere(
            (user) => user['id'] == widget.replyToMessage!.senderId,
            orElse: () => {'name': 'Unknown User'},
          );
          _recipientController.text = sender['name'];
        }
      });
    }
    if (widget.initialSubject != null) {
      _subjectController.text = widget.initialSubject!;
    }

    // Schedule loading users after the build is complete
    if (widget.replyToMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUsers();
      });
    }
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    final messageProvider = context.read<MessageProvider>();
    await messageProvider.fetchAllUsers();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final messageProvider = context.read<MessageProvider>();
      
      // إذا لم يتم تحميل المستخدمين بعد، قم بتحميلهم أولاً
      if (messageProvider.allUsers.isEmpty) {
        print('🔍 لم يتم تحميل المستخدمين بعد. جاري التحميل...');
        await messageProvider.fetchAllUsers();
      }
      
      final allUsers = messageProvider.allUsers;
      print('👥 عدد المستخدمين المتاحين للبحث: ${allUsers.length}');
      
      // البحث محلياً في المستخدمين الذين تم جلبهم بالفعل
      final results = allUsers.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
      
      print('🔎 نتائج البحث عن "$query": ${results.length} مستخدم');
      if (results.isNotEmpty) {
        print('👤 النتائج الأولى: ${results.first['name']} (${results.first['email']})');
      }
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في البحث عن المستخدمين: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildRecipientField() {
    final messageProvider = context.watch<MessageProvider>();
    final isLoading = messageProvider.isLoadingUsers;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _recipientController,
          decoration: InputDecoration(
            labelText: 'المستلم',
            hintText: 'اكتب اسم المستلم للبحث',
            prefixIcon: const Icon(Icons.person),
            suffixIcon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          ),
          onChanged: _searchUsers,
          validator: (value) {
            if (_selectedUserId == null) {
              return 'الرجاء اختيار المستلم';
            }
            return null;
          },
        ),
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                    ),
                  ),
                  title: Text(user['name']?.toString() ?? ''),
                  subtitle: Text(user['email']?.toString() ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedUserId = user['id'];
                      _recipientController.text = user['name'];
                      _searchResults = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المستلم')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final messageProvider = context.read<MessageProvider>();
      final success = await messageProvider.sendMessage(
        recipientId: _selectedUserId!,
        subject: _subjectController.text,
        body: _bodyController.text,
      );

      if (success != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الرسالة بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'رسالة جديدة',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildRecipientField(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'الموضوع',
                hintText: 'أدخل موضوع الرسالة',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال موضوع الرسالة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'نص الرسالة',
                hintText: 'اكتب رسالتك هنا',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال نص الرسالة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
