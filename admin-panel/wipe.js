import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, doc, deleteDoc, writeBatch } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCFn_NuxBN8ccz8nWtttNtXrJa4oC3SviM",
  projectId: "civio-ba41e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function wipeAll() {
  const cols = [
    "procedures", "citizens", "documents", "offices", "recentActivity",
    "documentTemplates", "admin_users", "categories", "regions", "cities",
    "office_types", "document_types", "activities", "system_config",
  ];
  for (const c of cols) {
    try {
      const snap = await getDocs(collection(db, c));
      if (snap.empty) {
        console.log(`${c}: empty`);
        continue;
      }
      const batch = writeBatch(db);
      for (const d of snap.docs) {
        const subs = await getDocs(collection(db, c, d.id, "steps"));
        subs.forEach((s) => batch.delete(s));
        const subDocs = await getDocs(collection(db, c, d.id, "required_documents"));
        subDocs.forEach((s) => batch.delete(s));
        const subQ = await getDocs(collection(db, c, d.id, "questions"));
        subQ.forEach((s) => batch.delete(s));
        const subL = await getDocs(collection(db, c, d.id, "locations"));
        subL.forEach((s) => batch.delete(s));
        const subCounters = await getDocs(collection(db, c, d.id, "counters"));
        subCounters.forEach((s) => batch.delete(s));
        batch.delete(d.ref);
      }
      await batch.commit();
      console.log(`${c}: deleted ${snap.size} top-level docs + subcollections`);
    } catch (e) {
      console.error(`${c}: ${e.message}`);
    }
  }
  const singletons = [
    "analytics/totals", "analytics/growth", "analytics/documents_per_month",
    "analytics/monthly_sync", "analytics/monthly_efficiency", "analytics/region_breakdown",
    "analytics/monthly_assistance", "analytics/daily_visits", "analytics/assistance_rate",
    "analytics/writing_needs", "analytics/stamp_savings", "analytics/user_stats",
    "analytics/platform_info", "analytics/admin_preferences", "analytics/stats",
    "analytics/efficiency",
  ];
  for (const s of singletons) {
    try {
      await deleteDoc(doc(db, s));
      console.log(`${s}: deleted`);
    } catch (e) {
      console.error(`${s}: ${e.message}`);
    }
  }
  process.exit(0);
}

wipeAll();
