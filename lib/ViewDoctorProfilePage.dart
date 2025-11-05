import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otlobni/doctorScreen.dart';
import 'edit_doctor_profile.dart'; // Import de la page d'édition

class ViewDoctorProfilePage extends StatefulWidget {
  @override
  _ViewDoctorProfilePageState createState() => _ViewDoctorProfilePageState();
}

class _ViewDoctorProfilePageState extends State<ViewDoctorProfilePage> {
  String? doctorId;
  String _name = "Chargement...";
  String _speciality = "Chargement...";
  String _phone = "Chargement...";
  String _email = "Chargement...";
  String _location = "Chargement...";

  @override
  void initState() {
    super.initState();
    doctorId = FirebaseAuth.instance.currentUser?.uid; // 🔥 Récupération de l'ID Firebase Auth
    if (doctorId != null) {
      _getDoctorProfile();
    }
  }

  Future<void> _getDoctorProfile() async {
    if (doctorId == null) return;

    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          _name = doctorDoc['name'] ?? "Non défini";
          _speciality = doctorDoc['speciality'] ?? "Non défini";
          _phone = doctorDoc['phone'] ?? "Non défini";
          _email = doctorDoc['email'] ?? "Non défini";
          _location = doctorDoc['location'] ?? "Non défini";
        });
      } else {
        setState(() {
          _name = "Profil non trouvé";
        });
      }
    } catch (e) {
      setState(() {
        _name = "Erreur de chargement";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil du Docteur",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorScreen()),
      );
    },
  ),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false, // Supprime la flèche de retour par défaut
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              if (doctorId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDoctorProfilePage(doctorId: doctorId!),
                  ),
                ).then((_) => _getDoctorProfile()); // Rafraîchir après édition
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur : ID du médecin introuvable")),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar circulaire avec un effet de bordure
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 70,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            _buildProfileInfo("Nom", _name),
            _buildProfileInfo("Spécialité", _speciality),
            _buildProfileInfo("Téléphone", _phone),
            _buildProfileInfo("Email", _email),
            _buildProfileInfo("Ville", _location),
            SizedBox(height: 20),
            // Bouton de modification avec un style moderne
            ElevatedButton(
              onPressed: () {
                if (doctorId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDoctorProfilePage(doctorId: doctorId!),
                    ),
                  ).then((_) => _getDoctorProfile()); // Rafraîchir après édition
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : ID du médecin introuvable")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                shadowColor: Colors.blueAccent.withOpacity(0.3),
              ),
              child: Text(
                "Modifier le Profil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              "$label : ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}