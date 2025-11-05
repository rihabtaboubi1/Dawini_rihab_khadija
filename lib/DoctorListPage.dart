import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otlobni/PharmacistSpacePage.dart';

class DoctorsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annuaire Médical',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  PharmacistSpacePage()),
      );
    },
  ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, 
                      color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined,
                      size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun médecin disponible',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doctor = snapshot.data!.docs[index];
              return _DoctorCard(doctor: doctor);
            },
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DocumentSnapshot doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final name = doctor['name'] as String? ?? 'Nom inconnu';
    final speciality = doctor['speciality'] as String? ?? 'Spécialité non spécifiée';
    final phone = doctor['phone'] as String? ?? 'Non spécifié';
    final email = doctor['email'] as String? ?? 'Non spécifié';
    final location = doctor['location'] as String? ?? 'Non spécifié';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDoctorDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, 
                    color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. $name',
                      style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      speciality,
                      style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, phone),
                    _buildInfoRow(Icons.email, email),
                    _buildInfoRow(Icons.location_on, location),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, 
                  color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  color: const Color.fromARGB(255, 26, 25, 25), 
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(BuildContext context) {
  final name = doctor['name'] as String? ?? 'Nom inconnu';
  final speciality = doctor['speciality'] as String? ?? 'Spécialité non spécifiée';
  final phone = doctor['phone'] as String? ?? 'Non spécifié';
  final email = doctor['email'] as String? ?? 'Non spécifié';
  final location = doctor['location'] as String? ?? 'Non spécifié';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar du médecin
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 50),
            ),
            const SizedBox(height: 10),

            // Nom du médecin
            Text(
              'Dr. $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),

            // Spécialité
            Text(
              speciality,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(thickness: 1, height: 25, color: Colors.grey),

            // Informations détaillées
            _buildDetailRow(Icons.phone, "Téléphone", phone),
            _buildDetailRow(Icons.email, "Email", email),
            _buildDetailRow(Icons.location_on, "Adresse", location),

            const SizedBox(height: 20),

            // Bouton de fermeture stylisé
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Widget amélioré pour afficher les détails avec un titre et une icône
Widget _buildDetailRow(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 22, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 45, 44, 44),
            ),
          ),
        ),
      ],
    ),
  );
}
}