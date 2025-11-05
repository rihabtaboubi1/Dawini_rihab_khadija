import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Pour formater les dates

class PharmacyListPages extends StatefulWidget {
  const PharmacyListPages({Key? key}) : super(key: key);

  @override
  State<PharmacyListPages> createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPages> {
  List<Map<String, dynamic>> pharmacies = [];

  @override
  void initState() {
    super.initState();
    fetchPharmacies();
  }

  Future<void> fetchPharmacies() async {
    String? doctorEmail = FirebaseAuth.instance.currentUser?.email;
    if (doctorEmail == null) return;

    // Récupérer les prescriptions validées du médecin
    final prescriptionsSnapshot = await FirebaseFirestore.instance
        .collection("prescriptions")
        .where("doctorEmail", isEqualTo: doctorEmail)
        .where("status", isEqualTo: "validée")
        .get();

    // Extraire les emails des pharmaciens
    Set<String> pharmacistEmails = prescriptionsSnapshot.docs
        .map((doc) => doc['pharmacistEmail'] as String)
        .toSet();

    List<Map<String, dynamic>> pharmacyList = [];

    // Récupérer les infos des pharmacies
    for (String email in pharmacistEmails) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("pharmacists")
          .where("email", isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        pharmacyList.add(querySnapshot.docs.first.data());
      }
    }

    setState(() {
      pharmacies = pharmacyList;
    });
  }

  // Fonction pour formater la date
  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('d MMM yyyy à HH:mm:ss');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacies ayant validé"),
        backgroundColor: Colors.teal,
      ),
      body: pharmacies.isEmpty
          ? const Center(child: Text("Aucune pharmacie n’a validé vos prescriptions."))
          : ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                final pharmacyName = pharmacy['pharmacy_name'] ?? '';
                final address = pharmacy['address'] ?? '';
                final phone = pharmacy['phone'] ?? '';
                final email = pharmacy['email'] ?? '';

                // Extraction de la date de validation de la prescription
                final DateTime validatedDate = DateTime.parse("2025-03-20T15:03:21.000Z"); // Exemple de date de validation
                final formattedDate = formatDate(validatedDate);

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      pharmacyName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Adresse: $address",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Téléphone: $phone",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Validée le: $formattedDate",
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Email: $email",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
           ),
);
}
}

