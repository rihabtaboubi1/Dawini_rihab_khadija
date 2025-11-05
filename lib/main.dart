import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otlobni/AboutUsPage.dart';
import 'package:otlobni/PharmacistSpacePage.dart';
import 'package:otlobni/WelcomePage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'patientScreen.dart';
import 'doctorScreen.dart';
import 'pharmacistScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}                                                                                             

const appId = "4bbc8ed835d246e89f04423a45fa8903"; // Votre App ID
const channel = "channel1"; // Nom du canal
const hostUrl = "https://4208-41-224-213-22.ngrok-free.app/token"; // URL publique ngrok

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/patientHome': (context) => PatientScreen(),
        '/doctorHome': (context) => DoctorScreen(),
        '/pharmacistHome': (context) => PharmacistSpacePage(),
        '/about': (context) => AboutUsPage(),
      },
    );
  }
}

void navigateTo(String route) {
  navigatorKey.currentState?.pushNamed(route);
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  late RtcEngine _engine;
  String? _token; // Token dynamique
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchTokenAndStartCall();
  }

  Future<void> _fetchTokenAndStartCall() async {
    await _requestPermissions();
    await _initializeAgoraVideoSDK();
    await _setupLocalVideo();
    _setupEventHandlers();

    // Récupérer le token dynamique
    try {
      _token = await _fetchToken();
      if (_token != null) {
        await _joinChannel();
      } else {
        debugPrint("Erreur : Token non récupéré");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération du token : $e");
    }
  }

  // Fonction pour récupérer le token depuis le backend
  Future<String> _fetchToken() async {
  try {
    final response = await http.get(
      Uri.parse('$hostUrl?channel=$channel'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Retourne le token généré
    } else {
      throw Exception('Erreur lors de la récupération du token');
    }
  } catch (e) {
    debugPrint("Erreur lors de la récupération du token : $e");
    rethrow;
  }
}

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _initializeAgoraVideoSDK() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
  }

  Future<void> _setupLocalVideo() async {
    await _engine.enableVideo();
    await _engine.startPreview();
  }

  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() => _remoteUid = remoteUid);
          _showCallNotification();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() => _remoteUid = null);
        },
      ),
    );
  }

  Future<void> _joinChannel() async {
    if (_token == null) {
      debugPrint("Erreur : Token non disponible");
      return;
    }

    await _engine.joinChannel(
      token: _token!, // Utiliser le token dynamique
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  Future<void> _leaveChannel() async {
    await _engine.leaveChannel();
    setState(() => _localUserJoined = false);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DoctorScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _toggleMic() async {
    await _engine.muteLocalAudioStream(!_isMicMuted);
    setState(() => _isMicMuted = !_isMicMuted);
  }

  Future<void> _toggleCamera() async {
    await _engine.muteLocalVideoStream(!_isCameraOff);
    setState(() => _isCameraOff = !_isCameraOff);
  }

  @override
  void dispose() {
    _cleanupAgoraEngine();
    super.dispose();
  }

  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _showCallNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Video Call',
      'You have an incoming call from a patient!',
      platformChannelSpecifics,
      payload: 'call_data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Otlobni'), backgroundColor: Colors.blueGrey[900]),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: _localUserJoined
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _isCameraOff
                          ? Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.videocam_off, color: Colors.white, size: 50),
                            )
                          : _localVideo(),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "mute_mic",
                  onPressed: _toggleMic,
                  backgroundColor: _isMicMuted ? Colors.red : Colors.grey[800],
                  child: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "end_call",
                  onPressed: _leaveChannel,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "toggle_camera",
                  onPressed: _toggleCamera,
                  backgroundColor: _isCameraOff ? Colors.red : Colors.grey[800],
                  child: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _localVideo() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(
          uid: 0,
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'En attente de l’utilisateur distant...',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}