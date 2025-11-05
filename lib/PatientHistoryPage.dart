import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart'; // Pour les animations

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({Key? key}) : super(key: key);

  @override
  _PatientHistoryPageState createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? doctorId; // ID du médecin

  @override
  void initState() {
    super.initState();
    // Récupérer l'ID du médecin connecté via Firebase Auth
    _getDoctorId();
  }

  // Fonction pour récupérer l'ID du médecin connecté
  void _getDoctorId() async {
    User? user = FirebaseAuth.instance.currentUser; // Récupérer l'utilisateur connecté
    if (user != null) {
      setState(() {
        doctorId = user.uid; // L'ID du médecin est l'ID de l'utilisateur connecté
      });
    } else {
      print("Aucun utilisateur connecté.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historique des Patients",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 10, // Ombre portée
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: doctorId == null // Si l'ID du médecin n'est pas encore récupéré
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('callsAll')
                  .where('accepted_by', isEqualTo: doctorId) // Filtrer sur le médecin
                  .where('call_type', isEqualTo: 'video') // Filtrer pour appels vidéo
                  .where('status', isEqualTo: 'accepted') // Filtrer pour appels acceptés
                  .orderBy('timestamp', descending: true) // Trier par date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Erreur Firestore: ${snapshot.error}");
                  return const Center(child: Text("Erreur de chargement des données"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun appel vidéo trouvé"));
                }

                var callHistory = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: callHistory.length,
                  itemBuilder: (context, index) {
                    var call = callHistory[index].data() as Map<String, dynamic>;

                    String patientName = call['patient_name'] ?? "Patient inconnu";
                    String callStatus = call['status'] ?? "Inconnu";

                    DateTime callDate;
                    if (call['timestamp'] is Timestamp) {
                      callDate = (call['timestamp'] as Timestamp).toDate();
                    } else if (call['timestamp'] is int) {
                      callDate = DateTime.fromMillisecondsSinceEpoch(call['timestamp']);
                    } else {
                      callDate = DateTime.now(); // Valeur par défaut si mal formaté
                    }

                    return FadeInUp(
                      duration: Duration(milliseconds: 200 * index), // Animation progressive
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 5, // Ombre portée
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Bordures arrondies
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          title: Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          subtitle: Text(
                            "Statut: $callStatus\nDate: ${callDate.toLocal()}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}