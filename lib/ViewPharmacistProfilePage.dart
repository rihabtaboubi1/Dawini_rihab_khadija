import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // N'oubliez pas d'importer Firebase Auth
import 'package:otlobni/EditPharmacistProfilePage.dart';
import 'package:otlobni/PharmacistSpacePage.dart';

class ViewPharmacistProfilePage extends StatefulWidget {
  @override
  _ViewPharmacistProfilePageState createState() => _ViewPharmacistProfilePageState();
}

class _ViewPharmacistProfilePageState extends State<ViewPharmacistProfilePage> {
  // Récupère l'email de l'utilisateur connecté
  final String pharmacistEmail = FirebaseAuth.instance.currentUser?.email ?? "";

  Future<DocumentSnapshot> _fetchProfile() async {
    try {
      // Récupère le document correspondant à l'email du pharmacien dans Firestore
      var snapshot = await FirebaseFirestore.instance.collection("pharmacists").doc(pharmacistEmail).get();
      if (!snapshot.exists) {
        print("Aucun document trouvé pour l'email: $pharmacistEmail");
      }
      return snapshot;
    } catch (e) {
      print("Erreur lors de la récupération du profil: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mon Profil",
          style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          
        ),
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  PharmacistSpacePage()),
      );
    },
  ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Supprime la flèche de retour par défaut
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),  // Icône de modification
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPharmacistProfilePage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur de récupération du profil",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text(
                "Aucun profil trouvé",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          var pharmacistData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar circulaire avec un effet de bordure
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                _buildProfileInfo("Nom", pharmacistData['name'] ?? "Non défini"),
                _buildProfileInfo("Email", pharmacistData['email'] ?? "Non défini"),
                _buildProfileInfo("Téléphone", pharmacistData['phone'] ?? "Non défini"),
                _buildProfileInfo("Nom de la pharmacie", pharmacistData['pharmacy_name'] ?? "Non défini"),
                _buildProfileInfo("Adresse", pharmacistData['address'] ?? "Non défini"),
                SizedBox(height: 20),
                // Bouton de modification avec un style moderne
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditPharmacistProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                  child: Text(
                    "Modifier le Profil",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
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
                color: Colors.blue,
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