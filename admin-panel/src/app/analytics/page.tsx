"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { MiniLineChart, MiniBarChart } from "@/components/Charts";
import { db } from "@/lib/firebase";
import { doc, onSnapshot } from "firebase/firestore";

interface MetricStats {
  dailyVisits: string;
  dailyVisitsChange: string;
  assistanceRate: string;
  assistanceRateChange: string;
  writingNeeds: string;
  writingNeedsChange: string;
  stampSavings: string;
  stampSavingsChange: string;
}

interface EfficiencyDetail {
  title: string;
  badge: string;
  desc: string;
}

interface EfficiencyStats {
  cniDelay: EfficiencyDetail;
  offlineUse: EfficiencyDetail;
  docValidation: EfficiencyDetail;
}

export default function AnalyticsPage() {
  const [monthlySyncData, setMonthlySyncData] = useState<number[]>([]);
  const [regionBreakdown, setRegionBreakdown] = useState<any[]>([]);
  const [stats, setStats] = useState<MetricStats>({
    dailyVisits: "0",
    dailyVisitsChange: "",
    assistanceRate: "0%",
    assistanceRateChange: "",
    writingNeeds: "0",
    writingNeedsChange: "",
    stampSavings: "0",
    stampSavingsChange: ""
  });
  const [efficiency, setEfficiency] = useState<EfficiencyStats>({
    cniDelay: { title: "Délai Moyen d'Établissement CNI", badge: "", desc: "" },
    offlineUse: { title: "Utilisation Hors-Ligne Locale", badge: "", desc: "" },
    docValidation: { title: "Validation Documentaire", badge: "", desc: "" }
  });

  useEffect(() => {
    // 1. Monthly Sync Data
    const unsubSync = onSnapshot(doc(db, "analytics", "monthly_sync"), (docSnap) => {
      if (docSnap.exists()) {
        setMonthlySyncData(docSnap.data().values || []);
      }
    });

    // 2. Region Breakdown
    const unsubRegions = onSnapshot(doc(db, "analytics", "region_breakdown"), (docSnap) => {
      if (docSnap.exists()) {
        setRegionBreakdown(docSnap.data().values || []);
      }
    });

    // 3. Stats Document
    const unsubStats = onSnapshot(doc(db, "analytics", "stats"), (docSnap) => {
      if (docSnap.exists()) {
        setStats(docSnap.data() as MetricStats);
      }
    });

    // 4. Efficiency Document
    const unsubEfficiency = onSnapshot(doc(db, "analytics", "efficiency"), (docSnap) => {
      if (docSnap.exists()) {
        setEfficiency(docSnap.data() as EfficiencyStats);
      }
    });

    return () => {
      unsubSync();
      unsubRegions();
      unsubStats();
      unsubEfficiency();
    };
  }, []);

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Header */}
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Analyses et Rapports</h1>
              <p className="page-subtitle">
                Données consolidées d&apos;utilisation, statistiques régionales et synchronisations hors-ligne.
              </p>
            </div>
          </div>

          {/* Quick Analytical Stats */}
          <div
            className="stagger"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
              gap: 20,
              marginBottom: 32,
            }}
          >
            <div className="glass-card" style={{ padding: 20 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Visites / Jour (Moy.)</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-cyan)", marginTop: 4 }}>
                {stats.dailyVisits}
              </div>
              <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 8 }}>
                {stats.dailyVisitsChange}
              </div>
            </div>
            <div className="glass-card" style={{ padding: 20 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Taux d&apos;Assistance Locale</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-emerald)", marginTop: 4 }}>
                {stats.assistanceRate}
              </div>
              <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 8 }}>
                {stats.assistanceRateChange}
              </div>
            </div>
            <div className="glass-card" style={{ padding: 20 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Besoins d&apos;Écriture</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-purple)", marginTop: 4 }}>
                {stats.writingNeeds}
              </div>
              <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 8 }}>
                {stats.writingNeedsChange}
              </div>
            </div>
            <div className="glass-card" style={{ padding: 20 }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Économie de Timbre</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-amber)", marginTop: 4 }}>
                {stats.stampSavings}
              </div>
              <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 8 }}>
                {stats.stampSavingsChange}
              </div>
            </div>
          </div>

          {/* Detailed Charts Row */}
          <div style={{ display: "grid", gridTemplateColumns: "1.5fr 1fr", gap: 24, marginBottom: 32 }}>
            {/* Sync Trends (Line) */}
            <div className="chart-container animate-fade-in-up" style={{ padding: 24 }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Volume des Synchronisations de Données</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    Mises à jour mensuelles de la base de connaissances Civio (2025 - 2026)
                  </p>
                </div>
              </div>
              <MiniLineChart
                data={monthlySyncData}
                color="#06b6d4"
                glow="rgba(6,182,212,0.3)"
                height={240}
              />
            </div>

            {/* Region breakdown (Bar) */}
            <div className="chart-container animate-fade-in-up" style={{ padding: 24 }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Régions Dominantes</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    Nombre d&apos;utilisateurs par région administrative
                  </p>
                </div>
              </div>
              <MiniBarChart
                data={regionBreakdown}
                color="#10b981"
                glow="rgba(16,185,129,0.3)"
                height={240}
              />
            </div>
          </div>

          {/* Efficiency Comparison Section (Liquid Glass) */}
          <div className="glass-card animate-fade-in-up" style={{ padding: 24 }}>
            <h3 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 20 }}>
              Comparaison de l&apos;efficacité administrative
            </h3>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: 20 }}>
              {/* Box 1 */}
              <div style={{ padding: 20, background: "rgba(255,255,255,0.02)", border: "1px solid var(--glass-border)", borderRadius: "var(--radius-lg)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <span style={{ fontWeight: 600, color: "white" }}>{efficiency.cniDelay.title}</span>
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-emerald)", background: "var(--accent-emerald-glow)", padding: "2px 8px", borderRadius: 10 }}>{efficiency.cniDelay.badge}</span>
                </div>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                  {efficiency.cniDelay.desc}
                </p>
              </div>

              {/* Box 2 */}
              <div style={{ padding: 20, background: "rgba(255,255,255,0.02)", border: "1px solid var(--glass-border)", borderRadius: "var(--radius-lg)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <span style={{ fontWeight: 600, color: "white" }}>{efficiency.offlineUse.title}</span>
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-cyan)", background: "var(--accent-cyan-glow)", padding: "2px 8px", borderRadius: 10 }}>{efficiency.offlineUse.badge}</span>
                </div>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                  {efficiency.offlineUse.desc}
                </p>
              </div>

              {/* Box 3 */}
              <div style={{ padding: 20, background: "rgba(255,255,255,0.02)", border: "1px solid var(--glass-border)", borderRadius: "var(--radius-lg)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <span style={{ fontWeight: 600, color: "white" }}>{efficiency.docValidation.title}</span>
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-purple)", background: "var(--accent-purple-glow)", padding: "2px 8px", borderRadius: 10 }}>{efficiency.docValidation.badge}</span>
                </div>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                  {efficiency.docValidation.desc}
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}
