import { initializeApp } from "firebase/app";
import { getFirestore, doc, setDoc, writeBatch } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCFn_NuxBN8ccz8nWtttNtXrJa4oC3SviM",
  projectId: "civio-ba41e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const now = new Date().toISOString();

const categories = [
  { id: "identite", name: "Identité", description: "CNI, passeports, cartes consulaires", icon: "id-card", color: "#10b981", order: 1 },
  { id: "voyage", name: "Voyage", description: "Visas, passeports, autorisations de sortie", icon: "plane", color: "#06b6d4", order: 2 },
  { id: "etat-civil", name: "État Civil", description: "Actes de naissance, mariage, décès", icon: "file-text", color: "#8b5cf6", order: 3 },
  { id: "entreprise", name: "Entreprise", description: "Création, statuts, formalités", icon: "briefcase", color: "#f59e0b", order: 4 },
  { id: "academique", name: "Académique", description: "Concours, bourses, inscriptions", icon: "graduation-cap", color: "#f43f5e", order: 5 },
  { id: "justice", name: "Justice", description: "Légalisations, procurations, recours", icon: "scale", color: "#3b82f6", order: 6 },
];

const regions = [
  { id: "adamaoua", name: "Adamaoua", capital: "Ngaoundéré", area_km2: 63691 },
  { id: "centre", name: "Centre", capital: "Yaoundé", area_km2: 68953 },
  { id: "est", name: "Est", capital: "Bertoua", area_km2: 109011 },
  { id: "extreme-nord", name: "Extrême-Nord", capital: "Maroua", area_km2: 34263 },
  { id: "littoral", name: "Littoral", capital: "Douala", area_km2: 20248 },
  { id: "nord", name: "Nord", capital: "Garoua", area_km2: 66090 },
  { id: "nord-ouest", name: "Nord-Ouest", capital: "Bamenda", area_km2: 17300 },
  { id: "ouest", name: "Ouest", capital: "Bafoussam", area_km2: 13892 },
  { id: "sud", name: "Sud", capital: "Ebolowa", area_km2: 47191 },
  { id: "sud-ouest", name: "Sud-Ouest", capital: "Buéa", area_km2: 25410 },
];

const cities = [
  { id: "douala", name: "Douala", region_id: "littoral", latitude: 4.0511, longitude: 9.7679 },
  { id: "yaounde", name: "Yaoundé", region_id: "centre", latitude: 3.8480, longitude: 11.5021 },
  { id: "garoua", name: "Garoua", region_id: "nord", latitude: 9.3014, longitude: 13.3928 },
  { id: "maroua", name: "Maroua", region_id: "extreme-nord", latitude: 10.5910, longitude: 14.3158 },
  { id: "ngaoundere", name: "Ngaoundéré", region_id: "adamaoua", latitude: 7.3167, longitude: 13.5833 },
  { id: "bertoua", name: "Bertoua", region_id: "est", latitude: 4.5774, longitude: 13.6846 },
  { id: "ebolowa", name: "Ebolowa", region_id: "sud", latitude: 2.9000, longitude: 11.1500 },
  { id: "bafoussam", name: "Bafoussam", region_id: "ouest", latitude: 5.4775, longitude: 10.4176 },
  { id: "bamenda", name: "Bamenda", region_id: "nord-ouest", latitude: 5.9597, longitude: 10.1493 },
  { id: "buea", name: "Buéa", region_id: "sud-ouest", latitude: 4.1550, longitude: 9.2310 },
];

const officeTypes = [
  { id: "cni", name: "Bureau d'enrôlement CNI", description: "Délivrance des cartes nationales d'identité" },
  { id: "passport", name: "Bureau de passeport", description: "Délivrance des passeports biométriques" },
  { id: "etat-civil", name: "Centre d'état civil", description: "Enregistrement des actes d'état civil" },
  { id: "tribunal", name: "Tribunal", description: "Légalisation, procurations, recours" },
  { id: "minesup", name: "Bureau MINESUP", description: "Bourses, équivalences de diplômes" },
  { id: "mairie", name: "Mairie", description: "Services municipaux, autorisations" },
];

const documentTypes = [
  { id: "demande-cni", name: "Demande de CNI", description: "Formulaire de demande de carte nationale d'identité", estimated_size_bytes: 102400 },
  { id: "demande-passeport", name: "Demande de Passeport", description: "Formulaire de demande de passeport biométrique", estimated_size_bytes: 102400 },
  { id: "acte-naissance", name: "Acte de Naissance", description: "Acte de naissance officiel", estimated_size_bytes: 81920 },
  { id: "statuts-sarl", name: "Statuts SARL", description: "Statuts de société à responsabilité limitée", estimated_size_bytes: 153600 },
  { id: "demande-bourse", name: "Demande de Bourse", description: "Dossier de demande de bourse", estimated_size_bytes: 122880 },
  { id: "lettre-motivation", name: "Lettre de Motivation", description: "Lettre de motivation académique ou professionnelle", estimated_size_bytes: 40960 },
  { id: "autorisation-parentale", name: "Autorisation Parentale", description: "Autorisation signée par un parent ou tuteur légal", estimated_size_bytes: 51200 },
  { id: "contestation-resultat", name: "Contestation de Résultat", description: "Lettre formelle de contestation de résultat académique", estimated_size_bytes: 61440 },
];

const systemConfig = {
  app_name: "CIVIO",
  app_tagline: "Vos démarches, simplifiées.",
  app_version: "1.0.0",
  contact_email: "support@civio.cm",
  support_phone: "+237 6 00 00 00 00",
  default_country_code: "+237",
  default_currency: "XAF",
  default_language: "fr",
  supported_languages: ["fr", "en"],
  encryption_standard: "AES-256",
  last_updated: now,
};

const adminPreferences = {
  sync_frequency: "daily",
  primary_language: "fr",
  enable_orbs: true,
  accent_color: "emerald",
  api_key_hash: null,
};

async function seed() {
  const batch = writeBatch(db);

  for (const c of categories) batch.set(doc(db, "categories", c.id), c);
  for (const r of regions) batch.set(doc(db, "regions", r.id), r);
  for (const c of cities) batch.set(doc(db, "cities", c.id), c);
  for (const o of officeTypes) batch.set(doc(db, "office_types", o.id), o);
  for (const d of documentTypes) batch.set(doc(db, "document_types", d.id), d);

  batch.set(doc(db, "system_config", "app"), systemConfig);
  batch.set(doc(db, "admin_preferences", "default"), adminPreferences);

  await batch.commit();
  console.log("Reference data seeded:");
  console.log(`  categories: ${categories.length}`);
  console.log(`  regions: ${regions.length}`);
  console.log(`  cities: ${cities.length}`);
  console.log(`  office_types: ${officeTypes.length}`);
  console.log(`  document_types: ${documentTypes.length}`);
  console.log(`  system_config: 1`);
  console.log(`  admin_preferences: 1`);
  console.log("\nUser data collections (procedures, citizens, documents, offices, activities, admin_users) are EMPTY — real users will populate them.");
  process.exit(0);
}

seed();
