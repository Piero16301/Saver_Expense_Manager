# 🧹 Cloud Functions (Python) - Saver Expense Manager

This directory contains the **Python** Cloud Function (2nd gen) to handle **cascade deletion** of user data whenever an account is deleted in **Firebase Authentication**.

---

## 🎯 What does this function do?

When a user confirms account deletion in the Flutter app (via `user.delete()` in Firebase Auth) or an administrator deletes the account from the Firebase console:

1. **Automatic Trigger**: `@identity_fn.on_user_deleted` catches the deletion event from Firebase Auth.
2. **Cloud Storage Cleanup**:
   - Deletes all user files stored under `users/{uid}/attachments/` (photos, invoices, receipts, etc.).
   - Checks if any user movement references legacy/historical attachments stored outside this prefix and deletes them as well.
3. **Cloud Firestore Cleanup**:
   - Queries and deletes all documents in the `movements` collection where `user == uid` using Firestore batched writes (up to 400 documents per batch).
   - Deletes any profile document or subcollections in `users/{uid}` if present.
4. **Audit & Logging**:
   - Logs the exact count of deleted documents and files to Google Cloud Logging.

---

## 📁 Directory Structure

```text
functions/
├── main.py            # Cloud Function implementation and on_user_deleted trigger
├── requirements.txt   # Python dependencies (firebase-functions, firebase-admin)
├── .gitignore         # Ignored files for version control and deployment
└── README.md          # Usage and deployment guide
```

---

## ⚙️ Prerequisites

1. **Python 3.10, 3.11, or 3.12** installed on your system.
2. **Firebase CLI** installed and authenticated:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
3. Your Firebase project must be on the **Blaze (Pay as you go)** plan, as Cloud Functions requires access to Cloud Build and Artifact Registry on Google Cloud (includes a generous free monthly tier).

---

## 💻 Local Setup (Optional, for testing or development)

To work locally in this directory or test with the emulator:

```bash
# 1. Navigate to the functions directory
cd functions

# 2. Create a Python virtual environment
python3 -m venv venv

# 3. Activate the virtual environment
# On macOS / Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# 4. Install dependencies
pip install -r requirements.txt
```

---

## 🧪 Testing with Firebase Emulator Suite

You can test the function locally with the Firebase Emulator before deploying to production:

```bash
# From the project root
firebase emulators:start --only functions,auth,firestore,storage
```

---

## 🚀 Deployment to Firebase

To deploy the function to your Firebase project (`saver-expense-manager`):

```bash
# From the project root
firebase deploy --only functions
```

If you only want to deploy this specific function:

```bash
firebase deploy --only functions:cleanup_deleted_user_data
```

---

## 🔍 Monitoring & Production Logs

Once deployed, you can stream real-time logs with:

```bash
firebase functions:log
```

Or view them directly in the [Firebase Console](https://console.firebase.google.com/) under **Functions > Logs**.
