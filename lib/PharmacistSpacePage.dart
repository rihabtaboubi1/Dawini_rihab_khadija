import 'package:flutter/material.dart';
import 'package:otlobni/DoctorListPage.dart';
import 'package:otlobni/ViewPharmacistProfilePage.dart';

import 'package:otlobni/pharmacistScreen.dart';
import 'package:otlobni/EditPharmacistProfilePage.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacistSpacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Ahla Pharmacien !",
                style: TextStyle(
                  fontSize: 19.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 5, 218, 115), // Couleur douce mais professionnelle
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: FadeIn(
                    duration: const Duration(milliseconds: 800),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            leading: Padding(
  padding: const EdgeInsets.only(left: 10),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      const SizedBox(width: 4), // Espace réduit entre l'icône et la photo
      Flexible(
        child: ClipOval(
          child: SizedBox(
            width: 60, // Taille réduite de l'image
            height: 40,
            child: Image.asset(
              'assets/portrait-smiling-handsome-male-doctor-man.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  ),
),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewPharmacistProfilePage()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: const Text(
                      "",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _buildAnimatedOptionCard(
                  context,
                  title: "Voir la liste des Docteurs",
                    description: "Accédez à la liste des docteurs disponibles.",

                  color: const Color.fromARGB(255, 110, 254, 115),
                  icon: Icons.medical_services,
                  animateIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorsListPage()),
                    );
                  },
                ),
                  const SizedBox(height: 15),
                  _buildAnimatedOptionCard(
                  context,
                  title: "Voir les Prescriptions",
                    description: "Consultez les prescriptions des patients.",

                  color: const Color.fromARGB(255, 255, 174, 0),
                  icon: Icons.assignment,
                  animateIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PharmacistPage()),
                    );
                  },
                ),
                  const SizedBox(height: 15),
              _buildAnimatedOptionCard(
                        context,
                       title: "Payer le docteur", // Correction orthographique
                       description: "Accédez à l'application de paiement",
                        color: Colors.pinkAccent,
                       // color: Colors.blueAccent,
                        icon: Icons.payment_rounded,
                        animateIcon: true,  // Ajout de l'animation comme dans l'autre carte
                        onTap: () async {
                          final playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=tn.mobipost&hl=fr");
                          
                          try {
                            if (await canLaunchUrl(playStoreUri)) {
                              await launchUrl(
                                playStoreUri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              await launchUrl(
                                Uri.parse("market://details?id=tn.mobipost"),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Impossible d'ouvrir l'application de paiement"),
                                behavior: SnackBarBehavior.floating,  // Style cohérent
                              ),
                            );
                          }
                        },
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
        
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 171, 134),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: const Text(
          "© 2025 Dawini - All Rights Reserved",
          style: TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAnimatedOptionCard(
  BuildContext context, {
  required String title,
    required String description,
    required Color color,
    required IconData icon,
    required bool animateIcon,
    required VoidCallback onTap,
}) {
 return SlideInUp(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: color.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                animateIcon
                    ? Bounce(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Icon(icon, color: color, size: 32),
                      )
                    : Icon(icon, color: color, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}