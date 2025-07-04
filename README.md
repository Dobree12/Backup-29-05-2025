# TrackIT - Aplicație mobilă pentru organizarea antrenamentelor și exercițiilor de fitness

## Coordonator:
## Conf.dr.ing. Iosif Szeidert-Șubert
## Candidat: Paloti Dobre



Pentru a vedea ultima versiune si cea prezentata in documentatie, trebuie aleas branch-ul "update", nu main.
### link repository: https://github.com/Dobree12/TrackIT/tree/update

---

##  Cerințe de sistem

- Flutter SDK (recomandat: ultima versiune stabilă)  
- Android Studio sau VS Code cu extensii Flutter & Dart  
- Git  
- Emulator Android (configurat în Android Studio) sau dispozitiv fizic  
- Cont Firebase (pentru rulare completă cu backend)

---

##  Instalare

### 1. Clonează proiectul

```bash
git clone https://github.com/utilizator/trackit.git
cd trackit
```

### 2. Instalează dependențele

```bash
flutter pub get
```

### 3. Configurează Firebase

- Creează un proiect Firebase la [https://console.firebase.google.com](https://console.firebase.google.com)
- Activează Authentication (Email/Parolă)
- Activează Firestore Database
- Descarcă fișierul `google-services.json` și plasează-l în:

```
android/app/google-services.json
```


---

##  Rulare aplicație

### 1. Folosind emulatorul din Android Studio

- Deschide Android Studio
- Mergi la **Device Manager** (în partea dreaptă sus)
- Creează un **Virtual Device** (emulator) dacă nu ai deja unul
- Pornește emulatorul
- Rulează comanda:

```bash
flutter run
```


### 2. Folosind un dispozitiv fizic

- Activează opțiunile de dezvoltator și „USB Debugging” pe telefon
- Conectează telefonul la PC prin cablu USB
- Aprobă conexiunea de pe telefon
- Rulează:

```bash
flutter devices   # pentru a verifica dacă telefonul este detectat
flutter run
```

---


##  Structură proiect

- `lib/screens/` – ecranele aplicației
- `lib/models/` – modele de date (Workout, Exercise etc.)
- `lib/services/` – interacțiuni cu Firebase
- `lib/providers/` – gestionare stare (state management)

---
