import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otlobni/PasswordForgotScreen.dart';
import 'package:otlobni/WelcomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  bool obscureText = true;
  bool isLoading = false;

  Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "token": token,
        "lastLogin": FieldValue.serverTimestamp(),
      });
      print("✅ Token sauvegardé avec succès dans Firestore");
    } catch (e) {
      print("❌ Erreur de sauvegarde du token dans Firestore : $e");
    }
  }

  void signIn() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Veuillez choisir un rôle")));
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken != null) {
        await saveTokenToFirestore(userCredential.user!.uid, firebaseToken);

        DocumentSnapshot userDoc = 
            await _firestore.collection("users").doc(userCredential.user!.uid).get();
            
        if (userDoc.exists) {
          String role = userDoc["role"];
          
          switch (role) {
            case "Patient":
              Navigator.pushReplacementNamed(context, "/patientHome");
              break;
            case "Médecin":
              Navigator.pushReplacementNamed(context, "/doctorHome");
              break;
            case "Pharmacien":
              Navigator.pushReplacementNamed(context, "/pharmacistHome");
              break;
            default:
              throw Exception("Rôle non reconnu");
          }
        } else {
          throw Exception("Document utilisateur non trouvé");
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Échec de la connexion";
      if (e.code == 'user-not-found') {
        errorMessage = "Aucun utilisateur trouvé avec cet email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Mot de passe incorrect";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  WelcomePage()),
          ),
        ),
        title: const Text("Connexion"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Connexion",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        hint: const Text("Choisissez un rôle"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: ["Patient", "Médecin", "Pharmacien"].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedRole = value),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() => obscureText = !obscureText);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Se connecter", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Solution pour le débordement - Utilisation de Wrap ou de colonnes
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/signup");
                            },
                            child: Text(
                              "Créer un compte",
                              style: TextStyle(color: Colors.blue.shade900),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  ResetPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}