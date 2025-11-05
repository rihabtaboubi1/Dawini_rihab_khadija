import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:otlobni/ViewDoctorProfilePage.dart'; // Pour les animations

class EditDoctorProfilePage extends StatefulWidget {
  final String doctorId; // Ajout de l'ID du docteur

  EditDoctorProfilePage({required this.doctorId});

  @override
  _EditDoctorProfilePageState createState() => _EditDoctorProfilePageState();
}

class _EditDoctorProfilePageState extends State<EditDoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _speciality = "";
  String _phone = "";
  String _email = "";
  String _location = "";

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    if (doctorDoc.exists) {
      setState(() {
        _name = doctorDoc['name'] ?? "";
        _speciality = doctorDoc['speciality'] ?? "";
        _phone = doctorDoc['phone'] ?? "";
        _email = doctorDoc['email'] ?? "";
        _location = doctorDoc['location'] ?? "";
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DocumentReference doctorRef = FirebaseFirestore.instance.collection('doctors').doc(widget.doctorId);
      DocumentSnapshot docSnapshot = await doctorRef.get();

      if (!docSnapshot.exists) {
        // Si le profil n'existe pas, on le crée
        await doctorRef.set({
          'name': _name,
          'speciality': _speciality,
          'phone': _phone,
          'email': _email,
          'location': _location,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profil créé avec succès !")),
          );
          Navigator.pop(context);
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de création : $error")),
          );
        });
      } else {
        // Si le profil existe, on le met à jour
        await doctorRef.update({
          'name': _name,
          'speciality': _speciality,
          'phone': _phone,
          'email': _email,
          'location': _location,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profil mis à jour avec succès !")),
          );
          Navigator.pop(context);
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de mise à jour : $error")),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, // Couleur moderne
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ViewDoctorProfilePage()),
      );
    },
  ),
        title: Text(
          "Modifier le Profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
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
          padding: EdgeInsets.all(20.0),
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
                      "Modifiez les informations de votre profil docteur! 😊 ",
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
                    child: _buildTextField("Nom", _name, (value) => _name = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: _buildTextField("Spécialité", _speciality, (value) => _speciality = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 800),
                    child: _buildTextField("Téléphone", _phone, (value) => _phone = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 900),
                    child: _buildTextField("Email", _email, (value) => _email = value!),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: _buildTextField("Ville", _location, (value) => _location = value!),
                  ),

                  SizedBox(height: 20),

                  // Bouton de sauvegarde
                  FadeInUp(
                    duration: Duration(milliseconds: 1100),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Couleur moderne et professionnelle
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Coins arrondis
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          elevation: 5, // Ombre légère pour le bouton
                        ),
                        child: Text("Sauvegarder", style: TextStyle(color: Colors.white)),
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

  Widget _buildTextField(String label, String initialValue, Function(String?) onSaved) {
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
        onSaved: onSaved,
      ),
    );
  }
}