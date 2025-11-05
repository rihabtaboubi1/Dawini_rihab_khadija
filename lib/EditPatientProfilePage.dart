import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:otlobni/ViewPatientProfilePage.dart'; // Pour les animations

class EditPatientProfilePage extends StatefulWidget {
  final String patientEmail;
  const EditPatientProfilePage({Key? key, required this.patientEmail}) : super(key: key);

  @override
  _EditPatientProfilePageState createState() => _EditPatientProfilePageState();
}

class _EditPatientProfilePageState extends State<EditPatientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String phone = "";
  String address = "";
  String email = ""; // Ajout de l'email

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  // Récupère les données du patient à partir de Firestore
  void _loadPatientData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("patients").doc(widget.patientEmail).get();
    if (doc.exists) {
      setState(() {
        name = doc["name"];
        phone = doc["phone"];
        address = doc["address"];
        email = doc["email"]; // Charger l'email depuis Firestore
      });
    }
  }

  // Mise à jour des données dans Firestore
  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection("patients").doc(widget.patientEmail).set({
        "name": name,
        "phone": phone,
        "address": address,
        "email": email, // Enregistrer l'email dans Firestore
      }, SetOptions(merge: true)) // Fusionne avec les données existantes
      .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil mis à jour")));
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : ${error.toString()}")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modifier Profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ViewPatientProfilePage()),
      );
    },
  ),
        backgroundColor: Colors.blueAccent,
        elevation: 5, // Ajout d'une légère ombre pour un effet professionnel
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.1), Colors.lightBlue.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texte d'en-tête
                  FadeInDown(
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      "Modifiez les informations de votre profil patient! 😊",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent, // Texte sombre pour la lisibilité
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Champs du formulaire
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    child: _buildTextField("Nom", name, (value) => name = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: _buildTextField("Téléphone", phone, (value) => phone = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 800),
                    child: _buildTextField("Email", email, (value) => email = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 900),
                    child: _buildTextField("Adresse", address, (value) => address = value!),
                  ),

                  SizedBox(height: 20),

                  // Bouton de sauvegarde
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Couleur moderne et professionnelle
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Coins arrondis
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          elevation: 5, // Ombre légère pour le bouton
                        ),
                        child: Text("Enregistrer", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.blueAccent, // Accent professionnel
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Coins arrondis
            borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
        validator: (value) => value!.isEmpty ? "Veuillez entrer $label" : null,
        onChanged: onChanged,
      ),
    );
  }
}