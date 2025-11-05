const express = require('express');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const app = express();
const port = 3000;

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*'); // Autoriser toutes les origines
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
  });
// Remplacez ces valeurs par votre App ID et App Certificate d'Agora
const appId = "4bbc8ed835d246e89f04423a45fa8903"; // Votre App ID
const appCertificate = "abf877c2868847adb6122514cd703702"; // Votre App Certificate

// Vérifier que l'App ID et l'App Certificate sont définis
if (!appId || !appCertificate) {
  console.error("Erreur : L'App ID et l'App Certificate doivent être définis.");
  process.exit(1);
}

// Middleware pour parser le JSON
app.use(express.json());

// Endpoint pour générer un token
app.get('/token', (req, res) => {
    console.log("Requête reçue sur /token");
  console.log("Paramètres de la requête :", req.query);
  const channelName = req.query.channel || "channel1"; // Nom du canal (par défaut "channel1")
  const uid = req.query.uid || 0; // UID (par défaut 0)
  const role = RtcRole.PUBLISHER; // Rôle publisher
  const tokenExpirationInSecond = 3600; // Durée de validité du token (1 heure)
  const privilegeExpirationInSecond = 3600; // Durée de validité des permissions (1 heure)

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role,
      tokenExpirationInSecond,
      privilegeExpirationInSecond
    );
    
    res.json({ token }); // Retourne le token généré au format JSON
  } catch (error) {
    console.error("Erreur lors de la génération du token :", error);
    res.status(500).json({ error: "Erreur lors de la génération du token" });
  }
});

// Démarrer le serveur
app.listen(3000, '0.0.0.0', () => {
    console.log('Serveur en écoute sur le port 3000');
  });