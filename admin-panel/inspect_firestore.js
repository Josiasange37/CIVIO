import { initializeApp } from 'firebase/app';
import { getFirestore, doc, getDoc, collection, getDocs, query, limit } from 'firebase/firestore';
import { config } from './src/lib/firebase.ts';

const app = initializeApp(config);
const db = getFirestore(app);

(async () => {
  console.log('--- analytics/totals ---');
  const totals = await getDoc(doc(db, 'analytics', 'totals'));
  console.log(JSON.stringify(totals.data(), null, 2));
  
  console.log('--- analytics/growth ---');
  const growth = await getDoc(doc(db, 'analytics', 'growth'));
  console.log(JSON.stringify(growth.data(), null, 2));
  
  console.log('--- analytics/documents_per_month ---');
  const dpm = await getDoc(doc(db, 'analytics', 'documents_per_month'));
  console.log(JSON.stringify(dpm.data(), null, 2));
  
  console.log('--- recentActivity[0] ---');
  const act = await getDocs(query(collection(db, 'recentActivity'), limit(1)));
  act.forEach(d => console.log(d.id, JSON.stringify(d.data(), null, 2)));
  
  console.log('--- procedures[0] ---');
  const procs = await getDocs(query(collection(db, 'procedures'), limit(1)));
  procs.forEach(d => console.log(d.id, JSON.stringify(d.data(), null, 2)));
  
  console.log('--- documents[0] ---');
  const docs = await getDocs(query(collection(db, 'documents'), limit(1)));
  docs.forEach(d => console.log(d.id, JSON.stringify(d.data(), null, 2)));
  
  console.log('--- citizens[0] ---');
  const citizens = await getDocs(query(collection(db, 'citizens'), limit(2)));
  citizens.forEach(d => console.log(d.id, JSON.stringify(d.data(), null, 2)));
  
  process.exit(0);
})();
