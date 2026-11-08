# 🧹 Storage Cleanup & Migration Script

This module contains the Node.js script to inspect Saver Expense Manager's **Firebase Storage** bucket, detect and safely delete orphaned files, and migrate historical root files into the secure multi-tenant structure (`users/{userId}/attachments/{fileName}`).

---

## 🚀 Requirements & Installation

1. Ensure **Node.js** (v18+) is installed.
2. Navigate to this directory and install dependencies:
   ```bash
   cd storage_cleanup
   npm install
   ```

---

## 🔑 Firebase Credentials

The script automatically searches for credentials in any of the following locations:

* `storage_cleanup/service-account.json` (or `service-account.json` in the project root).
* The `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
* An active Google Cloud CLI session:
  ```bash
  gcloud auth application-default login
  ```

*(Note: `service-account*.json` files and `node_modules/` are excluded in `.gitignore` to prevent committing sensitive keys to the repository).*

---

## 🛠️ Available Commands

From the `storage_cleanup` folder:

### 1. Dry Run (Simulation)
Inspects Firestore and Storage, counts movements, identifies linked files, and lists orphaned files without deleting or modifying anything:
```bash
npm run clean
```

### 2. Delete Orphaned Files
Permanently deletes all files in Storage that are not linked to any Firestore movement:
```bash
npm run clean:delete
```

### 3. Migrate Historical Root Files
Moves existing valid files from the root of the bucket into `users/{userId}/attachments/{fileName}` and automatically updates the `attachments` arrays in Firestore:
```bash
npm run clean:migrate
```

### 4. Full Cleanup and Migration
Runs both orphaned file deletion and valid file migration in a single run:
```bash
npm run clean:all
```
