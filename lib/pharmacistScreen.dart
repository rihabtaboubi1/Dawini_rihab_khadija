import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cryptography/cryptography.dart';
import 'package:otlobni/PharmacistSpacePage.dart';
import 'ValidatedPrescriptionsPage.dart';  // Import de la page des prescriptions validées

class PharmacistPage extends StatefulWidget {
  @override
  _PharmacistPageState createState() => _PharmacistPageState();
}

class _PharmacistPageState extends State<PharmacistPage> {
  String? pharmacistEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
  }

  void getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        pharmacistEmail = user.email;
      });
    }
  }

  // 🔑 Récupère la clé publique directement depuis la prescription
  Future<SimplePublicKey?> getPublicKeyFromPrescription(String prescriptionId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('prescriptions')
          .doc(prescriptionId)
          .get();

      if (doc.exists) {
        String publicKeyBase64 = doc['publicKey'];
        Uint8List publicKeyBytes = base64Decode(publicKeyBase64);
        return SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
      }
    } catch (e) {
      print("Erreur lors de la récupération de la clé publique depuis la prescription : $e");
    }
    return null;
  }

  // ✅ Vérifie la signature numérique
  Future<bool> verifySignature(String prescriptionId, String prescriptionText, String signatureBase64) async {
    try {
      SimplePublicKey? publicKey = await getPublicKeyFromPrescription(prescriptionId);
      if (publicKey == null) {
        print("Clé publique introuvable");
        return false;
      }

      Uint8List messageBytes = Uint8List.fromList(utf8.encode(prescriptionText));
      Uint8List signatureBytes = base64Decode(signatureBase64);

      final algorithm = Ed25519();
      return await algorithm.verify(
        messageBytes,
        signature: Signature(signatureBytes, publicKey: publicKey),
      );
    } catch (e) {
      print("Erreur de vérification de la signature : $e");
      return false;
    }
  }

  // 📥 Mise à jour du champ validateBy avec l'email du pharmacien
  Future<void> updateValidateByField(String prescriptionId) async {
    if (pharmacistEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection("prescriptions")
            .doc(prescriptionId)
            .update({"validateBy": pharmacistEmail}); // Ajout de l'email du pharmacien
      } catch (e) {
        print("Erreur lors de la mise à jour du champ validateBy : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prescriptions reçues", style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)), backgroundColor: Colors.blue,
      leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  PharmacistSpacePage()),
      );
    },
  ),),
      
      body: pharmacistEmail == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Redirection vers la page des prescriptions validées
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ValidatedPrescriptionsPage()),
                    );
                  },
                  child: Text("Voir prescriptions validées"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("prescriptions")
                        .where("status", isEqualTo: "envoyée") // Filtrer par statut "envoyée"
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("Aucune prescription reçue"));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var prescription = snapshot.data!.docs[index];
                          bool isValid = prescription["status"] == "validée"; // Vérifie si la prescription est validée
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 3,
                            child: ListTile(
                              leading: Icon(Icons.medical_services, color: Colors.blue),
                              title: Text("Prescription de patient ${prescription["patientEmail"]} et de docteur ${prescription["doctorEmail"]}"),
                              subtitle: Text(
                                "${prescription["prescriptionText"]}\n\nSignature: ${prescription["signature"]}",
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: isValid
                                  ? Icon(Icons.check_circle, color: Colors.green) // Icône de validation si la prescription est validée
                                  : ElevatedButton(
                                      onPressed: () async {
                                        bool isValid = await verifySignature(
                                          prescription.id, // Passe l'ID de la prescription pour récupérer la clé publique
                                          prescription["prescriptionText"],
                                          prescription["signature"],
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isValid ? "Signature VALIDE ✅" : "Signature INVALIDE ❌",
                                            ),
                                            backgroundColor: isValid ? Colors.green : Colors.red,
                                          ),
                                        );

                                        if (isValid) {
                                          // Mise à jour du statut de la prescription sans la supprimer
                                          await FirebaseFirestore.instance
                                              .collection("prescriptions")
                                              .doc(prescription.id)
                                              .update({"status": "validée"}); // Change le statut en "validée"
                                          
                                          // Mise à jour du champ validateBy avec l'email du pharmacien
                                          await updateValidateByField(prescription.id);
                                        }
                                      },
                                      child: Text("Vérifier"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
