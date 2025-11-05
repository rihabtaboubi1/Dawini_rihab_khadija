import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Pour les animations

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final TextEditingController patientEmailController = TextEditingController();
  final TextEditingController prescriptionController = TextEditingController();
  late SimpleKeyPair keyPair;
  Uint8List? signature;

  @override
  void initState() {
    super.initState();
    generateAndStoreKeys();
  }

  String getDoctorEmail() {
    return FirebaseAuth.instance.currentUser?.email ?? "unknown@unknown.com";
  }

  Future<void> generateAndStoreKeys() async {
    final algorithm = Ed25519();
    keyPair = await algorithm.newKeyPair();
  }

  Future<void> signPrescription() async {
    final String prescriptionText = prescriptionController.text;
    if (prescriptionText.isNotEmpty) {
      final algorithm = Ed25519();
      final messageBytes = utf8.encode(prescriptionText);
      final signatureResult = await algorithm.sign(
        messageBytes,
        keyPair: keyPair,
      );

      setState(() {
        signature = signatureResult.bytes as Uint8List?;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prescription signée avec succès')),
      );
    }
  }

  void sendPrescription() async {
    final String patientEmail = patientEmailController.text;
    final String prescriptionText = prescriptionController.text;
    final String doctorEmail = getDoctorEmail();

    if (patientEmail.isNotEmpty && prescriptionText.isNotEmpty && signature != null) {
      final algorithm = Ed25519();
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBase64 = base64Encode(publicKey.bytes);

      FirebaseFirestore.instance.collection('prescriptions').add({
        'patientEmail': patientEmail,
        'doctorEmail': doctorEmail,
        'prescriptionText': prescriptionText,
        'signature': base64Encode(signature!),
        'publicKey': publicKeyBase64,
        'date': Timestamp.now(),
      });

      patientEmailController.clear();
      prescriptionController.clear();
      setState(() {
        signature = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prescription envoyée avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et signer la prescription')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Espace Ordonnances',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: TextField(
                controller: patientEmailController,
                decoration: InputDecoration(
                  labelText: 'Email du patient',
                  hintText: 'Entrez Email du patient',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: TextField(
                controller: prescriptionController,
                decoration: InputDecoration(
                  labelText: 'Prescription',
                  hintText: 'Entrez la prescription',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: signPrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 60, 184, 251),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5, // Ombre portée
                    ),
                    child: const Text('Signer', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: sendPrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 73, 241, 79),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5, // Ombre portée
                    ),
                    child: const Text('Envoyer', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}