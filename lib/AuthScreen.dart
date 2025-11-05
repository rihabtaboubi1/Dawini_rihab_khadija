/*import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:otlobni/pharmacistScreen.dart';

import 'patientScreen.dart';
import 'doctorScreen.dart';



class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController specialCodeController = TextEditingController(); // Pour médecins et admins

  final String appName = "Dawini";
  String? selectedRole; // Stocke le rôle sélectionné

  final List<String> roles = ["Patient", "Doctor", "Pharmacist"];

  void navigateToRoleScreen() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un rôle."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Widget nextScreen;
    switch (selectedRole) {
      case "Patient":
        nextScreen = const PatientScreen();
        break;
      case "Doctor":
        nextScreen = const DoctorScreen();
        break;
      case "Pharmacist":
        nextScreen = PharmacistPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animation du nom de l'application
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      appName,
                      speed: const Duration(milliseconds: 200),
                      textStyle: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 1000),
                ),
                const SizedBox(height: 10),

                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/portrait-smiling-handsome-male-doctor-man.jpg',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),

                // Choix du rôle
                const Text(
                  "Sélectionnez votre rôle",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  hint: const Text("Choisir un rôle"),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Champs dynamiques selon le rôle sélectionné
                if (selectedRole != null) ...[
                  // Email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mot de passe
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Champ spécifique pour les médecins et admins
                  if (selectedRole == "Doctor" || selectedRole == "Pharmacist") ...[
                    TextField(
                      controller: specialCodeController,
                      decoration: InputDecoration(
                        labelText: "Code spécial",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        prefixIcon: const Icon(Icons.security),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Bouton de connexion
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: navigateToRoleScreen,
                    child: const Text("Se connecter", style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 10),

                  // Lien vers l'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PatientScreen()),
                          );
                        },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
