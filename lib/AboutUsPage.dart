import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: FadeIn(
          duration: Duration(milliseconds: 500),
          child: Text(
            "À propos de nous",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo avec animation
            FadeInDown(
              duration: Duration(milliseconds: 600),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/portrait-smiling-handsome-male-doctor-man.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Titre principal
            FadeIn(
              delay: Duration(milliseconds: 300),
              child: Text(
                "Découvrez Dawini",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Carte d'information
            FadeInUp(
              delay: Duration(milliseconds: 400),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Notre mission est de révolutionner les soins de santé en Tunisie en connectant patients, médecins et pharmaciens sur une plateforme sécurisée et facile à utiliser.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    Divider(),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Consultations en ligne avec des médecins certifiés",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.medication, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Prescriptions numériques sécurisées",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Gestion simplifiée des rendez-vous",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Section pour professionnels
            FadeInUp(
              delay: Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueAccent.withOpacity(0.8),
                      Colors.blue[800]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Professionnels de santé",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Rejoignez notre réseau de professionnels de santé et bénéficiez d'outils modernes pour gérer votre pratique médicale.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      );
    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        ),
                        child: Text(
                          "Nous contacter",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Section contact
            FadeInUp(
              delay: Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    "Contactez-nous",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 15),
                  InkWell(
  onTap: () async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: "dawinidoctor@gmail.com",
      // Optionnel : Ajouter un sujet et un corps
      query: 'subject=Demande de rendez-vous&body=Bonjour,', // encodage automatique des espaces
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucune application email trouvée")),
      );
    }
  },
  child: ContactCard(
    icon: Icons.email,
    title: "Email",
    value: "dawinidoctor@gmail.com",
  ),
),
                  SizedBox(height: 10),
                  InkWell(
  onTap: () async {
    final Uri telUri = Uri(scheme: 'tel', path: "+21622061630"); // Supprimez les espaces
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir l'application d'appel")),
      );
    }
  },
  child: ContactCard(
    icon: Icons.phone,
    title: "Téléphone",
    value: "+216 99 999 999",
  ),
),
                  SizedBox(height: 10),
                  ContactCard(
                    icon: Icons.location_on,
                    title: "Adresse",
                    value: "Tunis, Tunisie",
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Bouton retour
            FadeInUp(
              delay: Duration(milliseconds: 700),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text(
                  "Retour à l'accueil",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueAccent),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}