"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { MiniLineChart, MiniBarChart } from "@/components/Charts";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

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
  if (n === null || n === undefined || isNaN(n)) return "0";
  return n.toLocaleString("fr-FR").replace(/,/g, " ");
}

export default function AnalyticsPage() {
  const [monthlySyncData, setMonthlySyncData] = useState<number[]>([]);
  const [regionBreakdown, setRegionBreakdown] = useState<any[]>([]);
  const [stats, setStats] = useState({
    dailyVisits: "0",
    dailyVisitsChange: "—",
    assistanceRate: "—",
    assistanceRateChange: "—",
    writingNeeds: "0",
    writingNeedsChange: "—",
    stampSavings: "0 FCFA",
    stampSavingsChange: "—",
  });
  const [efficiency, setEfficiency] = useState({
    cniDelay: { title: "Délai Moyen d'Établissement CNI", badge: "—", desc: "Aucune procédure enregistrée." },
    offlineUse: { title: "Utilisation Hors-Ligne Locale", badge: "—", desc: "Aucune donnée d'utilisation." },
    docValidation: { title: "Validation Documentaire", badge: "—", desc: "Aucun document généré." },
  });

  useEffect(() => {
    const unsubs: (() => void)[] = [];

    unsubs.push(onSnapshot(collection(db, "documents"), (snap) => {
      const docs = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const total = snap.size;
      const completed = docs.filter((d) => d.status === "completed").length;
      const rate = total > 0 ? (completed / total) * 100 : 0;

      setStats((prev) => ({
        ...prev,
        writingNeeds: fmtNum(total),
        stampSavings: `${fmtNum(total * 1000)} FCFA`,
        docValidationRate: rate,
      }));

      const last24 = new Array(24).fill(0);
      const now = new Date();
      for (const docItem of docs) {
        const dt = parseFrenchDate(docItem.dateGenerated);
        if (!dt) continue;
        const monthsAgo = (now.getFullYear() - dt.getFullYear()) * 12 + (now.getMonth() - dt.getMonth());
        if (monthsAgo >= 0 && monthsAgo < 24) last24[23 - monthsAgo] += 1;
      }
      setMonthlySyncData(last24);

      setEfficiency((prev) => ({
        ...prev,
        docValidation: {
          title: "Validation Documentaire",
          badge: total > 0 ? `${rate.toFixed(1)}%` : "—",
          desc: total > 0
            ? `${fmtNum(completed)} documents validés sur ${fmtNum(total)} générés — calculé à partir de la collection documents.`
            : "Aucun document généré pour le moment.",
        },
      }));
    }));

    unsubs.push(onSnapshot(collection(db, "citizens"), (snap) => {
      const citizens = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));

      const regionCounts: Record<string, number> = {};
      for (const c of citizens) {
        const r = c.region || "Inconnue";
        regionCounts[r] = (regionCounts[r] || 0) + 1;
      }
      const regions = Object.entries(regionCounts)
        .map(([name, count]) => ({ name, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 6)
        .map((r) => ({ value: r.count, label: r.name }));
      setRegionBreakdown(regions);
    }));

    unsubs.push(onSnapshot(collection(db, "procedures"), (snap) => {
      const procs = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const cniProcs = procs.filter((p) =>
        /cni|carte|identité|identite|passeport/i.test(p.title || "") || /Identité/i.test(p.category || "")
      );
      if (cniProcs.length > 0) {
        const parseTimeline = (t: string): number => {
          if (!t) return 0;
          const m = t.match(/(\d+)\s*(h|j|sem|mois)/i);
          if (!m) return 0;
          const n = parseInt(m[1], 10);
          const u = m[2].toLowerCase();
          if (u === "h") return n / 24;
          if (u === "j") return n;
          if (u === "sem") return n * 7;
          if (u === "mois") return n * 30;
          return 0;
        };
        const avgDays = cniProcs.reduce((acc, p) => acc + parseTimeline(p.timeline || ""), 0) / cniProcs.length;
        setEfficiency((prev) => ({
          ...prev,
          cniDelay: {
            title: "Délai Moyen d'Établissement CNI",
            badge: `${avgDays.toFixed(0)} j`,
            desc: `Moyenne calculée sur ${cniProcs.length} procédure(s) liée(s) à l'identité / passeport dans la base.`,
          },
        }));
      } else {
        setEfficiency((prev) => ({
          ...prev,
          cniDelay: {
            title: "Délai Moyen d'Établissement CNI",
            badge: "—",
            desc: "Aucune procédure d'identité ou passeport enregistrée.",
          },
        }));
      }
    }));

    unsubs.push(onSnapshot(collection(db, "recentActivity"), (snap) => {
      const acts = snap.docs.map((d) => ({ id: d.id, ...d.data() } as any));
      const total = acts.length;
      const completed = acts.filter((a) => a.status === "completed").length;
      const rate = total > 0 ? (completed / total) * 100 : 0;

      setStats((prev) => ({
        ...prev,
        dailyVisits: total > 0 ? (total / 7).toFixed(1) : "0",
        dailyVisitsChange: total > 0 ? `${total} interactions / 7 j` : "—",
        assistanceRate: total > 0 ? `${rate.toFixed(1)}%` : "—",
        assistanceRateChange: total > 0 ? `${completed} terminées` : "—",
      }));

      setEfficiency((prev) => ({
        ...prev,
        offlineUse: {
          title: "Utilisation Hors-Ligne Locale",
          badge: total > 0 ? `${total} act.` : "—",
          desc: total > 0
            ? `${fmtNum(total)} interactions enregistrées (${fmtNum(completed)} terminées, ${fmtNum(acts.filter((a) => a.status === "pending").length)} en attente, ${fmtNum(acts.filter((a) => a.status === "error").length)} en erreur).`
            : "Aucune activité enregistrée pour le moment.",
        },
      }));
    }));

    return () => unsubs.forEach((u) => u());
  }, []);

  return (
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          <div className="page-header animate-fade-in-up">
            <div>
              <h1 className="page-title">Analyses et Rapports</h1>
              <p className="page-subtitle">
                Données consolidées d&apos;utilisation, statistiques régionales et synchronisations hors-ligne.
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

          <div style={{ display: "grid", gridTemplateColumns: "1.5fr 1fr", gap: 24, marginBottom: 32 }}>
            <div className="chart-container animate-fade-in-up" style={{ padding: 24 }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Volume des Synchronisations de Données</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    Documents générés par mois (24 derniers mois)
                  </p>
                </div>
              </div>
              {monthlySyncData.some((v) => v > 0) ? (
                <MiniLineChart
                  data={monthlySyncData}
                  color="#06b6d4"
                  glow="rgba(6,182,212,0.3)"
                  height={240}
                />
              ) : (
                <div style={{ height: 240, display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-tertiary)", fontSize: 14 }}>
                  Aucun document généré — courbe vide.
                </div>
              )}
            </div>

            <div className="chart-container animate-fade-in-up" style={{ padding: 24 }}>
              <div className="chart-header">
                <div>
                  <div className="chart-title">Régions Dominantes</div>
                  <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                    Nombre d&apos;utilisateurs par région administrative
                  </p>
                </div>
              </div>
              {regionBreakdown.length > 0 ? (
                <MiniBarChart
                  data={regionBreakdown}
                  color="#10b981"
                  glow="rgba(16,185,129,0.3)"
                  height={240}
                />
              ) : (
                <div style={{ height: 240, display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-tertiary)", fontSize: 14 }}>
                  Aucun utilisateur enregistré — répartition vide.
                </div>
              )}
            </div>
          </div>

          <div className="glass-card animate-fade-in-up" style={{ padding: 24 }}>
            <h3 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 20 }}>
              Comparaison de l&apos;efficacité administrative
            </h3>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: 20 }}>
              <div style={{ padding: 20, background: "rgba(255,255,255,0.02)", border: "1px solid var(--glass-border)", borderRadius: "var(--radius-lg)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <span style={{ fontWeight: 600, color: "white" }}>{efficiency.cniDelay.title}</span>
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-emerald)", background: "var(--accent-emerald-glow)", padding: "2px 8px", borderRadius: 10 }}>{efficiency.cniDelay.badge}</span>
                </div>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                  {efficiency.cniDelay.desc}
                </p>
              </div>

              <div style={{ padding: 20, background: "rgba(255,255,255,0.02)", border: "1px solid var(--glass-border)", borderRadius: "var(--radius-lg)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <span style={{ fontWeight: 600, color: "white" }}>{efficiency.offlineUse.title}</span>
                  <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-cyan)", background: "var(--accent-cyan-glow)", padding: "2px 8px", borderRadius: 10 }}>{efficiency.offlineUse.badge}</span>
                </div>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                  {efficiency.offlineUse.desc}
                </p>
              </div>

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
