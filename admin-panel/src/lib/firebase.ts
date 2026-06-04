import { initializeApp, getApps, getApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAnalytics, isSupported } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyCFn_NuxBN8ccz8nWtttNtXrJa4oC3SviM",
  authDomain: "civio-ba41e.firebaseapp.com",
  projectId: "civio-ba41e",
  storageBucket: "civio-ba41e.firebasestorage.app",
  messagingSenderId: "458071945684",
  appId: "1:458071945684:web:c5e9672048911c7e26e641",
  measurementId: "G-4HEDXXPREF"
};

const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
const db = getFirestore(app);

// Initialize Analytics safely for Next.js SSR
let analytics = null;
if (typeof window !== "undefined") {
  isSupported().then((yes) => yes && (analytics = getAnalytics(app)));
}

export { app, db, analytics };
