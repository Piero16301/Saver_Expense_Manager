# 🧹 Cloud Functions (2nd Gen) - Saver Expense Manager

This directory contains the Firebase Cloud Function in **Node.js (2nd Generation, running on Cloud Run)** to handle **cascade deletion** of a user's account and all associated data.

---

## 🎯 What does this function do?

The `deleteUserAccount` function is a secure HTTPS endpoint (2nd Gen) that:

1. **Authentication**: Validates the caller's Firebase Authentication JWT ID token passed in the `Authorization: Bearer <idToken>` header.
2. **Cloud Storage Cleanup**:
   - Deletes all user files stored under `users/{uid}/` (photos, receipts, attachments).
   - Deletes any legacy attachments referenced by user movements stored outside that prefix.
3. **Cloud Firestore Cleanup**:
   - Queries and deletes all documents in `movements` where `user == uid` using Firestore batched writes (up to 400 documents per batch).
   - Recursively deletes user document/subcollections at `users/{uid}` if present.
4. **Firebase Authentication Deletion**:
   - Deletes the user record from Firebase Auth (`admin.auth().deleteUser(uid)`).
5. **Audit & Logging**:
   - Logs detailed summary and returns `{ success: true, deletedMovements, deletedFiles }`.

---

## 📁 Directory Structure

```text
functions/
├── index.js           # 2nd Gen HTTPS function implementation (deleteUserAccount)
├── package.json       # Node.js dependencies (firebase-admin, firebase-functions)
├── .gitignore         # Excludes node_modules and sensitive files
└── README.md          # Setup and deployment documentation
```

---

## ⚙️ Prerequisites & Setup

1. **Node.js** (v20 or v22) installed.
2. **Firebase CLI** installed and authenticated:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
3. Install dependencies:
   ```bash
   cd functions
   npm install
   ```

---

## 🚀 Deployment

### Option A: Using Google Cloud CLI (`gcloud`) - Recommended
Deploy directly specifying the build service account to bypass any default compute account restrictions:

```bash
gcloud functions deploy deleteUserAccount \
  --project=saver-expense-manager \
  --gen2 \
  --region=us-central1 \
  --runtime=nodejs22 \
  --source=./functions \
  --entry-point=deleteUserAccount \
  --trigger-http \
  --allow-unauthenticated \
  --service-account=saver-expense-manager@appspot.gserviceaccount.com \
  --build-service-account=projects/saver-expense-manager/serviceAccounts/saver-expense-manager@appspot.gserviceaccount.com
```

### Option B: Using Firebase CLI
> ⚠️ **Note**: Run from the **root directory** of the project (`Saver_Expense_Manager/`):

```bash
firebase deploy --only functions
```

---

## 🔍 Monitoring Logs

View function logs in real-time with:

```bash
firebase functions:log
```

Or view them directly in the [Firebase Console](https://console.firebase.google.com/) under **Functions > Logs**.
