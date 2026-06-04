import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCFn_NuxBN8ccz8nWtttNtXrJa4oC3SviM",
  projectId: "civio-ba41e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function check() {
  const cols = ["procedures", "documents", "offices", "recentActivity", "analytics"];
  for (const c of cols) {
    try {
      const snap = await getDocs(collection(db, c));
      console.log(`Collection ${c}: ${snap.size} documents`);
    } catch (e) {
      console.error(`Collection ${c}: ERROR - ${e.message}`);
    }
  }
}

check();
