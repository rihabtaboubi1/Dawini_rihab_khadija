import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otlobni/patientScreen.dart';

class PharmacyListPage extends StatefulWidget {
  const PharmacyListPage({Key? key}) : super(key: key);

  @override
  _PharmacyListPageState createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text("Liste des pharmacies",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PharmacySearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('pharmacists').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune pharmacie trouvée."));
          }

          // Filtrer les résultats selon la recherche
          var filteredPharmacies = snapshot.data!.docs.where((pharmacy) {
            String pharmacyName = pharmacy['pharmacy_name']?.toLowerCase() ?? '';
            String address = pharmacy['address']?.toLowerCase() ?? '';
            return pharmacyName.contains(searchQuery.toLowerCase()) ||
                address.contains(searchQuery.toLowerCase());
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredPharmacies.length,
            itemBuilder: (context, index) {
              var pharmacy = filteredPharmacies[index];

              String pharmacyName = pharmacy['pharmacy_name'] ?? 'Nom inconnu';
              String pharmacistName = pharmacy['name'] ?? 'Pharmacien inconnu';
              String address = pharmacy['address'] ?? 'Adresse inconnue';
              String email = pharmacy['email'] ?? 'Email inconnu';
              String phone = pharmacy['phone'] ?? 'Téléphone inconnu';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.local_pharmacy, color: Colors.blue, size: 40),
                  title: Text(
                    pharmacyName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pharmacien : $pharmacistName"),
                      Text("Adresse : $address"),
                      Text("Email : $email"),
                      Text("Téléphone : $phone"),
                    ],
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

class PharmacySearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => "Rechercher une pharmacie...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('pharmacists').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var results = snapshot.data!.docs.where((pharmacy) {
          String pharmacyName = pharmacy['pharmacy_name']?.toLowerCase() ?? '';
          String address = pharmacy['address']?.toLowerCase() ?? '';
          return pharmacyName.contains(query.toLowerCase()) ||
              address.contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var pharmacy = results[index];
            return ListTile(
              title: Text(pharmacy['pharmacy_name']),
              subtitle: Text(pharmacy['address']),
              onTap: () {
                close(context, pharmacy['pharmacy_name']);
              },
            );
          },
        );
      },
    );
  }
}
