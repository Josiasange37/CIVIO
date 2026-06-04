"use client";

import React, { useState } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";

interface Citizen {
  id: string;
  name: string;
  region: string;
  joinedDate: string;
  lastActive: string;
  completedProcedures: number;
  status: "active" | "inactive";
  avatarColor: string;
}

const mockCitizens: Citizen[] = [
  {
    id: "cit-1",
    name: "Amadou Bouba",
    region: "Extrême-Nord (Maroua)",
    joinedDate: "12 Mai 2026",
    lastActive: "Il y a 2 min",
    completedProcedures: 3,
    status: "active",
    avatarColor: "#10b981",
  },
  {
    id: "cit-2",
    name: "Marie Ngono",
    region: "Centre (Yaoundé)",
    joinedDate: "18 Mai 2026",
    lastActive: "Il y a 5 min",
    completedProcedures: 1,
    status: "active",
    avatarColor: "#8b5cf6",
  },
  {
    id: "cit-3",
    name: "Paul Ekambi",
    region: "Littoral (Douala)",
    joinedDate: "02 Avr 2026",
    lastActive: "Il y a 12 min",
    completedProcedures: 5,
    status: "active",
    avatarColor: "#06b6d4",
  },
  {
    id: "cit-4",
    name: "Fatou Diallo",
    region: "Adamaoua (Ngaoundéré)",
    joinedDate: "20 Avr 2026",
    lastActive: "Il y a 18 min",
    completedProcedures: 2,
    status: "inactive",
    avatarColor: "#f59e0b",
  },
  {
    id: "cit-5",
    name: "Jean-Pierre Tabi",
    region: "Sud (Ebolowa)",
    joinedDate: "01 Juin 2026",
    lastActive: "Il y a 25 min",
    completedProcedures: 0,
    status: "active",
    avatarColor: "#f43f5e",
  },
  {
    id: "cit-6",
    name: "Aïssatou Moussa",
    region: "Nord (Garoua)",
    joinedDate: "10 Mai 2026",
    lastActive: "Il y a 32 min",
    completedProcedures: 4,
    status: "inactive",
    avatarColor: "#3b82f6",
  },
  {
    id: "cit-7",
    name: "Samuel Eto'o Mbappé",
    region: "Littoral (Douala)",
    joinedDate: "29 Mai 2026",
    lastActive: "Il y a 1 heure",
    completedProcedures: 2,
    status: "active",
    avatarColor: "#10b981",
  },
  {
    id: "cit-8",
    name: "Florence Atangana",
    region: "Centre (Yaoundé)",
    joinedDate: "04 Mai 2026",
    lastActive: "Il y a 2 heures",
    completedProcedures: 7,
    status: "active",
    avatarColor: "#8b5cf6",
  },
];

export default function UsersPage() {
  const [citizens, setCitizens] = useState<Citizen[]>(mockCitizens);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedRegion, setSelectedRegion] = useState("Toutes");

  const regions = [
    "Toutes",
    "Centre (Yaoundé)",
    "Littoral (Douala)",
    "Extrême-Nord (Maroua)",
    "Nord (Garoua)",
    "Adamaoua (Ngaoundéré)",
    "Sud (Ebolowa)",
  ];

  const filteredCitizens = citizens.filter((cit) => {
    const matchesSearch = cit.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          cit.region.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesRegion = selectedRegion === "Toutes" || cit.region.includes(selectedRegion.split(" ")[0]);
    return matchesSearch && matchesRegion;
  });

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Header */}
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Utilisateurs Actifs</h1>
              <p className="page-subtitle">
                Suivez la répartition des citoyens camerounais qui utilisent Civio pour leurs démarches.
              </p>
            </div>
          </div>

          {/* Quick Stats Grid */}
          <div
            className="stagger"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
              gap: 20,
              marginBottom: 32,
            }}
          >
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Citoyens Enregistrés</div>
              <div style={{ fontFamily: "Outfit", fontSize: 32, fontWeight: 700, color: "white", marginTop: 8 }}>
                12 847
              </div>
              <div style={{ fontSize: 12, color: "var(--accent-emerald)", marginTop: 8 }}>
                +1 240 cette semaine
              </div>
            </div>
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Actifs Aujourd&apos;hui</div>
              <div style={{ fontFamily: "Outfit", fontSize: 32, fontWeight: 700, color: "white", marginTop: 8 }}>
                2 451
              </div>
              <div style={{ fontSize: 12, color: "var(--accent-cyan)", marginTop: 8 }}>
                +8% d&apos;augmentation
              </div>
            </div>
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Sessions Hors-ligne</div>
              <div style={{ fontFamily: "Outfit", fontSize: 32, fontWeight: 700, color: "white", marginTop: 8 }}>
                78.2%
              </div>
              <div style={{ fontSize: 12, color: "var(--text-tertiary)", marginTop: 8 }}>
                Assistance locale complète
              </div>
            </div>
          </div>

          {/* Filtering Bar */}
          <div
            className="animate-fade-in-up"
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              gap: 16,
              marginBottom: 24,
              flexWrap: "wrap",
            }}
          >
            {/* Search */}
            <div style={{ position: "relative", flex: 1, minWidth: 260 }}>
              <input
                type="text"
                placeholder="Rechercher par nom ou région..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  width: "100%",
                  height: 42,
                  padding: "0 16px 0 44px",
                  background: "var(--glass-bg)",
                  border: "1px solid var(--glass-border)",
                  borderRadius: "var(--radius-xl)",
                  color: "white",
                  outline: "none",
                  transition: "all 0.25s",
                }}
              />
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{
                  position: "absolute",
                  left: 14,
                  top: "50%",
                  transform: "translateY(-50%)",
                  width: 18,
                  height: 18,
                  color: "var(--text-tertiary)",
                }}
              >
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
              </svg>
            </div>

            {/* Region Select */}
            <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 4 }}>
              {regions.map((reg) => (
                <button
                  key={reg}
                  onClick={() => setSelectedRegion(reg)}
                  className="btn-glass"
                  style={{
                    padding: "8px 16px",
                    borderRadius: "20px",
                    fontSize: 12,
                    background: selectedRegion === reg ? "linear-gradient(135deg, rgba(6, 182, 212, 0.15), rgba(139, 92, 246, 0.1))" : "var(--glass-bg)",
                    borderColor: selectedRegion === reg ? "var(--accent-cyan)" : "var(--glass-border)",
                    color: selectedRegion === reg ? "white" : "var(--text-secondary)",
                  }}
                >
                  {reg === "Toutes" ? "Toutes les Régions" : reg.split(" ")[0]}
                </button>
              ))}
            </div>
          </div>

          {/* Citizen Table List in Glass Card Container */}
          <div className="chart-container animate-fade-in-up" style={{ padding: 0, overflow: "hidden" }}>
            <div className="chart-header" style={{ padding: "20px 24px 16px" }}>
              <div>
                <div className="chart-title">Annuaire des Citoyens</div>
                <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                  Liste des utilisateurs actifs et hors-ligne enregistrés sur Civio
                </p>
              </div>
            </div>

            <table className="glass-table">
              <thead>
                <tr>
                  <th>Citoyen</th>
                  <th>Région d&apos;inscription</th>
                  <th>Date d&apos;inscription</th>
                  <th>Dernière activité</th>
                  <th>Démarches complétées</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {filteredCitizens.map((cit, i) => (
                  <tr key={cit.id}>
                    <td>
                      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                        <div
                          style={{
                            width: 36,
                            height: 36,
                            borderRadius: "50%",
                            background: `linear-gradient(135deg, ${cit.avatarColor}, var(--bg-primary))`,
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            fontSize: 13,
                            fontWeight: 700,
                            color: "white",
                            flexShrink: 0,
                            boxShadow: `0 0 10px ${cit.avatarColor}44`,
                          }}
                        >
                          {cit.name
                            .split(" ")
                            .map((w) => w[0])
                            .join("")}
                        </div>
                        <div>
                          <span style={{ color: "var(--text-primary)", fontWeight: 600, display: "block" }}>
                            {cit.name}
                          </span>
                          <span style={{ fontSize: 11, color: "var(--text-tertiary)" }}>
                            ID: {cit.id}
                          </span>
                        </div>
                      </div>
                    </td>
                    <td>{cit.region}</td>
                    <td>{cit.joinedDate}</td>
                    <td style={{ color: "var(--text-primary)" }}>{cit.lastActive}</td>
                    <td style={{ textAlign: "center", fontWeight: 700, color: "var(--accent-cyan)" }}>
                      {cit.completedProcedures}
                    </td>
                    <td>
                      <span className={`badge-status badge-${cit.status === "active" ? "active" : "error"}`}>
                        {cit.status === "active" ? "En ligne" : "Hors ligne"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </>
  );
}
