"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

interface Office {
  id: string;
  name: string;
  city: string;
  region: string;
  address: string;
  hours: string;
  phone: string;
  status: "open" | "busy" | "closed";
  activeCounters: number;
  avgWaitTime: string;
}

export default function MapPage() {
  const [offices, setOffices] = useState<Office[]>([]);
  const [selectedRegion, setSelectedRegion] = useState("Toutes");

  useEffect(() => {
    const unsub = onSnapshot(collection(db, "offices"), (snap) => {
      setOffices(snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as Office)));
    });
    return unsub;
  }, []);

  const regions = ["Toutes", "Centre", "Littoral", "Nord", "Ouest", "Extrême-Nord"];

  const filteredOffices = offices.filter(
    (off) => selectedRegion === "Toutes" || off.region === selectedRegion
  );

  const getOfficeStatusColor = (city: string) => {
    const office = offices.find((o) => o.city.toLowerCase() === city.toLowerCase());
    if (!office) return "var(--glass-border)";
    if (office.status === "open") return "var(--accent-emerald)";
    if (office.status === "busy") return "var(--accent-amber)";
    return "var(--accent-rose)";
  };

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Header */}
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Carte des Bureaux Administratifs</h1>
              <p className="page-subtitle">
                Localisez les points d&apos;enrôlement CNI, passeport et état civil dans tout le Cameroun.
              </p>
            </div>
          </div>

          <div className="stagger" style={{ display: "grid", gridTemplateColumns: "1.2fr 1fr", gap: 24 }}>
            {/* Interactive Office List */}
            <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
              {/* Region Selector */}
              <div className="glass-card" style={{ padding: "16px 20px", display: "flex", gap: 8, overflowX: "auto" }}>
                {regions.map((reg) => (
                  <button
                    key={reg}
                    onClick={() => setSelectedRegion(reg)}
                    className="btn-glass"
                    style={{
                      padding: "8px 16px",
                      borderRadius: "20px",
                      fontSize: 12,
                      background: selectedRegion === reg ? "linear-gradient(135deg, rgba(59, 130, 246, 0.15), rgba(6, 182, 212, 0.1))" : "var(--glass-bg)",
                      borderColor: selectedRegion === reg ? "var(--accent-blue)" : "var(--glass-border)",
                      color: selectedRegion === reg ? "white" : "var(--text-secondary)",
                    }}
                  >
                    {reg === "Toutes" ? "Toutes les Régions" : reg}
                  </button>
                ))}
              </div>

              {/* Offices */}
              {filteredOffices.map((off) => {
                const statusColor = off.status === "open" ? "var(--accent-emerald)" :
                                    off.status === "busy" ? "var(--accent-amber)" :
                                    "var(--accent-rose)";

                return (
                  <div key={off.id} className="glass-card" style={{ padding: 20, transition: "transform 0.2s" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 10 }}>
                      <div>
                        <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-blue)", background: "var(--accent-blue-glow)", padding: "2px 8px", borderRadius: 10, marginRight: 8 }}>
                          {off.region}
                        </span>
                        <span style={{ fontSize: 11, color: "var(--text-tertiary)" }}>{off.city}</span>
                      </div>
                      <span
                        style={{
                          fontSize: 12,
                          fontWeight: 600,
                          color: statusColor,
                          display: "flex",
                          alignItems: "center",
                          gap: 6,
                        }}
                      >
                        <span style={{ width: 8, height: 8, borderRadius: "50%", background: statusColor }} />
                        {off.status === "open" ? "Fluide" : off.status === "busy" ? "Affluence élevée" : "Fermé"}
                      </span>
                    </div>

                    <h3 style={{ fontFamily: "Outfit", fontSize: 16, fontWeight: 700, color: "white", marginBottom: 6 }}>
                      {off.name}
                    </h3>
                    <p style={{ fontSize: 13, color: "var(--text-secondary)", marginBottom: 12 }}>
                      Adresse: {off.address}
                    </p>

                    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 12, borderTop: "1px solid rgba(255,255,255,0.04)", paddingTop: 12, fontSize: 12 }}>
                      <div>
                        <span style={{ color: "var(--text-tertiary)", display: "block" }}>Horaires</span>
                        <span style={{ color: "white", fontWeight: 600, display: "block", marginTop: 2 }}>{off.hours}</span>
                      </div>
                      <div>
                        <span style={{ color: "var(--text-tertiary)", display: "block" }}>Guichets Actifs</span>
                        <span style={{ color: "white", fontWeight: 600, display: "block", marginTop: 2 }}>{off.activeCounters} guichets</span>
                      </div>
                      <div>
                        <span style={{ color: "var(--text-tertiary)", display: "block" }}>Attente Moyenne</span>
                        <span style={{ color: "var(--accent-amber)", fontWeight: 600, display: "block", marginTop: 2 }}>{off.avgWaitTime}</span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Stylized Visual Cameroon Map representation (Vector mockup inside a glass card) */}
            <div className="glass-card" style={{ padding: 24, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
              <div>
                <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 16 }}>
                  Répartition Géographique Cameroun
                </h2>
                {/* SVG Visual Graphic */}
                <div style={{ width: "100%", height: 320, display: "flex", alignItems: "center", justifyContent: "center", position: "relative", background: "rgba(255,255,255,0.01)", borderRadius: "var(--radius-lg)", border: "1px solid var(--glass-border)", overflow: "hidden" }}>
                  <svg viewBox="0 0 400 450" width="100%" height="100%" fill="none" stroke="currentColor" style={{ opacity: 0.8 }}>
                    {/* Cameroon stylized outline */}
                    <path
                      d="M200 40 L250 80 L290 120 L270 180 L240 210 L280 250 L250 310 L210 330 L180 370 L140 400 L120 380 L130 320 L110 280 L150 250 L120 200 L160 160 L180 120 L160 80 Z"
                      fill="rgba(255, 255, 255, 0.02)"
                      stroke="var(--glass-border)"
                      strokeWidth="2"
                    />

                    {/* Douala point */}
                    <circle cx="145" cy="275" r="8" fill={getOfficeStatusColor("Douala")} style={{ animation: "pulse-glow 2s infinite" }} />
                    <text x="160" y="279" fill="white" fontSize="11" fontWeight="600">Douala</text>

                    {/* Yaounde point */}
                    <circle cx="180" cy="290" r="8" fill={getOfficeStatusColor("Yaoundé")} />
                    <text x="195" y="294" fill="white" fontSize="11" fontWeight="600">Yaoundé</text>

                    {/* Garoua point */}
                    <circle cx="260" cy="140" r="8" fill={getOfficeStatusColor("Garoua")} />
                    <text x="205" y="144" fill="white" fontSize="11" fontWeight="600">Garoua</text>

                    {/* Maroua point */}
                    <circle cx="270" cy="70" r="8" fill={getOfficeStatusColor("Maroua")} />
                    <text x="215" y="74" fill="white" fontSize="11" fontWeight="600">Maroua</text>

                    {/* Bafoussam point */}
                    <circle cx="150" cy="235" r="8" fill={getOfficeStatusColor("Bafoussam")} />
                    <text x="165" y="239" fill="white" fontSize="11" fontWeight="600">Bafoussam</text>
                  </svg>
                </div>
              </div>

              <div style={{ marginTop: 24, fontSize: 12, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                Astuce : Les indicateurs de couleur montrent la charge actuelle de travail dans chaque bureau d&apos;enregistrement en temps réel.
              </div>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}
