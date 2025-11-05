  import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otlobni/PatientHistoryPage.dart';
import 'package:otlobni/ShakeAnimation.dart';
import 'package:otlobni/ViewDoctorProfilePage.dart';
import 'package:otlobni/doctorprescreption_page.dart';
  import 'package:otlobni/main.dart';
  import 'package:animate_do/animate_do.dart';
  import 'package:otlobni/AuthScreen.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otlobni/pharmacylistpagevalidatorDoctor.dart';
import 'package:url_launcher/url_launcher.dart'; // Utilisez cloud_firestore

  class DoctorScreen extends StatefulWidget {
    const DoctorScreen({Key? key}) : super(key: key);

    @override
    _DoctorScreenState createState() => _DoctorScreenState();
  }

  class _DoctorScreenState extends State<DoctorScreen> with WidgetsBindingObserver {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    List<QueryDocumentSnapshot> _pendingCalls = []; // Liste pour stocker les appels en attente
    Set<String> _displayedCallIds = {}; // Pour garder une trace des appels déjà affichés
  Map<String, BuildContext> _popupContexts = {}; // Pour stocker les contextes des popups



  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _updateDoctorStatus(true); // Mettre à jour le statut à "en ligne"
  _initializeFirebaseMessaging();
  _listenForCalls(context);
  

  final user = FirebaseAuth.instance.currentUser;
  final doctorId = user?.uid; // Récupérer l'UID du médecin connecté
  if (doctorId != null) {
    _listenForCallsOne(context, doctorId); // Passer le doctorId à _listenForCallsOne
  }
}

@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateDoctorStatus(false); // Mettre à jour le statut à "hors ligne" lors de la fermeture
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // L'application est en arrière-plan ou fermée
      _updateDoctorStatus(false); // Mettre à jour le statut à "hors ligne"
    } else if (state == AppLifecycleState.resumed) {
      // L'application est de retour au premier plan
      _updateDoctorStatus(true); // Mettre à jour le statut à "en ligne"
    }
  }
Future<void> _updateDoctorStatus(bool isOnline) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user.uid) // Utilise l'UID du médecin comme ID du document
        .update({'is_online': isOnline});
  }
}

    void _initializeFirebaseMessaging() async {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Notification reçue : ${message.notification?.title}");
        print("Données : ${message.data}");

        final String patientName = message.data['patient_name'] ?? 'Patient inconnu';
        final String callType = message.data['call_type'] ?? 'appel';

        // Afficher une popup pour l'appel entrant
        _showIncomingCallPopup(
          context,
          patientName: patientName,
          callType: callType,
          callId: message.data['callId'] ?? '', // Transmettre l'ID de l'appel
        );
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      print("Notification en arrière-plan : ${message.notification?.title}");
      print("Données : ${message.data}");
    }

   void _listenForCalls(BuildContext context) {
  FirebaseFirestore.instance
      .collection('callsAll')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final patientName = doc['patient_name'];
      final callType = doc['call_type'];
      final callId = doc.id;

      // Afficher une popup pour l'appel entrant
      _showIncomingCallPopup(
        context,
        patientName: patientName,
        callType: callType,
        callId: callId,
      );
    }
  });
}

/*void _listenForCalls(BuildContext context) {
    FirebaseFirestore.instance
        .collection('calls')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        final callId = doc.id;
        final patientName = doc['patient_name'];
        final callType = doc['call_type'];

        // Écouter les changements de statut en temps réel pour cet appel
        _listenForCallStatusChange(context, callId, patientName, callType);
      }
    });
  }

  void _listenForCallStatusChange(BuildContext context, String callId, String patientName, String callType) {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (doc.exists) {
        final status = doc['status'];

        // Si le statut est "pending", afficher le popup
        if (status == 'pending') {
          _showIncomingCallPopup(
            context,
            patientName: patientName,
            callType: callType,
            callId: callId,
          );
        }
        // Si le statut est "accepted", fermer le popup
        else if (status == 'accepted') {
          _closeIncomingCallPopup(context, callId);
        }
      }
    });
  }

 void _closeIncomingCallPopup(BuildContext context, String callId) {
    if (_popupContexts.containsKey(callId)) {
      Navigator.of(_popupContexts[callId]!).pop(); // Fermer la popup
      _popupContexts.remove(callId); // Supprimer le contexte de la map
      _displayedCallIds.remove(callId); // Supprimer l'ID de la liste des popups affichés
    }
  }*/


void _listenForCallsOne(BuildContext context, String doctorId) {
  FirebaseFirestore.instance
      .collection('callsOne')
      .where('doctor_id', isEqualTo: doctorId)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final patientName = doc['patient_name'];
      final callType = doc['call_type'];
      final callId = doc.id;

      // Afficher une popup pour l'appel entrant
      _showIncomingCallPopupOne(
        context,
        patientName: patientName,
        callType: callType,
        callId: callId,
      );
    }
  });
}



void _showIncomingCallPopup(BuildContext context, {String? patientName, String? callType, required String callId}) {
  // Créez une instance d'AudioPlayer
  final AudioPlayer audioPlayer = AudioPlayer();

  // Jouez la sonnerie lorsque le popup s'affiche
  audioPlayer.play(AssetSource('Witch-Doctor.mp3'));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 20, // Augmentez l'élévation pour une ombre plus prononcée
        backgroundColor: Colors.white,
        content: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8, // Largeur maximale
            maxHeight: MediaQuery.of(context).size.height * 0.6, // Hauteur maximale
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // La Column s'adapte à la taille de ses enfants
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône d'appel
              Icon(
                Icons.phone_in_talk,
                size: 80, // Taille plus grande
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              // Nom du patient
              Text(
                patientName ?? 'Patient inconnu',
                style: TextStyle(
                  fontSize: 28, // Taille de police plus grande
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900, // Couleur plus foncée
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              // Type d'appel
              Text(
                callType ?? 'Appel mobile',
                style: TextStyle(
                  fontSize: 20, // Taille de police plus grande
                  color: Colors.grey.shade700, // Couleur plus foncée
                ),
              ),
              SizedBox(height: 20),
              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.stop(); // Arrêtez la sonnerie
                        Navigator.of(context).pop();
                        _rejectCall(context, callId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Refuser'),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.stop(); // Arrêtez la sonnerie
                        Navigator.of(context).pop();
                        _acceptVideoCall(context, callId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Accepter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showIncomingCallPopupOne(BuildContext context, {String? patientName, String? callType, required String callId}) {
  // Créez une instance d'AudioPlayer
  final AudioPlayer audioPlayer = AudioPlayer();

  // Jouez la sonnerie lorsque le popup s'affiche
  audioPlayer.play(AssetSource('Witch-Doctor.mp3'));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 20, // Augmentez l'élévation pour une ombre plus prononcée
        backgroundColor: Colors.white,
        content: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8, // Largeur maximale
            maxHeight: MediaQuery.of(context).size.height * 0.6, // Hauteur maximale
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // La Column s'adapte à la taille de ses enfants
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône d'appel
              Icon(
                Icons.phone_in_talk,
                size: 80, // Taille plus grande
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              // Nom du patient
              Text(
                patientName ?? 'Patient inconnu',
                style: TextStyle(
                  fontSize: 28, // Taille de police plus grande
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900, // Couleur plus foncée
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              // Type d'appel
              Text(
                callType ?? 'Appel mobile',
                style: TextStyle(
                  fontSize: 20, // Taille de police plus grande
                  color: Colors.grey.shade700, // Couleur plus foncée
                ),
              ),
              SizedBox(height: 20),
              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.stop(); // Arrêtez la sonnerie
                        Navigator.of(context).pop();
                        _rejectCallOne(context, callId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Refuser'),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.stop(); // Arrêtez la sonnerie
                        Navigator.of(context).pop();
                        _acceptVideoCallOne(context, callId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Accepter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
    void _acceptVideoCall(BuildContext context, String callId) {
      // Mettre à jour le statut de l'appel dans Firestore
      final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
      _firestore.collection('callsAll').doc(callId).update({'status': 'accepted',
      'accepted_by': user.uid,
      });

      // Naviguer vers l'écran d'appel vidéo
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }

     void _rejectCall(BuildContext context, String callId) {
      // Mettre à jour le statut de l'appel dans Firestore
      _firestore.collection('callsAll').doc(callId).update({'status': 'rejected'});

      print("Call rejected.");
    }

    void _acceptVideoCallOne(BuildContext context, String callId) {
      // Mettre à jour le statut de l'appel dans Firestore
      _firestore.collection('callsOne').doc(callId).update({'status': 'accepted'});

      // Naviguer vers l'écran d'appel vidéo
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }

    void _rejectCallOne(BuildContext context, String callId) {
      // Mettre à jour le statut de l'appel dans Firestore
      _firestore.collection('callsOne').doc(callId).update({'status': 'rejected'});

      print("Call rejected.");
    }

   

    Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: CustomScrollView(
      slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Ahla Docteur !",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 114, 213, 255), // Couleur douce mais professionnelle
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: FadeIn(
                    duration: const Duration(milliseconds: 800),
                    child: const Icon(
                      Icons.medical_services,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            leading: Padding(
  padding: const EdgeInsets.only(left: 10),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      const SizedBox(width: 4), // Espace réduit entre l'icône et la photo
      Flexible(
        child: ClipOval(
          child: SizedBox(
            width: 60, // Taille réduite de l'image
            height: 40,
            child: Image.asset(
              'assets/portrait-smiling-handsome-male-doctor-man.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  ),
),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewDoctorProfilePage()),
                  );
                },
              ),
            ],
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 48, 221, 204),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                _buildAnimatedOptionCard(
                  context,
                  title: "Historique des Patients",
                  description: "Consultez les dossiers médicaux des patients.",
                  color: const Color.fromARGB(255, 110, 254, 115),
                  icon: Icons.history,
                  animateIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PatientHistoryPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildAnimatedOptionCard(
                  context,
                  title: "Créer une Prescription",
                  description: "Rédigez et envoyez des prescriptions en ligne.",
                  color: const Color.fromARGB(255, 255, 174, 0),
                  icon: Icons.assignment,
                  animateIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildAnimatedOptionCard(
                  context,
                  title: "Trace des validations pharmaceutiques",
                  description: "Voir les pharmacies ayant reçu vos prescriptions.",
                  color: Colors.deepPurpleAccent,
                  icon: Icons.local_pharmacy,
                  animateIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PharmacyListPages()),
              );
              },
              ),
                const SizedBox(height: 15),
               _buildAnimatedOptionCard(
                        context,
                        title: "Mon Portefeuille Médical", 
                        description: "Solde et transactions de votre compte professionnel",
                        color: Colors.pinkAccent,
                       // color: Colors.blueAccent,
                        icon: Icons.payment_rounded,
                        animateIcon: true,  // Ajout de l'animation comme dans l'autre carte
                        onTap: () async {
                          final playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=tn.mobipost&hl=fr");
                          
                          try {
                            if (await canLaunchUrl(playStoreUri)) {
                              await launchUrl(
                                playStoreUri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              await launchUrl(
                                Uri.parse("market://details?id=tn.mobipost"),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Impossible d'ouvrir l'application de paiement"),
                                behavior: SnackBarBehavior.floating,  // Style cohérent
                              ),
                            );
                          }
                        },
                      ),
                
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 28, 202, 255),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: const Text(
        "© 2025 Dawini - All Rights Reserved",
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget _buildAnimatedOptionCard(
  BuildContext context, {
  required String title,
    required String description,
    required Color color,
    required IconData icon,
    required bool animateIcon,
    required VoidCallback onTap,
}) {
 return SlideInUp(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: color.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                animateIcon
                    ? Bounce(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Icon(icon, color: color, size: 32),
                      )
                    : Icon(icon, color: color, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}