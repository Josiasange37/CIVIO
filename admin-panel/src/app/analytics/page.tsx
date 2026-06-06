"use client";

import React, { useState, useEffect } from "react";
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
            ? `${fmtNum(completed)} documents validés sur ${fmtNum(total)} générés`
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
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Analyses et Rapports</h1>
          <p className="page-subtitle">
            Données consolidées d&apos;utilisation, statistiques régionales et synchronisations hors-ligne.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8 stagger">
        <div className="chart-container p-5">
          <div className="text-body-sm text-on-surface-variant">Visites / Jour (Moy.)</div>
          <div className="text-[24px] font-bold text-accent-cyan mt-1 font-headline">{stats.dailyVisits}</div>
          <div className="text-[11px] text-on-surface-variant opacity-70 mt-2">{stats.dailyVisitsChange}</div>
        </div>
        <div className="chart-container p-5">
          <div className="text-body-sm text-on-surface-variant">Taux d&apos;Assistance Locale</div>
          <div className="text-[24px] font-bold text-accent-emerald mt-1 font-headline">{stats.assistanceRate}</div>
          <div className="text-[11px] text-on-surface-variant opacity-70 mt-2">{stats.assistanceRateChange}</div>
        </div>
        <div className="chart-container p-5">
          <div className="text-body-sm text-on-surface-variant">Besoins d&apos;Écriture</div>
          <div className="text-[24px] font-bold text-accent-purple mt-1 font-headline">{stats.writingNeeds}</div>
          <div className="text-[11px] text-on-surface-variant opacity-70 mt-2">{stats.writingNeedsChange}</div>
        </div>
        <div className="chart-container p-5">
          <div className="text-body-sm text-on-surface-variant">Économie de Timbre</div>
          <div className="text-[24px] font-bold text-accent-amber mt-1 font-headline">{stats.stampSavings}</div>
          <div className="text-[11px] text-on-surface-variant opacity-70 mt-2">{stats.stampSavingsChange}</div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6 mb-8">
        <div className="lg:col-span-3 chart-container p-6 animate-fade-in-up">
          <div className="chart-header">
            <div>
              <div className="chart-title">Volume des Synchronisations de Données</div>
              <p className="text-body-sm text-on-surface-variant mt-1">
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
            <div className="h-60 flex items-center justify-center text-on-surface-variant text-body-md">
              Aucun document généré — courbe vide.
            </div>
          )}
        </div>

        <div className="lg:col-span-2 chart-container p-6 animate-fade-in-up">
          <div className="chart-header">
            <div>
              <div className="chart-title">Régions Dominantes</div>
              <p className="text-body-sm text-on-surface-variant mt-1">
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
            <div className="h-60 flex items-center justify-center text-on-surface-variant text-body-md">
              Aucun utilisateur enregistré — répartition vide.
            </div>
          )}
        </div>
      </div>

      <div className="chart-container p-6 animate-fade-in-up">
        <h3 className="text-headline-md font-bold text-on-surface mb-5 font-headline">
          Comparaison de l&apos;efficacité administrative
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
          {[
            { key: "cniDelay", icon: "badge", color: "emerald" },
            { key: "offlineUse", icon: "wifi_off", color: "cyan" },
            { key: "docValidation", icon: "verified", color: "purple" },
          ].map(({ key, color }) => {
            const item = efficiency[key as keyof typeof efficiency];
            const accentVar = `var(--accent-${color})`;
            const glowVar = `var(--accent-${color}-glow)`;
            return (
              <div
                key={key}
                className="p-5 bg-surface border border-outline-variant rounded-2xl"
              >
                <div className="flex justify-between items-center mb-3">
                  <span className="font-semibold text-on-surface text-body-md">{item.title}</span>
                  <span
                    className="text-[11px] font-bold px-2 py-0.5 rounded-xl"
                    style={{ color: accentVar, background: glowVar }}
                  >
                    {item.badge}
                  </span>
                </div>
                <p className="text-body-sm text-on-surface-variant leading-relaxed">
                  {item.desc}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
