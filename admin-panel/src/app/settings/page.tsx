"use client";

import React, { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { doc, onSnapshot, setDoc, getDoc, collection, getCountFromServer } from "firebase/firestore";

interface PlatformInfo {
  clientVersion: string;
  dbVersion: string;
  lastSync: string;
  encryption: string;
  apiKeyPreview: string;
}

export default function SettingsPage() {
  const [syncFreq, setSyncFreq] = useState("daily");
  const [primaryLang, setPrimaryLang] = useState("fr");
  const [enableOrbs, setEnableOrbs] = useState(true);
  const [accentColor, setAccentColor] = useState("emerald");
  const [apiKey, setApiKey] = useState("");
  const [platformInfo, setPlatformInfo] = useState<PlatformInfo>({
    clientVersion: "—",
    dbVersion: "—",
    lastSync: "—",
    encryption: "Actif (AES-256)",
    apiKeyPreview: ""
  });

  useEffect(() => {
    const unsubPrefs = onSnapshot(doc(db, "analytics", "admin_preferences"), (docSnap) => {
      if (docSnap.exists()) {
        const d = docSnap.data();
        setSyncFreq(d.syncFreq || "daily");
        setPrimaryLang(d.primaryLang || "fr");
        setEnableOrbs(d.enableOrbs !== false);
        setAccentColor(d.accentColor || "emerald");
        setApiKey(d.apiKey || "");
      }
    });

    const unsubInfo = onSnapshot(doc(db, "analytics", "platform_info"), (docSnap) => {
      if (docSnap.exists()) {
        setPlatformInfo(docSnap.data() as PlatformInfo);
      }
    });

    const seedPlatformInfo = async () => {
      try {
        const ref = doc(db, "analytics", "platform_info");
        const snap = await getDoc(ref);
        if (snap.exists()) return;

        const [procSnap, docSnap, citSnap] = await Promise.all([
          getCountFromServer(collection(db, "procedures")),
          getCountFromServer(collection(db, "documents")),
          getCountFromServer(collection(db, "citizens")),
        ]);
        const totalRecords = procSnap.data().count + docSnap.data().count + citSnap.data().count;

        const seeded: PlatformInfo = {
          clientVersion: "1.0.0",
          dbVersion: `Firestore v${totalRecords}`,
          lastSync: new Date().toLocaleString("fr-FR", {
            day: "2-digit", month: "long", year: "numeric",
            hour: "2-digit", minute: "2-digit",
          }),
          encryption: "Actif (AES-256)",
          apiKeyPreview: "••••••••civio-ba41e",
        };
        await setDoc(ref, seeded);
      } catch (e) {
        console.error("Error seeding platform_info:", e);
      }
    };
    seedPlatformInfo();

    return () => {
      unsubPrefs();
      unsubInfo();
    };
  }, []);

  const savePreference = async (key: string, value: any) => {
    try {
      await setDoc(doc(db, "analytics", "admin_preferences"), { [key]: value }, { merge: true });
    } catch (e) {
      console.error("Error saving preference:", e);
    }
  };

  return (
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Paramètres de la Plateforme</h1>
          <p className="page-subtitle">
            Configurez les options système de Civio, la base de connaissances et les préférences visuelles.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 stagger">
        <div className="flex flex-col gap-6">
          <div className="chart-container p-6">
            <h2 className="text-headline-md font-bold text-accent-cyan mb-4 font-headline">
              Base de Données et Synchronisation
            </h2>

            <div className="flex flex-col gap-4">
              <div>
                <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                  Fréquence des mises à jour des procédures
                </label>
                <select
                  value={syncFreq}
                  onChange={(e) => {
                    setSyncFreq(e.target.value);
                    savePreference("syncFreq", e.target.value);
                  }}
                  className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
                >
                  <option value="hourly">Toutes les heures</option>
                  <option value="daily">Quotidiennement (Recommandé)</option>
                  <option value="weekly">Hebdomadairement</option>
                  <option value="manual">Manuel uniquement</option>
                </select>
              </div>

              <div>
                <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                  Langue principale d&apos;assistance
                </label>
                <select
                  value={primaryLang}
                  onChange={(e) => {
                    setPrimaryLang(e.target.value);
                    savePreference("primaryLang", e.target.value);
                  }}
                  className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
                >
                  <option value="fr">Français (Cameroun)</option>
                  <option value="en">English (Cameroon)</option>
                  <option value="bilingual">Bilingue (Français/English)</option>
                </select>
              </div>
            </div>
          </div>

          <div className="chart-container p-6">
            <h2 className="text-headline-md font-bold text-accent-purple mb-4 font-headline">
              Sécurité et Clés d&apos;API
            </h2>

            <div className="flex flex-col gap-4">
              <div>
                <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                  Clé d&apos;API OpenRouter (Dialogue intelligent facultatif)
                </label>
                <input
                  type="password"
                  value={apiKey}
                  onChange={(e) => {
                    setApiKey(e.target.value);
                    savePreference("apiKey", e.target.value);
                  }}
                  className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
                />
              </div>

              <div className="flex justify-between items-center pt-2.5">
                <div>
                  <span className="font-semibold block text-body-md">Chiffrement Local</span>
                  <span className="text-body-sm text-on-surface-variant">Chiffrer l&apos;historique des citoyens</span>
                </div>
                <span className="text-[11px] font-bold text-accent-emerald bg-accent-emerald-glow px-2.5 py-1 rounded-2xl">
                  {platformInfo.encryption}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="flex flex-col gap-6">
          <div className="chart-container p-6">
            <h2 className="text-headline-md font-bold text-accent-emerald mb-4 font-headline">
              Design et Effets
            </h2>

            <div className="flex flex-col gap-5">
              <div className="flex justify-between items-center">
                <div>
                  <span className="font-semibold block text-body-md">Sphères Lumineuses Flottantes</span>
                  <span className="text-body-sm text-on-surface-variant">Activer l&apos;arrière-plan dynamique</span>
                </div>
                <button
                  onClick={() => {
                    setEnableOrbs(!enableOrbs);
                    savePreference("enableOrbs", !enableOrbs);
                  }}
                  className="btn-glass text-body-sm"
                >
                  {enableOrbs ? "Activé" : "Désactivé"}
                </button>
              </div>

              <div>
                <label className="font-label-md text-label-md text-on-surface-variant block mb-2.5">
                  Couleur d&apos;accentuation principale
                </label>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                  {[
                    { id: "emerald", color: "#10b981", label: "Émeraude" },
                    { id: "cyan", color: "#06b6d4", label: "Cyan" },
                    { id: "purple", color: "#8b5cf6", label: "Violet" },
                    { id: "amber", color: "#f59e0b", label: "Ambre" },
                  ].map((item) => (
                    <button
                      key={item.id}
                      onClick={() => {
                        setAccentColor(item.id);
                        savePreference("accentColor", item.id);
                      }}
                      className="btn-glass text-body-sm"
                    >
                      <span className="inline-block w-2 h-2 rounded-full mr-1.5" style={{ background: item.color }} />
                      {item.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          <div className="chart-container p-6 flex flex-col justify-between">
            <div>
              <h3 className="text-headline-md font-bold text-on-surface mb-2">Informations Civio</h3>
              <div className="text-body-sm text-on-surface-variant flex flex-col gap-2">
                <div>Version du client : <strong className="text-on-surface">{platformInfo.clientVersion}</strong></div>
                <div>Base de données locale : <strong className="text-on-surface">{platformInfo.dbVersion}</strong></div>
                <div>Dernière synchronisation : <strong className="text-on-surface">{platformInfo.lastSync}</strong></div>
              </div>
            </div>

            <div className="flex gap-2.5 mt-6">
              <button className="btn-glass flex-1 text-body-sm">
                Vérifier MAJ
              </button>
              <button className="btn-primary flex-[1.5] text-body-sm">
                Télécharger Logs
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
