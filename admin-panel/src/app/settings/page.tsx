"use client";

import React, { useState } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";

export default function SettingsPage() {
  const [syncFreq, setSyncFreq] = useState("daily");
  const [primaryLang, setPrimaryLang] = useState("fr");
  const [enableOrbs, setEnableOrbs] = useState(true);
  const [accentColor, setAccentColor] = useState("emerald");
  const [apiKey, setApiKey] = useState("op_live_••••••••••••••••••••••••");

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Header */}
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Paramètres de la Plateforme</h1>
              <p className="page-subtitle">
                Configurez les options système de Civio, la base de connaissances et les préférences visuelles.
              </p>
            </div>
          </div>

          <div className="stagger" style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24 }}>
            {/* Left Column: System & Security */}
            <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
              {/* Sync settings */}
              <div className="glass-card" style={{ padding: 24 }}>
                <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 16, color: "var(--accent-cyan)" }}>
                  Base de Données et Synchronisation
                </h2>

                <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
                  <div>
                    <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                      Fréquence des mises à jour des procédures
                    </label>
                    <select
                      value={syncFreq}
                      onChange={(e) => setSyncFreq(e.target.value)}
                      style={{
                        width: "100%",
                        padding: "10px 14px",
                        background: "var(--bg-secondary)",
                        border: "1px solid var(--glass-border)",
                        borderRadius: "var(--radius-md)",
                        color: "white",
                        outline: "none",
                      }}
                    >
                      <option value="hourly">Toutes les heures</option>
                      <option value="daily">Quotidiennement (Recommandé)</option>
                      <option value="weekly">Hebdomadairement</option>
                      <option value="manual">Manuel uniquement</option>
                    </select>
                  </div>

                  <div>
                    <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                      Langue principale d&apos;assistance
                    </label>
                    <select
                      value={primaryLang}
                      onChange={(e) => setPrimaryLang(e.target.value)}
                      style={{
                        width: "100%",
                        padding: "10px 14px",
                        background: "var(--bg-secondary)",
                        border: "1px solid var(--glass-border)",
                        borderRadius: "var(--radius-md)",
                        color: "white",
                        outline: "none",
                      }}
                    >
                      <option value="fr">Français (Cameroun)</option>
                      <option value="en">English (Cameroon)</option>
                      <option value="bilingual">Bilingue (Français/English)</option>
                    </select>
                  </div>
                </div>
              </div>

              {/* Security & Access */}
              <div className="glass-card" style={{ padding: 24 }}>
                <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 16, color: "var(--accent-purple)" }}>
                  Sécurité et Clés d&apos;API
                </h2>

                <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
                  <div>
                    <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                      Clé d&apos;API OpenRouter (Dialogue intelligent facultatif)
                    </label>
                    <input
                      type="password"
                      value={apiKey}
                      onChange={(e) => setApiKey(e.target.value)}
                      style={{
                        width: "100%",
                        padding: "10px 14px",
                        background: "rgba(255,255,255,0.03)",
                        border: "1px solid var(--glass-border)",
                        borderRadius: "var(--radius-md)",
                        color: "white",
                        outline: "none",
                      }}
                    />
                  </div>

                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingTop: 10 }}>
                    <div>
                      <span style={{ fontWeight: 600, display: "block", fontSize: 14 }}>Chiffrement Local</span>
                      <span style={{ fontSize: 12, color: "var(--text-secondary)" }}>Chiffrer l&apos;historique des citoyens</span>
                    </div>
                    <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-emerald)", background: "var(--accent-emerald-glow)", padding: "4px 10px", borderRadius: 20 }}>
                      Actif (AES-256)
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column: Style & Customization */}
            <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
              {/* Visual customization */}
              <div className="glass-card" style={{ padding: 24 }}>
                <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 16, color: "var(--accent-emerald)" }}>
                  Design Liquid Glass & Effets
                </h2>

                <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
                  {/* Orbs toggle */}
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div>
                      <span style={{ fontWeight: 600, display: "block", fontSize: 14 }}>Sphères Lumineuses Flottantes</span>
                      <span style={{ fontSize: 12, color: "var(--text-secondary)" }}>Activer l&apos;arrière-plan dynamique</span>
                    </div>
                    <button
                      onClick={() => setEnableOrbs(!enableOrbs)}
                      className="btn-glass"
                      style={{
                        padding: "6px 14px",
                        fontSize: 12,
                        borderColor: enableOrbs ? "var(--accent-emerald)" : "var(--glass-border)",
                        color: enableOrbs ? "var(--accent-emerald)" : "var(--text-secondary)",
                      }}
                    >
                      {enableOrbs ? "Activé" : "Désactivé"}
                    </button>
                  </div>

                  {/* Accent selection */}
                  <div>
                    <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 10 }}>
                      Couleur d&apos;accentuation principale
                    </label>
                    <div style={{ display: "flex", gap: 10 }}>
                      {[
                        { id: "emerald", color: "#10b981", label: "Émeraude" },
                        { id: "cyan", color: "#06b6d4", label: "Cyan" },
                        { id: "purple", color: "#8b5cf6", label: "Violet" },
                        { id: "amber", color: "#f59e0b", label: "Ambre" },
                      ].map((item) => (
                        <button
                          key={item.id}
                          onClick={() => setAccentColor(item.id)}
                          className="btn-glass"
                          style={{
                            flex: 1,
                            padding: "8px 0",
                            fontSize: 12,
                            borderColor: accentColor === item.id ? item.color : "var(--glass-border)",
                            color: accentColor === item.id ? "white" : "var(--text-secondary)",
                            background: accentColor === item.id ? `${item.color}22` : "var(--glass-bg)",
                          }}
                        >
                          <span style={{ display: "inline-block", width: 8, height: 8, borderRadius: "50%", background: item.color, marginRight: 6 }} />
                          {item.label}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Version Info Card */}
              <div className="glass-card" style={{ padding: 24, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                <div>
                  <h3 style={{ fontFamily: "Outfit", fontSize: 15, fontWeight: 700, marginBottom: 8 }}>Informations Civio</h3>
                  <div style={{ fontSize: 13, color: "var(--text-secondary)", display: "flex", flexDirection: "column", gap: 8 }}>
                    <div>Version du client : <strong style={{ color: "white" }}>1.0.4-release</strong></div>
                    <div>Base de données locale : <strong style={{ color: "white" }}>v36-cameroun-cni</strong></div>
                    <div>Dernière synchronisation : <strong style={{ color: "white" }}>Aujourd&apos;hui, 06:12</strong></div>
                  </div>
                </div>

                <div style={{ display: "flex", gap: 10, marginTop: 24 }}>
                  <button className="btn-glass" style={{ flex: 1, padding: "8px 12px", fontSize: 12 }}>
                    Vérifier MAJ
                  </button>
                  <button className="btn-primary" style={{ flex: 1.5, padding: "8px 12px", fontSize: 12 }}>
                    Télécharger Logs
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}
