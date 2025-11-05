import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otlobni/pharmacistScreen.dart';

class ValidatedPrescriptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupérer l'email du pharmacien actuel
    String pharmacistEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text("Prescriptions validées", style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)), backgroundColor: Colors.blue,
                leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  PharmacistPage()),
      );
    },
  ),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("prescriptions")
            .where("status", isEqualTo: "validée") // Filtrer les prescriptions validées
            .where("validateBy", isEqualTo: pharmacistEmail) // Filtrer par l'email du pharmacien
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucune prescription validée par ce pharmacien"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var prescription = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.blue),
                  title: Text("Prescription validée de patient ${prescription["patientEmail"]}"),
                  subtitle: Text(
                    "${prescription["prescriptionText"]}\n\nSignature: ${prescription["signature"]}",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
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
