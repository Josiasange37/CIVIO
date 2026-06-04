import { initializeApp } from "firebase/app";
import { getFirestore, doc, setDoc, collection, addDoc, getDocs, deleteDoc } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCFn_NuxBN8ccz8nWtttNtXrJa4oC3SviM",
  projectId: "civio-ba41e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const mockProcedures = [
  {
    title: "Carte Nationale d'Identité",
    category: "Identité",
    cost: "2 800 FCFA",
    timeline: "3 mois",
    difficulty: "Moyen",
    successRate: "92%",
    status: "active",
    stepsCount: 4,
    views: 2840,
  },
  {
    title: "Passeport Biométrique",
    category: "Voyage",
    cost: "110 000 FCFA",
    timeline: "48h",
    difficulty: "Moyen",
    successRate: "98%",
    status: "active",
    stepsCount: 5,
    views: 1681,
  },
  {
    title: "Acte de Naissance",
    category: "État Civil",
    cost: "Gratuit",
    timeline: "1 semaine",
    difficulty: "Facile",
    successRate: "95%",
    status: "completed",
    stepsCount: 2,
    views: 924,
  },
  {
    title: "Création SARL",
    category: "Entreprise",
    cost: "41 500 FCFA",
    timeline: "72h",
    difficulty: "Difficile",
    successRate: "88%",
    status: "pending",
    stepsCount: 6,
    views: 1345,
  },
  {
    title: "Demande de Bourse MINESUP",
    category: "Académique",
    cost: "Gratuit",
    timeline: "2 mois",
    difficulty: "Moyen",
    successRate: "75%",
    status: "active",
    stepsCount: 4,
    views: 1891,
  },
  {
    title: "Concours ENS Yaoundé",
    category: "Académique",
    cost: "15 000 FCFA",
    timeline: "1 mois",
    difficulty: "Difficile",
    successRate: "82%",
    status: "active",
    stepsCount: 4,
    views: 1000,
  },
];


const mockOffices = [
  {
    name: "Commissariat CNI - DGSN Yaoundé Centre",
    city: "Yaoundé",
    region: "Centre",
    address: "Avenue Nachtigal, près de la préfecture du Mfoundi",
    hours: "Lun - Ven: 07h30 - 15h30",
    phone: "+237 222 22 22 22",
    status: "busy",
    activeCounters: 8,
    avgWaitTime: "45 min",
  },
  {
    name: "Hôtel de Ville de Douala 1er",
    city: "Douala",
    region: "Littoral",
    address: "Bonanjo, Rue de la Marine",
    hours: "Lun - Ven: 08h00 - 15h00",
    phone: "+237 233 42 43 44",
    status: "open",
    activeCounters: 5,
    avgWaitTime: "15 min",
  },
  {
    name: "Bureau d'Émigration / Immigration Garoua",
    city: "Garoua",
    region: "Nord",
    address: "Quartier Administratif Garoua",
    hours: "Lun - Ven: 07h30 - 15h30",
    phone: "+237 222 27 10 11",
    status: "open",
    activeCounters: 4,
    avgWaitTime: "10 min",
  },
  {
    name: "Sous-Préfecture de Bafoussam I",
    city: "Bafoussam",
    region: "Ouest",
    address: "Face Monument de la Paix",
    hours: "Lun - Ven: 08h00 - 16h00",
    phone: "+237 233 44 12 13",
    status: "closed",
    activeCounters: 0,
    avgWaitTime: "0 min",
  },
  {
    name: "Commissariat Central de Maroua",
    city: "Maroua",
    region: "Extrême-Nord",
    address: "Route Nationale 1, Quartier Lopéré",
    hours: "Lun - Ven: 07h30 - 15h30",
    phone: "+237 222 29 14 15",
    status: "open",
    activeCounters: 6,
    avgWaitTime: "25 min",
  },
];

const mockDocLogs = [
  {
    citizenName: "Marie Ngono",
    docType: "Demande de bourse MINESUP",
    dateGenerated: "Aujourd'hui, 09:03",
    validationCode: "CIVIO-8392-CM",
    size: "142 KB",
    status: "active",
  },
  {
    citizenName: "Jean-Pierre Tabi",
    docType: "Lettre de contestation au Doyen",
    dateGenerated: "Aujourd'hui, 08:44",
    validationCode: "CIVIO-1249-YA",
    size: "98 KB",
    status: "active",
  },
  {
    citizenName: "Amadou Bouba",
    docType: "Formulaire Fiche CNI",
    dateGenerated: "Hier, 17:15",
    validationCode: "CIVIO-9912-MA",
    size: "244 KB",
    status: "completed",
  },
  {
    citizenName: "Florence Atangana",
    docType: "Demande d'autorisation parentale",
    dateGenerated: "02 Juin 2026",
    validationCode: "CIVIO-7231-YA",
    size: "87 KB",
    status: "completed",
  },
  {
    citizenName: "Paul Ekambi",
    docType: "Statuts SARL Unipersonnelle",
    dateGenerated: "31 Mai 2026",
    validationCode: "CIVIO-4509-DO",
    size: "512 KB",
    status: "completed",
  },
];

const mockRecentActivity = [
  {
    user: "Amadou Bouba",
    action: "A consulté la procédure",
    target: "Carte Nationale d'Identité",
    status: "completed",
    time: "Il y a 2 min",
  },
  {
    user: "Marie Ngono",
    action: "A généré un document",
    target: "Demande de bourse MINESUP",
    status: "active",
    time: "Il y a 5 min",
  },
  {
    user: "Paul Ekambi",
    action: "A démarré la procédure",
    target: "Création SARL",
    status: "pending",
    time: "Il y a 12 min",
  },
  {
    user: "Fatou Diallo",
    action: "A consulté la procédure",
    target: "Passeport Biométrique",
    status: "completed",
    time: "Il y a 18 min",
  },
  {
    user: "Jean-Pierre Tabi",
    action: "A généré un document",
    target: "Lettre au Doyen",
    status: "active",
    time: "Il y a 25 min",
  },
  {
    user: "Aïssatou Moussa",
    action: "A consulté la procédure",
    target: "Concours ENS Yaoundé",
    status: "completed",
    time: "Il y a 32 min",
  },
];

const analyticsDocs = [
  {
    id: "growth",
    values: [120, 180, 150, 280, 220, 340, 310, 420, 380, 520, 490, 610]
  },
  {
    id: "documents_per_month",
    values: [
      { label: "Jan", value: 45 },
      { label: "Fév", value: 62 },
      { label: "Mar", value: 78 },
      { label: "Avr", value: 91 },
      { label: "Mai", value: 84 },
      { label: "Juin", value: 110 },
      { label: "Juil", value: 95 },
      { label: "Août", value: 125 },
    ]
  },
  {
    id: "totals",
    usersTotal: "12 847",
    usersChange: "+12.5% ce mois",
    docsTotal: "6 754",
    docsChange: "+22.1% ce mois",
    successRate: "94.7%",
    successChange: "+2.3% ce mois"
  },
  {
    id: "monthly_sync",
    values: [320, 410, 390, 580, 690, 710, 890, 950, 1100, 1050, 1300, 1420]
  },
  {
    id: "region_breakdown",
    values: [
      { label: "Centre", value: 450 },
      { label: "Littoral", value: 380 },
      { label: "Extrême-Nord", value: 240 },
      { label: "Nord", value: 180 },
      { label: "Adamaoua", value: 120 },
      { label: "Ouest", value: 310 },
      { label: "Sud", value: 90 },
      { label: "Est", value: 70 },
    ]
  },
  {
    id: "stats",
    dailyVisits: "1 425",
    dailyVisitsChange: "92% sur mobile Android",
    assistanceRate: "86.4%",
    assistanceRateChange: "Procédures consultées sans internet",
    writingNeeds: "6 754",
    writingNeedsChange: "Lettres générées avec succès",
    stampSavings: "~4,5M FCFA",
    stampSavingsChange: "Économisés par les citoyens"
  },
  {
    id: "efficiency",
    cniDelay: { title: "Délai Moyen d'Établissement CNI", badge: "-45% temps", desc: "Grâce aux instructions interactives, le citoyen prépare un dossier complet sans erreurs au premier passage." },
    offlineUse: { title: "Utilisation Hors-Ligne Locale", badge: "100% autonome", desc: "Zéro dépendance réseau. Les guides de procédures de la CNI, du Passeport et des concours restent accessibles dans les zones reculées." },
    docValidation: { title: "Validation Documentaire", badge: "Anti-fraude", desc: "Chaque document possède une empreinte unique limitant les falsifications de diplômes ou de requêtes officielles." }
  }
];

const mockTemplates = [
  { title: "Demande de Bourse Universitaire", desc: "Format officiel conforme aux exigences du MINESUP.", count: "2 841 générés" },
  { title: "Statuts SARL / SAS", desc: "Création d'entreprise simplifiée au greffe du tribunal.", count: "1 245 générés" },
  { title: "Lettre de réclamation administrative", desc: "Modèle générique de saisine pour tout ministère.", count: "891 générés" },
  { title: "Demande d'autorisation de bâtir", desc: "Dossier préliminaire pour les communes d'arrondissement.", count: "453 générés" }
];

const mockCitizens = [
  { name: "Amadou Bouba", region: "Extrême-Nord (Maroua)", joinedDate: "12 Mai 2026", lastActive: "Il y a 2 min", completedProcedures: 3, status: "active", avatarColor: "#10b981" },
  { name: "Marie Ngono", region: "Centre (Yaoundé)", joinedDate: "18 Mai 2026", lastActive: "Il y a 5 min", completedProcedures: 1, status: "active", avatarColor: "#8b5cf6" },
  { name: "Paul Ekambi", region: "Littoral (Douala)", joinedDate: "02 Avr 2026", lastActive: "Il y a 12 min", completedProcedures: 5, status: "active", avatarColor: "#06b6d4" },
  { name: "Fatou Diallo", region: "Adamaoua (Ngaoundéré)", joinedDate: "20 Avr 2026", lastActive: "Il y a 18 min", completedProcedures: 2, status: "inactive", avatarColor: "#f59e0b" },
  { name: "Jean-Pierre Tabi", region: "Sud (Ebolowa)", joinedDate: "01 Juin 2026", lastActive: "Il y a 25 min", completedProcedures: 0, status: "active", avatarColor: "#f43f5e" },
  { name: "Aïssatou Moussa", region: "Nord (Garoua)", joinedDate: "10 Mai 2026", lastActive: "Il y a 32 min", completedProcedures: 4, status: "inactive", avatarColor: "#3b82f6" },
  { name: "Samuel Eto'o Mbappé", region: "Littoral (Douala)", joinedDate: "29 Mai 2026", lastActive: "Il y a 1 heure", completedProcedures: 2, status: "active", avatarColor: "#10b981" },
  { name: "Florence Atangana", region: "Centre (Yaoundé)", joinedDate: "04 Mai 2026", lastActive: "Il y a 2 heures", completedProcedures: 7, status: "active", avatarColor: "#8b5cf6" },
];

async function seedCollection(colName, dataArr) {
  const colRef = collection(db, colName);
  const existing = await getDocs(colRef);
  
  console.log(`Clearing existing documents in ${colName}...`);
  for (const doc of existing.docs) {
    await deleteDoc(doc.ref);
  }
  
  console.log(`Seeding ${colName}...`);
  for (const item of dataArr) {
    await addDoc(colRef, item);
  }
}

async function seedAnalytics() {
  const colRef = collection(db, "analytics");
  console.log(`Seeding analytics...`);
  for (const item of analyticsDocs) {
    const dRef = doc(db, "analytics", item.id);
    await setDoc(dRef, item);
  }
}

async function runSeeder() {
  try {
    await seedCollection("procedures", mockProcedures);
    await seedCollection("offices", mockOffices);
    await seedCollection("documents", mockDocLogs);
    await seedCollection("recentActivity", mockRecentActivity);
    await seedCollection("documentTemplates", mockTemplates);
    await seedCollection("citizens", mockCitizens);
    // Seed user_stats
    await setDoc(doc(db, "analytics", "user_stats"), {
      registered: "12 847",
      registeredChange: "+1 240 cette semaine",
      activeToday: "2 451",
      activeTodayChange: "+8% d'augmentation",
      offlineSessions: "78.2%",
      offlineSessionsChange: "Assistance locale complète"
    });
    await seedAnalytics();
    console.log("Database successfully seeded!");
    process.exit(0);
  } catch (error) {
    console.error("Seeding failed: ", error);
    process.exit(1);
  }
}

runSeeder();
