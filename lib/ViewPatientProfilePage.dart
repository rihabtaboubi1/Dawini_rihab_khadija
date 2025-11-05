import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otlobni/EditPatientProfilePage.dart';
import 'package:otlobni/patientScreen.dart'; // Import de la page d'édition

class ViewPatientProfilePage extends StatelessWidget {
  final String patientEmail = "patient@example.com"; // Remplacez par l'email connecté

  Future<DocumentSnapshot> _fetchProfile() async {
    return FirebaseFirestore.instance.collection("patients").doc(patientEmail).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false, // Supprime la flèche de retour par défaut
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
            icon: const Icon(Icons.edit, color: Colors.white), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPatientProfilePage(patientEmail: patientEmail)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de récupération du profil", style: TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("Aucun profil trouvé", style: TextStyle(color: Colors.red)));
          }

          var patientData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.pinkAccent, // Fond rose
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white, // Icône blanche
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileInfoRow("Nom", patientData['name']),
                        const Divider(),
                        _buildProfileInfoRow("Email", patientData['email']),
                        const Divider(),
                        _buildProfileInfoRow("Téléphone", patientData['phone']),
                        const Divider(),
                        _buildProfileInfoRow("Adresse", patientData['address']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditPatientProfilePage(patientEmail: patientEmail)),
                    );
                  },
                  child: const Text("Modifier le profil"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}