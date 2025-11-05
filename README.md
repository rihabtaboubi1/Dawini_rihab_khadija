# Dawini_rihab_khadija  
**Telemedicine Mobile App**  

# 🩺 Dawini — Telemedicine Mobile App

**Dawini** is an **intelligent telemedicine mobile application** that allows patients to consult a doctor online via **video call** or through a **medical chatbot**.  
The app facilitates communication between patients, doctors, and pharmacists through a secure **prescription and validation system**.

---

## 👩‍💻 Development Team
- **Rihab Taboubi**  
- **Khadija Saidi**
## 📚 Supervision
Project carried out **under the supervision of Mr. Hamza Hammami**.


## 🚀 Project Objective
The main goal of **Dawini** is to provide **fast, convenient, and safe access to medical care**, reducing unnecessary travel while ensuring the **confidentiality** of interactions between patients and healthcare professionals.  

---

## ⚙️ Technologies Used

### 🖥️ Front-end
- **Flutter** — cross-platform mobile development

### 🧠 Back-end
- **Node.js** — API management, business logic, and secure token generation for each call session  
- **Agora** — real-time video conferencing  
- **Botpress** — intelligent medical chatbot

### ☁️ Database & Cloud Services
- **Firebase Firestore** — real-time database  
- **Firebase Authentication** — user management  
- **Firebase Cloud Messaging** — push notifications  

### 🔒 Security
- **Digital Signature (DSA)** — securing and validating electronic prescriptions

---

## 🧭 User Flow

### 👩‍⚕️ Step 1 — Choosing the Consultation Mode
The **patient** has two options:  
1. **Intelligent Chatbot (Botpress):** for quick, automated assistance.  
2. **Consultation with a real doctor (Agora):** for a video consultation.

### 📞 Step 2 — Connecting with a Doctor
If the patient chooses a doctor consultation, they have two options:  
- **Broadcast a call** to **all connected doctors**: the session starts as soon as a doctor responds.  
- **Select a specific doctor** from the list of online practitioners.

When the call is launched:  
- The **doctor** receives a **popup notification** showing the **patient's name**.  
- They can **accept or decline** the consultation request.  
- A **secure video session** starts if accepted.

### 💊 Step 3 — Prescription and Validation
At the end of the consultation:  
- The **doctor writes a digital prescription**, **signs it electronically (DSA)**, and sends it to the patient.  
- The **patient** can then **forward the prescription to the pharmacist**, who **validates** it directly through the app.

---

## 📱 Key Features
- 👨‍⚕️ Live video consultation with a doctor  
- 🤖 Intelligent medical chatbot for quick consultations  
- 🏥 Dynamic selection of connected doctors  
- 📲 Real-time notifications  
- 💊 Signed and secure electronic prescriptions  
- 🔐 Firebase authentication  
- ☁️ Cloud storage and synchronization of medical data

---

## 🧩 System Architecture
**Dawini** is based on a **client-server architecture connected to the cloud**:  
- Flutter mobile app (patient & doctor interface)  
- Node.js server (business logic & API management)  
- Third-party services: **Agora**, **Botpress**, **Firebase**
## 📸 Screenshots

![WelcomePage](assets/1.png)
![AboutUsPage](assets/2.png)



