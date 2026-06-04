"use client";

import React, { useEffect, useState } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import StatCard from "@/components/StatCard";
import { MiniLineChart, MiniBarChart } from "@/components/Charts";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

/* ── Stat Icons ── */
const UsersIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="24" height="24">
    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
    <circle cx="9" cy="7" r="4" />
    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
  </svg>
);

const ProcedureIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="24" height="24">
    <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2" />
    <rect x="9" y="3" width="6" height="4" rx="1" />
    <path d="M9 14l2 2 4-4" />
  </svg>
);

const DocIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="24" height="24">
    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
    <polyline points="14 2 14 8 20 8" />
    <line x1="16" y1="13" x2="8" y2="13" />
    <line x1="16" y1="17" x2="8" y2="17" />
  </svg>
);

const SuccessIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="24" height="24">
    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
    <polyline points="22 4 12 14.01 9 11.01" />
  </svg>
);

const statusLabels: Record<string, string> = {
  completed: "Terminé",
  active: "En cours",
  pending: "En attente",
  error: "Erreur",
};

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

const MONTH_LABELS = ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sep", "Oct", "Nov", "Déc"];

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

function fmtNum(n: number): string {
  if (!n && n !== 0) return "0";
  return n.toLocaleString("fr-FR").replace(/,/g, " ");
}

function pct(curr: number, prev: number): string {
  if (prev === 0) return curr > 0 ? "+100%" : "—";
  const v = ((curr - prev) / prev) * 100;
  const sign = v >= 0 ? "+" : "";
  return `${sign}${v.toFixed(1)}% ce mois`;
}

export default function DashboardPage() {
  const [procedureCount, setProcedureCount] = useState<number>(0);
  const [lineData, setLineData] = useState<number[]>([]);
  const [barData, setBarData] = useState<any[]>([]);
  const [recentActivity, setRecentActivity] = useState<any[]>([]);
  const [totals, setTotals] = useState<any>({
    usersTotal: "0", usersChange: "—",
    docsTotal: "0", docsChange: "—",
    successRate: "—", successChange: "—",
  });
  const [topProcedures, setTopProcedures] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubs: (() => void)[] = [];

    unsubs.push(onSnapshot(collection(db, "citizens"), (snap) => {
      const citizens = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const total = snap.size;

      const now = new Date();
      const thisMonth = now.getMonth();
      const thisYear = now.getFullYear();
      const lastMonth = thisMonth === 0 ? 11 : thisMonth - 1;
      const lastMonthYear = thisMonth === 0 ? thisYear - 1 : thisYear;

      const monthCounts = new Array(12).fill(0);
      let thisM = 0;
      let lastM = 0;
      for (const c of citizens) {
        const dt = parseFrenchDate(c.joinedDate);
        if (!dt) continue;
        if (dt.getFullYear() === thisYear) monthCounts[dt.getMonth()] += 1;
        if (dt.getMonth() === thisMonth && dt.getFullYear() === thisYear) thisM += 1;
        if (dt.getMonth() === lastMonth && dt.getFullYear() === lastMonthYear) lastM += 1;
      }

      setTotals((prev: any) => ({
        ...prev,
        usersTotal: fmtNum(total),
        usersChange: pct(thisM, lastM),
      }));
      setLineData(monthCounts);
    }));

    unsubs.push(onSnapshot(collection(db, "documents"), (snap) => {
      const docs = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const total = snap.size;

      const now = new Date();
      const thisMonth = now.getMonth();
      const thisYear = now.getFullYear();
      const lastMonth = thisMonth === 0 ? 11 : thisMonth - 1;
      const lastMonthYear = thisMonth === 0 ? thisYear - 1 : thisYear;

      const monthCounts = new Array(12).fill(0);
      let thisM = 0;
      let lastM = 0;
      for (const docItem of docs) {
        const dt = parseFrenchDate(docItem.dateGenerated);
        if (!dt) continue;
        if (dt.getFullYear() === thisYear) monthCounts[dt.getMonth()] += 1;
        if (dt.getMonth() === thisMonth && dt.getFullYear() === thisYear) thisM += 1;
        if (dt.getMonth() === lastMonth && dt.getFullYear() === lastMonthYear) lastM += 1;
      }

      setTotals((prev: any) => ({
        ...prev,
        docsTotal: fmtNum(total),
        docsChange: pct(thisM, lastM),
      }));
      setBarData(monthCounts.map((v, i) => ({ value: v, label: MONTH_LABELS[i] })));
    }));

    unsubs.push(onSnapshot(collection(db, "recentActivity"), (snap) => {
      const activities = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const total = activities.length;
      const completed = activities.filter((a) => a.status === "completed").length;
      const rate = total > 0 ? (completed / total) * 100 : 0;

      const now = new Date();
      const thisMonth = now.getMonth();
      const thisYear = now.getFullYear();
      const lastMonth = thisMonth === 0 ? 11 : thisMonth - 1;
      const lastMonthYear = thisMonth === 0 ? thisYear - 1 : thisYear;

      const parseActDate = (a: any): Date | null => {
        if (!a || !a.time || typeof a.time !== "string") return null;
        const m = a.time.match(/Il y a\s+(\d+)\s+(min|h|heure|heures|jour|jours)/i);
        if (!m) return null;
        const n = parseInt(m[1], 10);
        const unit = m[2].toLowerCase();
        const dt = new Date(now);
        if (unit.startsWith("min")) dt.setMinutes(dt.getMinutes() - n);
        else if (unit.startsWith("h") || unit.startsWith("heure")) dt.setHours(dt.getHours() - n);
        else if (unit.startsWith("jour")) dt.setDate(dt.getDate() - n);
        return dt;
      };

      let thisCompleted = 0, thisTotal = 0, lastCompleted = 0, lastTotal = 0;
      for (const a of activities) {
        const dt = parseActDate(a);
        if (!dt) continue;
        if (dt.getMonth() === thisMonth && dt.getFullYear() === thisYear) {
          thisTotal += 1;
          if (a.status === "completed") thisCompleted += 1;
        }
        if (dt.getMonth() === lastMonth && dt.getFullYear() === lastMonthYear) {
          lastTotal += 1;
          if (a.status === "completed") lastCompleted += 1;
        }
      }
      const thisRate = thisTotal > 0 ? (thisCompleted / thisTotal) * 100 : 0;
      const lastRate = lastTotal > 0 ? (lastCompleted / lastTotal) * 100 : 0;
      const change = lastRate === 0 ? (thisRate > 0 ? "+100%" : "—") : `${thisRate - lastRate >= 0 ? "+" : ""}${(thisRate - lastRate).toFixed(1)}% ce mois`;

      setTotals((prev: any) => ({
        ...prev,
        successRate: total > 0 ? `${rate.toFixed(1)}%` : "—",
        successChange: change,
      }));
      setRecentActivity(activities);
    }));

    unsubs.push(onSnapshot(collection(db, "procedures"), (snap) => {
      const procs = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      setProcedureCount(snap.size);
      setTopProcedures(procs.sort((a, b) => (b.views || 0) - (a.views || 0)).slice(0, 3));
    }));

    const t = setTimeout(() => setLoading(false), 1500);
    return () => {
      unsubs.forEach((u) => u());
      clearTimeout(t);
    };
  }, []);

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Page Header */}
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Dashboard</h1>
              <p className="page-subtitle">
                Vue d&apos;ensemble de l&apos;activité CIVIO — Cameroun
              </p>
            </div>
            <div style={{ display: "flex", gap: 12 }}>
              <button className="btn-glass">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                  <polyline points="7 10 12 15 17 10" />
                  <line x1="12" y1="15" x2="12" y2="3" />
                </svg>
                Exporter
              </button>
              <button className="btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
                  <line x1="12" y1="5" x2="12" y2="19" />
                  <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
                Nouvelle Procédure
              </button>
            </div>
          </div>

          {/* Stat Cards */}
          <div
            className="stagger"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
              gap: 20,
              marginBottom: 32,
            }}
          >
            <StatCard
              icon={<UsersIcon />}
              label="Utilisateurs Totaux"
              value={totals.usersTotal}
              change={totals.usersChange}
              positive={totals.usersChange?.startsWith("+") || totals.usersChange === "—"}
              glowColor="emerald"
              delay={50}
            />
            <StatCard
              icon={<ProcedureIcon />}
              label="Procédures Actives"
              value={fmtNum(procedureCount)}
              change={loading ? "Chargement…" : "Synchronisé en temps réel"}
              positive
              glowColor="cyan"
              delay={100}
            />
            <StatCard
              icon={<DocIcon />}
              label="Documents Générés"
              value={totals.docsTotal}
              change={totals.docsChange}
              positive={totals.docsChange?.startsWith("+") || totals.docsChange === "—"}
              glowColor="purple"
              delay={150}
            />
            <StatCard
              icon={<SuccessIcon />}
              label="Taux de Succès"
              value={totals.successRate}
              change={totals.successChange}
              positive={totals.successChange?.startsWith("+") || totals.successChange === "—"}
              glowColor="amber"
              delay={200}
            />
          </div>

          {/* Charts Row */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1.5fr 1fr",
              gap: 20,
              marginBottom: 32,
            }}
          >
            {/* Line Chart */}
            <div className="chart-container animate-fade-in-up" style={{ animationDelay: "0.3s" }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Croissance des Utilisateurs</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    {new Date().getFullYear()}
                  </p>
                </div>
                <div style={{ display: "flex", gap: 8 }}>
                  <button className="btn-glass" style={{ padding: "6px 14px", fontSize: 12 }}>
                    Mois
                  </button>
                  <button className="btn-glass" style={{ padding: "6px 14px", fontSize: 12, opacity: 0.5 }}>
                    Semaine
                  </button>
                </div>
              </div>
              {lineData.some((v) => v > 0) ? (
                <MiniLineChart
                  data={lineData}
                  color="#10b981"
                  glow="rgba(16,185,129,0.3)"
                  height={220}
                />
              ) : (
                <div style={{ height: 220, display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-tertiary)", fontSize: 14 }}>
                  Aucun utilisateur enregistré pour {new Date().getFullYear()}
                </div>
              )}
            </div>

            {/* Bar Chart */}
            <div className="chart-container animate-fade-in-up" style={{ animationDelay: "0.4s" }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Documents par Mois</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    {new Date().getFullYear()}
                  </p>
                </div>
              </div>
              {barData.some((b) => b.value > 0) ? (
                <MiniBarChart
                  data={barData}
                  color="#8b5cf6"
                  glow="rgba(139,92,246,0.3)"
                  height={220}
                />
              ) : (
                <div style={{ height: 220, display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-tertiary)", fontSize: 14 }}>
                  Aucun document généré pour {new Date().getFullYear()}
                </div>
              )}
            </div>
          </div>

          {/* Recent Activity Table */}
          <div
            className="chart-container animate-fade-in-up"
            style={{ animationDelay: "0.5s", padding: 0, overflow: "hidden" }}
          >
            <div className="chart-header" style={{ padding: "20px 24px 16px" }}>
              <div>
                <div className="chart-title">Activité Récente</div>
                <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                  Dernières interactions des utilisateurs
                </p>
              </div>
              <button className="btn-glass" style={{ padding: "6px 14px", fontSize: 12 }}>
                Voir tout →
              </button>
            </div>
            {recentActivity.length === 0 ? (
              <div style={{ padding: 40, textAlign: "center", color: "var(--text-tertiary)" }}>
                Aucune activité récente
              </div>
            ) : (
              <table className="glass-table" id="recent-activity-table">
                <thead>
                  <tr>
                    <th>Utilisateur</th>
                    <th>Action</th>
                    <th>Procédure / Document</th>
                    <th>Statut</th>
                    <th>Temps</th>
                  </tr>
                </thead>
                <tbody>
                  {recentActivity.map((row, i) => (
                    <tr key={row.id || i}>
                      <td>
                        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                          <div
                            style={{
                              width: 32,
                              height: 32,
                              borderRadius: "50%",
                              background: `linear-gradient(135deg, hsl(${i * 60}, 70%, 60%), hsl(${i * 60 + 30}, 70%, 50%))`,
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              fontSize: 12,
                              fontWeight: 700,
                              flexShrink: 0,
                            }}
                          >
                            {(row.user || "?")
                              .split(" ")
                              .map((w: string) => w?.[0] || "")
                              .join("")}
                          </div>
                          <span style={{ color: "var(--text-primary)", fontWeight: 500 }}>
                            {row.user}
                          </span>
                        </div>
                      </td>
                      <td>{row.action}</td>
                      <td style={{ color: "var(--text-primary)", fontWeight: 500 }}>
                        {row.target}
                      </td>
                      <td>
                        <span className={`badge-status badge-${row.status}`}>
                          {statusLabels[row.status] || row.status}
                        </span>
                      </td>
                      <td style={{ whiteSpace: "nowrap", fontSize: 13 }}>{row.time}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>

          {/* Procedures Quick View */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
              gap: 20,
              marginTop: 32,
            }}
          >
            {topProcedures.length === 0 ? (
              <div style={{ gridColumn: "1 / -1", padding: 40, textAlign: "center", color: "var(--text-tertiary)", background: "var(--glass-bg)", borderRadius: 16 }}>
                Aucune procédure enregistrée
              </div>
            ) : topProcedures.map((proc, i) => {
              const gradientColors = [
                { bg: "rgba(16,185,129,0.12)", bar: "linear-gradient(90deg, var(--accent-emerald), var(--accent-cyan))", glow: "var(--accent-emerald-glow)", text: "var(--accent-emerald)" },
                { bg: "rgba(139,92,246,0.12)", bar: "linear-gradient(90deg, var(--accent-purple), var(--accent-rose))", glow: "var(--accent-purple-glow)", text: "var(--accent-purple)" },
                { bg: "rgba(6,182,212,0.12)", bar: "linear-gradient(90deg, var(--accent-cyan), var(--accent-blue))", glow: "var(--accent-cyan-glow)", text: "var(--accent-cyan)" },
              ];
              const g = gradientColors[i % gradientColors.length];
              const maxViews = Math.max(...topProcedures.map((p) => p.views || 0));
              const barWidth = maxViews > 0 ? Math.round(((proc.views || 0) / maxViews) * 100) : 0;

              return (
                <div key={proc.id} className="glass-card" style={{ padding: 24 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
                    <div
                      style={{
                        width: 40,
                        height: 40,
                        borderRadius: "var(--radius-md)",
                        background: g.bg,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        fontSize: 18,
                      }}
                    >
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
                        <rect x="3" y="4" width="18" height="16" rx="2"/>
                        <circle cx="8" cy="10" r="2"/>
                        <line x1="12" y1="10" x2="18" y2="10"/>
                        <line x1="8" y1="16" x2="18" y2="16"/>
                      </svg>
                    </div>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 15 }}>{proc.title}</div>
                      <div style={{ fontSize: 12, color: "var(--text-tertiary)" }}>{proc.category}</div>
                    </div>
                  </div>
                  <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13 }}>
                    <span style={{ color: "var(--text-secondary)" }}>Consultations</span>
                    <span style={{ color: g.text, fontWeight: 600 }}>
                      {fmtNum(proc.views || 0)}
                    </span>
                  </div>
                  <div
                    style={{
                      height: 4,
                      borderRadius: 2,
                      background: "rgba(255,255,255,0.05)",
                      marginTop: 12,
                      overflow: "hidden",
                    }}
                  >
                    <div
                      style={{
                        height: "100%",
                        width: `${barWidth}%`,
                        borderRadius: 2,
                        background: g.bar,
                        boxShadow: `0 0 8px ${g.glow}`,
                      }}
                    />
                  </div>
                </div>
              );
            })}
          </div>

          {/* Footer */}
          <footer
            style={{
              marginTop: 48,
              paddingTop: 24,
              borderTop: "1px solid var(--glass-border)",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              fontSize: 12,
              color: "var(--text-tertiary)",
            }}
          >
            <span>© {new Date().getFullYear()} CIVIO — Xyberclan</span>
            <span>
              Conçu avec passion pour l&apos;administration camerounaise
            </span>
          </footer>
        </div>
      </main>
    </>
  );
}
