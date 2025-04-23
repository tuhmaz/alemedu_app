import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

// Define the app's main colors
const Color primaryColor = Color(0xFF1363DF);  // Main blue color
const Color secondaryColor = Color(0xFF47B5FF); // Secondary blue
const Color accentColor = Color(0xFFDFF6FF);   // Light blue
const Color starColor = Color(0xFFFFD700);     // Golden color for stars

class DownloadScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const DownloadScreen({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  int _timeLeft = 35;
  late Timer _timer;
  bool _canDownload = false;
  int _score = 0;
  final List<CollectibleItem> _items = [];
  final Random _random = Random();
  late Timer _gameTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
    startGameLoop();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _canDownload = true;
          _timer.cancel();
          _gameTimer.cancel();
        }
      });
    });
  }

  void startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (!_canDownload) {
        addNewItem();
      }
    });
  }

  void addNewItem() {
    if (_items.length < 5) {
      setState(() {
        _items.add(CollectibleItem(
          x: _random.nextDouble() * (MediaQuery.of(context).size.width - 40),
          y: 0,
          speed: _random.nextDouble() * 2 + 1,
        ));
      });
    }
  }

  void collectItem(int index) {
    setState(() {
      _items.removeAt(index);
      _score++;
      if (_timeLeft > 1) {
        _timeLeft--;
      }
    });
  }

  void updateItemPositions() {
    setState(() {
      for (int i = _items.length - 1; i >= 0; i--) {
        _items[i] = _items[i].copyWith(
          y: _items[i].y + _items[i].speed,
        );
        
        if (_items[i].y > MediaQuery.of(context).size.height) {
          _items.removeAt(i);
        }
      }
    });
  }

  Future<void> _downloadFile() async {
    final Uri url = Uri.parse(widget.fileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => updateItemPositions());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تحميل الملف',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Game items
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Positioned(
                left: item.x,
                top: item.y,
                child: GestureDetector(
                  onTapDown: (_) => collectItem(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: starColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: starColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                ),
              );
            }),
            
            // UI Elements
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.file_present_rounded,
                            size: 50,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'اسم الملف:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.fileName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'النقاط: $_score',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_canDownload) ...[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _timeLeft / 35,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          Text(
                            '$_timeLeft',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'اضغط على النجوم لتقليل وقت الانتظار!',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (_canDownload)
                      ElevatedButton.icon(
                        onPressed: _downloadFile,
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          'حمل الآن',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectibleItem {
  final double x;
  final double y;
  final double speed;

  CollectibleItem({
    required this.x,
    required this.y,
    required this.speed,
  });

  CollectibleItem copyWith({
    double? x,
    double? y,
    double? speed,
  }) {
    return CollectibleItem(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
    );
  }
}
