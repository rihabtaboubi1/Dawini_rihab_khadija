import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otlobni/main.dart';
import 'package:otlobni/patientScreen.dart'; // Assurez-vous d'importer votre écran d'appel vidéo

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        title: const Text('Médecins Disponibles',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PatientScreen()),
      );
    },
  ),
        actions: [
          IconButton(
            icon: const Icon(Icons.broadcast_on_home, color: Colors.white,),
            iconSize: 35,
            tooltip: 'Appel groupé',
            onPressed: () =>  _startVideoCall(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('is_online', isEqualTo: true) // Filtrer les médecins en ligne
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun médecin disponible.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doctor = snapshot.data!.docs[index];
              return _buildDoctorCard(context, doctor);
            },
          );
        },
      ),
    );
  }

  // Méthode pour construire la carte d'un médecin
  Widget _buildDoctorCard(BuildContext context, QueryDocumentSnapshot doctor) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar et statut
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.green, size: 30),
            ),
            const SizedBox(width: 16),
            
            // Informations du médecin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['speciality'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        doctor['location'] ?? 'Non spécifiée',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton d'appel
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
              ),
              child: IconButton(
                icon: const Icon(Icons.video_call, color: Colors.blueAccent),
                onPressed: () => _callSpecificDoctor(context, doctor.id),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Méthode pour appeler un médecin spécifique
 void _callSpecificDoctor(BuildContext context, String doctorId) async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vous devez être connecté pour lancer un appel.')),
    );
    return;
  }

  // Vérifier si le patient a déjà un appel en cours
  final ongoingCall = await firestore.collection('callsOne')
      .where('patient_name', isEqualTo: user.uid)
      .where('status', isEqualTo: 'pending')
      .get();

  if (ongoingCall.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vous avez déjà un appel en attente.')),
    );
    return;
  }

  // Récupérer les informations du patient depuis Firestore
  final patientDoc = await firestore.collection('users').doc(user.uid).get();
  final patientName = patientDoc['name'] ?? 'Patient inconnu';

  // Enregistrer l'appel dans Firestore avec le nom du patient
  await firestore.collection('callsOne').add({
    'patient_id': user.uid,
    'call_type': 'video',
    'patient_name': patientName,
    'doctor_id': doctorId,
    'status': 'pending',
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Naviguer vers l'écran d'appel vidéo
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}

  // Méthode pour diffuser un appel à tous les médecins (logique actuelle)
   void _startVideoCall(BuildContext context) async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vous devez être connecté pour lancer un appel.')),
    );
    return;
  }

  // Vérifier si le patient a déjà un appel en cours
  final ongoingCall = await firestore.collection('callsAll')
      .where('patient_name', isEqualTo: user.uid)
      .where('status', isEqualTo: 'pending')
      .get();

  if (ongoingCall.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vous avez déjà un appel en attente.')),
    );
    return;
  }

  // Récupérer les informations du patient depuis Firestore
  final patientDoc = await firestore.collection('users').doc(user.uid).get();
  final patientName = patientDoc['name'] ?? 'Patient inconnu';
  
  

  // Enregistrer l'appel dans Firestore avec le nom du patient
  await firestore.collection('callsAll').add({
    'patient_name': patientName, // Nom dynamique du patient
    'call_type': 'video',
    'status': 'pending', // Statut initial de l'appel
    'timestamp': FieldValue.serverTimestamp(), // Horodatage automatique
    'accepted_by': null, // Aucun médecin n'a encore accepté l'appel
  });

  // Naviguer vers l'écran d'appel vidéo
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}
}