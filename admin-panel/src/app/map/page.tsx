"use client";

import React, { useState, useEffect } from "react";
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
    if (!office) return "var(--outline-variant)";
    if (office.status === "open") return "var(--accent-emerald)";
    if (office.status === "busy") return "var(--accent-amber)";
    return "var(--accent-rose)";
  };

  const cityCoordinates: Record<string, { cx: number; cy: number }> = {
    Douala: { cx: 145, cy: 275 },
    "Yaoundé": { cx: 180, cy: 290 },
    Garoua: { cx: 260, cy: 140 },
    Maroua: { cx: 270, cy: 70 },
    Bafoussam: { cx: 150, cy: 235 },
  };

  return (
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Carte des Bureaux Administratifs</h1>
          <p className="page-subtitle">
            Localisez les points d&apos;enrôlement CNI, passeport et état civil dans tout le Cameroun.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6 stagger">
        <div className="lg:col-span-3 flex flex-col gap-5">
          <div className="chart-container p-4 flex gap-2 overflow-x-auto">
            {regions.map((reg) => (
              <button
                key={reg}
                onClick={() => setSelectedRegion(reg)}
                className="btn-glass whitespace-nowrap"
              >
                {reg === "Toutes" ? "Toutes les Régions" : reg}
              </button>
            ))}
          </div>

          {filteredOffices.map((off) => {
            const statusColor = off.status === "open" ? "var(--accent-emerald)" :
                                off.status === "busy" ? "var(--accent-amber)" :
                                "var(--accent-rose)";

            return (
              <div key={off.id} className="chart-container p-5 transition-transform hover:scale-[1.01]">
                <div className="flex justify-between items-start mb-2.5">
                  <div>
                    <span className="text-[11px] font-bold text-accent-blue bg-accent-blue-glow px-2 py-0.5 rounded-xl mr-2">
                      {off.region}
                    </span>
                    <span className="text-[11px] text-on-surface-variant">{off.city}</span>
                  </div>
                  <span className="text-body-sm font-semibold flex items-center gap-1.5" style={{ color: statusColor }}>
                    <span className="w-2 h-2 rounded-full" style={{ background: statusColor }} />
                    {off.status === "open" ? "Fluide" : off.status === "busy" ? "Affluence élevée" : "Fermé"}
                  </span>
                </div>

                <h3 className="text-[16px] font-bold text-on-surface mb-1.5 font-headline">
                  {off.name}
                </h3>
                <p className="text-body-sm text-on-surface-variant mb-3">
                  Adresse: {off.address}
                </p>

                <div className="grid grid-cols-3 gap-3 border-t border-outline-variant pt-3 text-body-sm">
                  <div>
                    <span className="text-on-surface-variant opacity-70 block">Horaires</span>
                    <span className="font-semibold text-on-surface block mt-0.5">{off.hours}</span>
                  </div>
                  <div>
                    <span className="text-on-surface-variant opacity-70 block">Guichets Actifs</span>
                    <span className="font-semibold text-on-surface block mt-0.5">{off.activeCounters} guichets</span>
                  </div>
                  <div>
                    <span className="text-on-surface-variant opacity-70 block">Attente Moyenne</span>
                    <span className="font-semibold text-accent-amber block mt-0.5">{off.avgWaitTime}</span>
                  </div>
                </div>
              </div>
            );
          })}

          {filteredOffices.length === 0 && (
            <div className="chart-container p-8 text-center text-on-surface-variant italic">
              Aucun bureau trouvé pour cette région.
            </div>
          )}
        </div>

        <div className="lg:col-span-2 chart-container p-6 flex flex-col justify-between">
          <div>
            <h2 className="text-headline-md font-bold text-on-surface mb-4 font-headline">
              Répartition Géographique Cameroun
            </h2>
            <div className="w-full aspect-[4/5] flex items-center justify-center relative bg-surface border border-outline-variant rounded-2xl overflow-hidden">
              <svg viewBox="0 0 400 450" width="100%" height="100%" fill="none" className="opacity-80">
                <path
                  d="M200 40 L250 80 L290 120 L270 180 L240 210 L280 250 L250 310 L210 330 L180 370 L140 400 L120 380 L130 320 L110 280 L150 250 L120 200 L160 160 L180 120 L160 80 Z"
                  fill="rgba(255, 255, 255, 0.02)"
                  stroke="var(--outline-variant)"
                  strokeWidth="2"
                />

                {Object.entries(cityCoordinates).map(([city, coord]) => {
                  const fillColor = getOfficeStatusColor(city);
                  return (
                    <g key={city}>
                      <circle cx={coord.cx} cy={coord.cy} r="8" fill={fillColor} />
                      <text x={coord.cx + 16} y={coord.cy + 4} fill="var(--text-primary)" fontSize="11" fontWeight="600">
                        {city}
                      </text>
                    </g>
                  );
                })}
              </svg>
            </div>
          </div>

          <div className="mt-6 text-body-sm text-on-surface-variant leading-relaxed">
            Les indicateurs de couleur montrent la charge actuelle de travail dans chaque bureau d&apos;enregistrement en temps réel.
          </div>
        </div>
      </div>
    </div>
  );
}
