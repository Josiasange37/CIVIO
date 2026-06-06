"use client";

import React, { useState, useEffect } from "react";
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
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Utilisateurs Actifs</h1>
          <p className="page-subtitle">
            Suivez la répartition des citoyens camerounais qui utilisent Civio pour leurs démarches.
          </p>
        </div>
      </div>

      <div className="chart-container p-5 mb-8">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 stagger">
          <div>
            <div className="text-body-sm text-on-surface-variant">Citoyens Enregistrés</div>
            <div className="text-[32px] font-bold text-primary mt-2 font-headline tracking-tight">
              {userStats.registered}
            </div>
            <div className="text-body-sm text-accent-emerald mt-2">
              {userStats.registeredChange}
            </div>
          </div>
          <div>
            <div className="text-body-sm text-on-surface-variant">Actifs Aujourd&apos;hui</div>
            <div className="text-[32px] font-bold text-primary mt-2 font-headline tracking-tight">
              {userStats.activeToday}
            </div>
            <div className="text-body-sm text-accent-cyan mt-2">
              {userStats.activeTodayChange}
            </div>
          </div>
          <div>
            <div className="text-body-sm text-on-surface-variant">Sessions Hors-ligne</div>
            <div className="text-[32px] font-bold text-primary mt-2 font-headline tracking-tight">
              {userStats.offlineSessions}
            </div>
            <div className="text-body-sm text-on-surface-variant opacity-70 mt-2">
              {userStats.offlineSessionsChange}
            </div>
          </div>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6 animate-fade-in-up">
        <div className="relative flex-1 w-full sm:max-w-sm">
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="18" height="18">
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </div>
          <input
            type="text"
            placeholder="Rechercher par nom ou région..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-[42px] pl-[44px] pr-4 bg-surface border border-outline-variant rounded-2xl text-body-sm text-on-surface outline-none"
          />
        </div>

        <div className="flex gap-2 overflow-x-auto pb-1 w-full sm:w-auto">
          {regions.map((reg) => (
            <button
              key={reg}
              onClick={() => setSelectedRegion(reg)}
              className="btn-glass whitespace-nowrap"
            >
              {reg === "Toutes" ? "Toutes les Régions" : reg.split(" ")[0]}
            </button>
          ))}
        </div>
      </div>

      <div className="chart-container animate-fade-in-up overflow-hidden">
        <div className="chart-header">
          <div>
            <div className="chart-title">Annuaire des Citoyens</div>
            <p className="text-body-sm text-on-surface-variant mt-1">
              Liste des utilisateurs actifs et hors-ligne enregistrés sur Civio
            </p>
          </div>
        </div>

        <div className="table-responsive">
          <table className="glass-table">
            <thead>
              <tr>
                <th>Citoyen</th>
                <th className="hide-mobile">Région</th>
                <th className="hide-mobile">Inscription</th>
                <th>Dernière activité</th>
                <th>Démarches</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              {filteredCitizens.map((cit) => (
                <tr key={cit.id}>
                  <td>
                    <div className="flex items-center gap-3">
                      <div
                        className="w-9 h-9 rounded-full flex items-center justify-center text-[13px] font-bold text-white flex-shrink-0"
                        style={{
                          background: `linear-gradient(135deg, ${cit.avatarColor}, var(--bg-primary))`,
                          boxShadow: `0 0 10px ${cit.avatarColor}44`,
                        }}
                      >
                        {cit.name.split(" ").map((w) => w[0]).join("")}
                      </div>
                      <div>
                        <span className="text-on-surface font-semibold block text-body-sm">
                          {cit.name}
                        </span>
                        <span className="text-[11px] text-on-surface-variant opacity-70">
                          ID: {cit.id}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td className="hide-mobile">{cit.region}</td>
                  <td className="hide-mobile">{cit.joinedDate}</td>
                  <td className="text-on-surface">{cit.lastActive}</td>
                  <td className="text-center font-bold text-accent-cyan">
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
    </div>
  );
}
