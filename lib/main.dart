import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

// Initialize the local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Notifications Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _fcmToken = 'Loading...';
  String _lastMessage = 'No messages received yet';
  int _messageCount = 0;
  final List<String> _subscribedTopics = [];
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token ?? 'Failed to get token';
    });
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}');
      setState(() {
        _messageCount++;
        _lastMessage = message.notification?.title ?? 'No title';
      });
      _showNotification(message);
    });

    // Handle message taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.notification?.title}');
      setState(() {
        _lastMessage = 'Tapped: ${message.notification?.title ?? 'No title'}';
      });
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'firebase_channel',
      'Firebase Notifications',
      channelDescription: 'Channel for Firebase notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
    );
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      setState(() {
        if (!_subscribedTopics.contains(topic)) {
          _subscribedTopics.add(topic);
        }
      });
      _showSnackBar('Subscribed to topic: $topic', Colors.green);
      print('Successfully subscribed to topic: $topic');
    } catch (e) {
      _showSnackBar('Failed to subscribe: $e', Colors.red);
      print('Failed to subscribe to topic: $e');
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      setState(() {
        _subscribedTopics.remove(topic);
      });
      _showSnackBar('Unsubscribed from topic: $topic', Colors.orange);
      print('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      _showSnackBar('Failed to unsubscribe: $e', Colors.red);
      print('Failed to unsubscribe from topic: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)));
  }

  void _addTopicFromInput() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      _subscribeToTopic(topic);
      _topicController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Notifications'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FCM Token:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(_fcmToken, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          String? token = await FirebaseMessaging.instance.getToken();
                          setState(() {
                            _fcmToken = token ?? 'Failed to get token';
                          });
                        },
                        child: const Text('Refresh Token'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages Received: $_messageCount',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Last Message: $_lastMessage', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Topic Subscriptions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _topicController,
                              decoration: const InputDecoration(
                                hintText: 'Enter topic name (e.g., news, sports)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onSubmitted: (_) => _addTopicFromInput(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: _addTopicFromInput, child: const Text('Subscribe')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Quick Topics:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTopicChip('news'),
                          _buildTopicChip('sports'),
                          _buildTopicChip('weather'),
                          _buildTopicChip('tech'),
                          _buildTopicChip('general'),
                        ],
                      ),
                      if (_subscribedTopics.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Subscribed Topics:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: _subscribedTopics.map((topic) => _buildSubscribedTopicChip(topic)).toList()),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instructions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        '1. Copy the FCM token above\n'
                        '2. Add your google-services.json file to android/app/\n'
                        '3. Use Firebase Console or server to send notifications\n'
                        '4. Test both foreground and background notifications\n'
                        '5. Subscribe to topics to receive topic-based messages',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    final isSubscribed = _subscribedTopics.contains(topic);
    return ActionChip(
      label: Text(topic),
      backgroundColor: isSubscribed ? Colors.green.shade100 : Colors.grey.shade200,
      onPressed: () {
        if (isSubscribed) {
          _unsubscribeFromTopic(topic);
        } else {
          _subscribeToTopic(topic);
        }
      },
      avatar: Icon(
        isSubscribed ? Icons.check_circle : Icons.add_circle_outline,
        size: 18,
        color: isSubscribed ? Colors.green : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildSubscribedTopicChip(String topic) {
    return Chip(
      label: Text(topic),
      backgroundColor: Colors.blue.shade100,
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _unsubscribeFromTopic(topic),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}
