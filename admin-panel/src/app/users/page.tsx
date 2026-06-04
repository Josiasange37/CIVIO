"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

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

const FR_MONTHS: Record<string, number> = {
  jan: 0, janv: 0, janvier: 0,
  fév: 1, fev: 1, févr: 1, fevr: 1, février: 1, fevrier: 1,
  mar: 2, mars: 2,
  avr: 3, avril: 3,
  mai: 4,
  juin: 5,
  juil: 6, juillet: 6,
  août: 7, aout: 7,
  sep: 8, sept: 8, septembre: 8,
  oct: 9, octobre: 9,
  nov: 10, novembre: 10,
  déc: 11, dec: 11, décembre: 11, decembre: 11,
};

function parseFrenchDate(s: string): Date | null {
  if (!s || typeof s !== "string") return null;
  const m = s.match(/(\d{1,2})\s+([A-Za-zéûôîâèù]+)\s+(\d{4})/i);
  if (!m) return null;
  const day = parseInt(m[1], 10);
  const monthKey = m[2].toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  const month = FR_MONTHS[monthKey];
  const year = parseInt(m[3], 10);
  if (month === undefined || isNaN(day) || isNaN(year)) return null;
  return new Date(year, month, day);
}

const avatarColors = ["#10b981", "#8b5cf6", "#06b6d4", "#f59e0b", "#f43f5e", "#3b82f6", "#10b981", "#8b5cf6"];

export default function UsersPage() {
  const [citizens, setCitizens] = useState<Citizen[]>([]);
  const [userStats, setUserStats] = useState({
    registered: "0",
    registeredChange: "—",
    activeToday: "0",
    activeTodayChange: "—",
    offlineSessions: "0%",
    offlineSessionsChange: "—",
  });
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedRegion, setSelectedRegion] = useState("Toutes");

  useEffect(() => {
    const unsubCitizens = onSnapshot(collection(db, "citizens"), (snap) => {
      const list = snap.docs.map((doc, i) => {
        const data = doc.data();
        return {
          id: doc.id,
          name: data.name || "",
          region: data.region || "",
          joinedDate: data.joinedDate || "",
          lastActive: data.lastActive || "",
          completedProcedures: data.completedProcedures || 0,
          status: data.status || "active",
          avatarColor: avatarColors[i % avatarColors.length],
        } as Citizen;
      });
      setCitizens(list);

      const total = list.length;
      const inactive = list.filter((c) => c.status === "inactive").length;
      const offlinePct = total > 0 ? (inactive / total) * 100 : 0;

      const now = new Date();
      const todayStr = now.toLocaleDateString("fr-FR", { day: "2-digit", month: "long", year: "numeric" });
      const activeToday = list.filter((c) => {
        const la = (c.lastActive || "").toLowerCase();
        if (!la) return false;
        if (la.includes("il y a")) {
          const m = la.match(/il y a\s+(\d+)\s+(min|h|heure|heures|jour|jours)/);
          if (!m) return false;
          const n = parseInt(m[1], 10);
          const u = m[2].toLowerCase();
          if (u.startsWith("min") || u.startsWith("h") || u.startsWith("heure")) return true;
          if (u.startsWith("jour") && n === 1) return true;
          return false;
        }
        return c.lastActive === todayStr;
      }).length;

      const thisMonth = now.getMonth();
      const thisYear = now.getFullYear();
      const lastMonth = thisMonth === 0 ? 11 : thisMonth - 1;
      const lastMonthYear = thisMonth === 0 ? thisYear - 1 : thisYear;
      let thisM = 0, lastM = 0;
      for (const c of list) {
        const dt = parseFrenchDate(c.joinedDate);
        if (!dt) continue;
        if (dt.getMonth() === thisMonth && dt.getFullYear() === thisYear) thisM += 1;
        if (dt.getMonth() === lastMonth && dt.getFullYear() === lastMonthYear) lastM += 1;
      }
      const regChange = lastM === 0
        ? (thisM > 0 ? `+${thisM} ce mois` : "—")
        : `${thisM - lastM >= 0 ? "+" : ""}${thisM - lastM} ce mois`;

      setUserStats({
        registered: total.toLocaleString("fr-FR").replace(/,/g, " "),
        registeredChange: regChange,
        activeToday: activeToday.toLocaleString("fr-FR").replace(/,/g, " "),
        activeTodayChange: total > 0 ? `${Math.round((activeToday / total) * 100)}% du total` : "—",
        offlineSessions: `${offlinePct.toFixed(1)}%`,
        offlineSessionsChange: `${inactive} inactif(s)`,
      });
    });

    return () => unsubCitizens();
  }, []);

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
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Utilisateurs Actifs</h1>
              <p className="page-subtitle">
                Suivez la répartition des citoyens camerounais qui utilisent Civio pour leurs démarches.
              </p>
            </div>
          </div>

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
                {userStats.registered}
              </div>
              <div style={{ fontSize: 12, color: "var(--accent-emerald)", marginTop: 8 }}>
                {userStats.registeredChange}
              </div>
            </div>
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Actifs Aujourd&apos;hui</div>
              <div style={{ fontFamily: "Outfit", fontSize: 32, fontWeight: 700, color: "white", marginTop: 8 }}>
                {userStats.activeToday}
              </div>
              <div style={{ fontSize: 12, color: "var(--accent-cyan)", marginTop: 8 }}>
                {userStats.activeTodayChange}
              </div>
            </div>
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Sessions Hors-ligne</div>
              <div style={{ fontFamily: "Outfit", fontSize: 32, fontWeight: 700, color: "white", marginTop: 8 }}>
                {userStats.offlineSessions}
              </div>
              <div style={{ fontSize: 12, color: "var(--text-tertiary)", marginTop: 8 }}>
                {userStats.offlineSessionsChange}
              </div>
            </div>
          </div>

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
