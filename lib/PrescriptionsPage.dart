import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otlobni/patientScreen.dart';

class PatientPrescriptionPage extends StatefulWidget {
  @override
  _PatientPrescriptionPageState createState() => _PatientPrescriptionPageState();
}

class _PatientPrescriptionPageState extends State<PatientPrescriptionPage> {
  String? patientEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
  }

  void getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        patientEmail = user.email;
      });
    }
  }

  void sendToPharmacist(DocumentSnapshot prescription, String pharmacistEmail) async {
    await FirebaseFirestore.instance.collection("prescriptions").doc(prescription.id).update({
      "pharmacistEmail": pharmacistEmail,
      "status": "envoyée"
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Prescription envoyée à $pharmacistEmail"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showPharmacistDialog(DocumentSnapshot prescription) {
    TextEditingController pharmacistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Envoyer au pharmacien",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: pharmacistController,
            decoration: InputDecoration(
              hintText: "Email du pharmacien",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (pharmacistController.text.isNotEmpty) {
                  sendToPharmacist(prescription, pharmacistController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Envoyer", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Prescriptions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PatientScreen()),
      );
    },
  ),
      ),
      body: patientEmail == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("prescriptions")
                  .where("patientEmail", isEqualTo: patientEmail)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucune prescription disponible",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var prescription = snapshot.data!.docs[index];
                    String signature = prescription["signature"] ?? "Signature non disponible";
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.medical_services, color: Colors.blueAccent, size: 40),
                        title: Text(
                          "Prescription reçue de ${prescription["doctorEmail"]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${prescription["prescriptionText"] ?? "Aucune description"}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Signature: $signature",
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () => showPharmacistDialog(prescription),
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