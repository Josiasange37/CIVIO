const fs = require('fs');
let code = fs.readFileSync('/home/almight/ekema/admin-panel/src/app/page.tsx', 'utf8');

// Replace mock data imports with state variables inside the component
code = code.replace(/const lineData = \[\s*120,.*610\s*\];/s, "");
code = code.replace(/const barData = \[[^\]]*\];/s, "");
code = code.replace(/const recentActivity = \[[^\]]*\];/s, "");

// Replace the imports to include what we need
code = code.replace(
  `import { collection, getDocs } from "firebase/firestore";`,
  `import { collection, getDocs, doc, onSnapshot } from "firebase/firestore";`
);

const newComponentCode = `
export default function DashboardPage() {
  const [procedureCount, setProcedureCount] = useState<number>(0);
  const [lineData, setLineData] = useState<number[]>([]);
  const [barData, setBarData] = useState<any[]>([]);
  const [recentActivity, setRecentActivity] = useState<any[]>([]);
  const [totals, setTotals] = useState<any>({ usersTotal: "0", usersChange: "", docsTotal: "0", docsChange: "", successRate: "0%", successChange: "" });
  
  useEffect(() => {
    // lineData
    const unsubLine = onSnapshot(doc(db, "analytics", "growth"), (doc) => {
      if(doc.exists()) setLineData(doc.data().values || []);
    });
    // barData
    const unsubBar = onSnapshot(doc(db, "analytics", "documents_per_month"), (doc) => {
      if(doc.exists()) setBarData(doc.data().values || []);
    });
    // recentActivity
    const unsubActivity = onSnapshot(collection(db, "recentActivity"), (snap) => {
      setRecentActivity(snap.docs.map(d => ({id: d.id, ...d.data()})));
    });
    // totals
    const unsubTotals = onSnapshot(doc(db, "analytics", "totals"), (doc) => {
      if(doc.exists()) setTotals(doc.data());
    });
    // procedures count
    const unsubProcs = onSnapshot(collection(db, "procedures"), (snap) => {
      setProcedureCount(snap.size);
    });

    return () => { unsubLine(); unsubBar(); unsubActivity(); unsubProcs(); unsubTotals(); };
  }, []);
`;

code = code.replace(/export default function DashboardPage\(\) \{[\s\S]*?\}, \[\]\);/s, newComponentCode.trim());

// replace hardcoded stat cards values with state
code = code.replace(/value="12 847"/, 'value={totals.usersTotal}');
code = code.replace(/change="\+12\.5% ce mois"/, 'change={totals.usersChange}');

code = code.replace(/value="6 754"/, 'value={totals.docsTotal}');
code = code.replace(/change="\+22\.1% ce mois"/, 'change={totals.docsChange}');

code = code.replace(/value="94\.7%"/, 'value={totals.successRate}');
code = code.replace(/change="\+2\.3% ce mois"/, 'change={totals.successChange}');


fs.writeFileSync('/home/almight/ekema/admin-panel/src/app/page.tsx', code);
