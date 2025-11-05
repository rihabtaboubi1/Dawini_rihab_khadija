import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String? selectedRole;

  void signUp() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Veuillez choisir un rôle")));
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "email": emailController.text.trim(),
        "name": nameController.text.trim(),
        "role": selectedRole,
      });

      Navigator.pushReplacementNamed(context, "/login"); // Retourner à la page login après l'inscription
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de l'inscription : ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Inscription",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
      SizedBox(height: 20),
      TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: "Email",
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 15),
      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Mot de passe",
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 15),
      TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: "Nom complet",
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 15),
      DropdownButtonFormField<String>(
        value: selectedRole,
        hint: Text("Choisissez un rôle"),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: ["Patient"].map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: (value) => setState(() => selectedRole = value),
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("S'inscrire", style: TextStyle(fontSize: 18)),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: Text(
          "Déjà un compte ? Se connecter",
          style: TextStyle(color: Colors.blue.shade900),
        ),
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
