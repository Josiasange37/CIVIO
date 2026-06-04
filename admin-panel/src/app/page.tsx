"use client";

import React, { useEffect, useState } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import StatCard from "@/components/StatCard";
import { MiniLineChart, MiniBarChart } from "@/components/Charts";
import { db } from "@/lib/firebase";
import { collection, getDocs, doc, onSnapshot } from "firebase/firestore";

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

/* ── Mock Data ── */





const statusLabels: Record<string, string> = {
  completed: "Terminé",
  active: "En cours",
  pending: "En attente",
  error: "Erreur",
};

/* ── Page Component ── */
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
              positive
              glowColor="emerald"
              delay={50}
            />
            <StatCard
              icon={<ProcedureIcon />}
              label="Procédures Actives"
              value={procedureCount.toString()}
              change="Synchronisé en temps réel"
              positive
              glowColor="cyan"
              delay={100}
            />
            <StatCard
              icon={<DocIcon />}
              label="Documents Générés"
              value={totals.docsTotal}
              change={totals.docsChange}
              positive
              glowColor="purple"
              delay={150}
            />
            <StatCard
              icon={<SuccessIcon />}
              label="Taux de Succès"
              value={totals.successRate}
              change={totals.successChange}
              positive
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
                    12 derniers mois
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
              <MiniLineChart
                data={lineData}
                color="#10b981"
                glow="rgba(16,185,129,0.3)"
                height={220}
              />
            </div>

            {/* Bar Chart */}
            <div className="chart-container animate-fade-in-up" style={{ animationDelay: "0.4s" }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Documents par Mois</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    2026
                  </p>
                </div>
              </div>
              <MiniBarChart
                data={barData}
                color="#8b5cf6"
                glow="rgba(139,92,246,0.3)"
                height={220}
              />
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
                  <tr key={i}>
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
                          {row.user
                            .split(" ")
                            .map((w) => w[0])
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
                        {statusLabels[row.status]}
                      </span>
                    </td>
                    <td style={{ whiteSpace: "nowrap", fontSize: 13 }}>{row.time}</td>
                  </tr>
                ))}
              </tbody>
            </table>
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
            {/* Procedure Card 1 */}
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: "var(--radius-md)",
                    background: "rgba(16,185,129,0.12)",
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
                  <div style={{ fontWeight: 600, fontSize: 15 }}>CNI / Passeport</div>
                  <div style={{ fontSize: 12, color: "var(--text-tertiary)" }}>2 procédures</div>
                </div>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13 }}>
                <span style={{ color: "var(--text-secondary)" }}>Consultations</span>
                <span style={{ color: "var(--accent-emerald)", fontWeight: 600 }}>4 521</span>
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
                    width: "78%",
                    borderRadius: 2,
                    background: "linear-gradient(90deg, var(--accent-emerald), var(--accent-cyan))",
                    boxShadow: "0 0 8px var(--accent-emerald-glow)",
                  }}
                />
              </div>
            </div>

            {/* Procedure Card 2 */}
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: "var(--radius-md)",
                    background: "rgba(139,92,246,0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 18,
                  }}
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
                    <path d="M6 12v5c0 2 2 3 6 3s6-1 6-3v-5"/>
                  </svg>
                </div>
                <div>
                  <div style={{ fontWeight: 600, fontSize: 15 }}>Concours ENS</div>
                  <div style={{ fontSize: 12, color: "var(--text-tertiary)" }}>1 procédure</div>
                </div>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13 }}>
                <span style={{ color: "var(--text-secondary)" }}>Consultations</span>
                <span style={{ color: "var(--accent-purple)", fontWeight: 600 }}>2 891</span>
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
                    width: "62%",
                    borderRadius: 2,
                    background: "linear-gradient(90deg, var(--accent-purple), var(--accent-rose))",
                    boxShadow: "0 0 8px var(--accent-purple-glow)",
                  }}
                />
              </div>
            </div>

            {/* Procedure Card 3 */}
            <div className="glass-card" style={{ padding: 24 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: "var(--radius-md)",
                    background: "rgba(6,182,212,0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 18,
                  }}
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
                    <rect x="4" y="2" width="16" height="20" rx="2"/>
                    <line x1="9" y1="22" x2="9" y2="22"/>
                    <line x1="15" y1="22" x2="15" y2="22"/>
                  </svg>
                </div>
                <div>
                  <div style={{ fontWeight: 600, fontSize: 15 }}>Création SARL</div>
                  <div style={{ fontSize: 12, color: "var(--text-tertiary)" }}>1 procédure</div>
                </div>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13 }}>
                <span style={{ color: "var(--text-secondary)" }}>Consultations</span>
                <span style={{ color: "var(--accent-cyan)", fontWeight: 600 }}>1 345</span>
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
                    width: "45%",
                    borderRadius: 2,
                    background: "linear-gradient(90deg, var(--accent-cyan), var(--accent-blue))",
                    boxShadow: "0 0 8px var(--accent-cyan-glow)",
                  }}
                />
              </div>
            </div>
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
            <span>© 2026 CIVIO — GCD4F Cameroun</span>
            <span>
              Conçu avec passion pour l&apos;administration camerounaise
            </span>
          </footer>
        </div>
      </main>
    </>
  );
}
