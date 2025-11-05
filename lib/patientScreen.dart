import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:otlobni/AboutUsPage.dart';
import 'package:otlobni/AuthScreen.dart';
import 'package:otlobni/PharmacyListPage.dart';
import 'package:otlobni/PrescriptionsPage.dart';
import 'package:otlobni/ViewPatientProfilePage.dart';
import 'package:otlobni/login_screen.dart';
import 'package:otlobni/DoctorListScreen.dart';
import 'package:otlobni/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Utilisez cloud_firestore

class PatientScreen extends StatelessWidget {
  const PatientScreen({Key? key}) : super(key: key);

  // Fonction pour lancer un appel vidéo
  void _startVideoCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
  backgroundColor: Colors.blueAccent,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    },
  ),
  title: Row(
    children: [
      ClipOval(
        child: Image.asset(
          'assets/portrait-smiling-handsome-male-doctor-man.jpg',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 10),
      Expanded( // Utilisez Expanded pour éviter le débordement
        child: Text(
          '     Ahla Patient !',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis, // Ajoutez cette ligne pour gérer le débordement
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.person, color: Colors.white),
      iconSize: 35, // Icône profil
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewPatientProfilePage()),
        );
      },
    ),
  ],
),
      
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: SizedBox(
                      height: 50,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            "❤️🏥 \"Votre compagnon santé, où que vous soyez !\" 🩺❤️",
                            speed: const Duration(milliseconds: 100),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                        totalRepeatCount: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedOptionCard(
                    context,
                    title: "🤖 Chatbot médical",
                    description: "Posez vos questions de santé à notre IA !",
                    color: Colors.green,
                    icon: Icons.smart_toy,
                    animateIcon: true,
                    onTap: () async {
                      final Uri url = Uri.parse(
                        "https://cdn.botpress.cloud/webchat/v2.3/shareable.html?configUrl=https://files.bpcontent.cloud/2024/11/28/13/20241128133447-EP0NGSA8.json"
                      );
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        throw "Impossible d'ouvrir le lien $url";
                      }
                    },
                  ),
                  _buildAnimatedOptionCard(
                    context,
                    title: "📹 Appel vidéo avec un médecin",
                    description: "Parlez à un médecin en direct !",
                    color: Colors.blue,
                    icon: Icons.videocam_rounded,
                    animateIcon: true,
                    onTap: () => _startVideoCall(context), // Appeler la fonction ici
                  ),
                  _buildAnimatedOptionCard(
                    context,
                    title: "📄 Mes ordonnances",
                    description: "Consultez et téléchargez vos ordonnances !",
                    color: Colors.orange,
                    icon: Icons.description,
                    animateIcon: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PatientPrescriptionPage()),
                      );
                    },
                  ),
                  _buildAnimatedOptionCard(
  context,
  title: "🏥 Liste des pharmacies",
  description: "Trouvez une pharmacie près de chez vous !",
  color: Colors.purple,
  icon: Icons.local_pharmacy,
  animateIcon: true,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PharmacyListPage()),
    );
  },
),
                ],
              ),
            ),
          ),

          

          Container(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
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
        ],
      ),
    );
  }

  // Méthode pour créer une carte avec animation
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