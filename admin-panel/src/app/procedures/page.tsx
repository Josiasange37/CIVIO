"use client";

import React, { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, addDoc } from "firebase/firestore";

interface Procedure {
  id: string;
  title: string;
  category: string;
  cost: string;
  timeline: string;
  difficulty: "Facile" | "Moyen" | "Difficile";
  successRate: string;
  status: "active" | "pending" | "completed";
  stepsCount: number;
}

export default function ProceduresPage() {
  const [procedures, setProcedures] = useState<Procedure[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("Toutes");
  const [isAdding, setIsAdding] = useState(false);
  const [loading, setLoading] = useState(true);

  const [newTitle, setNewTitle] = useState("");
  const [newCategory, setNewCategory] = useState("Identité");
  const [newCost, setNewCost] = useState("");
  const [newTimeline, setNewTimeline] = useState("");
  const [newDifficulty, setNewDifficulty] = useState<"Facile" | "Moyen" | "Difficile">("Moyen");

  useEffect(() => {
    const q = collection(db, "procedures");
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const procsData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Procedure[];
      setProcedures(procsData);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching procedures: ", error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const categories = ["Toutes", "Identité", "Voyage", "État Civil", "Entreprise", "Académique", "Justice"];

  const filteredProcedures = procedures.filter((proc) => {
    const matchesSearch = proc.title?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          proc.category?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === "Toutes" || proc.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const handleAddProcedure = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;

    const newProc = {
      title: newTitle,
      category: newCategory,
      cost: newCost || "Gratuit",
      timeline: newTimeline || "Indéterminé",
      difficulty: newDifficulty,
      successRate: "100%",
      status: "active",
      stepsCount: 3,
    };

    try {
      await addDoc(collection(db, "procedures"), newProc);
    } catch (error) {
      console.error("Error adding procedure: ", error);
    }

    setNewTitle("");
    setNewCost("");
    setNewTimeline("");
    setNewDifficulty("Moyen");
    setIsAdding(false);
  };

  return (
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Gestion des Procédures</h1>
          <p className="page-subtitle">
            Visualisez, modifiez et ajoutez les guides d&apos;aide aux citoyens.
          </p>
        </div>
        <button className="btn-primary" onClick={() => setIsAdding(!isAdding)}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
          {isAdding ? "Fermer" : "Nouvelle Procédure"}
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8 stagger">
        <div className="chart-container p-4">
          <div className="text-body-sm text-on-surface-variant">Total Procédures</div>
          <div className="text-[24px] font-bold text-accent-cyan mt-1 font-headline">
            {procedures.length}
          </div>
        </div>
        <div className="chart-container p-4">
          <div className="text-body-sm text-on-surface-variant">Actives</div>
          <div className="text-[24px] font-bold text-accent-emerald mt-1 font-headline">
            {procedures.filter(p => p.status === "active").length}
          </div>
        </div>
        <div className="chart-container p-4">
          <div className="text-body-sm text-on-surface-variant">Moyenne Coût</div>
          <div className="text-[24px] font-bold text-accent-amber mt-1 font-headline">
            {(() => {
              const costs = procedures.map(p => {
                const num = parseInt((p.cost || "").replace(/\s/g, "").replace(/[^0-9]/g, ""));
                return isNaN(num) ? 0 : num;
              }).filter(c => c > 0);
              const avg = costs.length > 0 ? Math.round(costs.reduce((a, b) => a + b, 0) / costs.length) : 0;
              return avg > 0 ? `~${avg.toLocaleString()} FCFA` : "—";
            })()}
          </div>
        </div>
      </div>

      {isAdding && (
        <div className="chart-container p-6 mb-8 animate-fade-in-up border border-accent-emerald">
          <h2 className="text-headline-md font-bold text-accent-emerald mb-5">
            Créer un nouveau guide de procédure admin
          </h2>
          <form onSubmit={handleAddProcedure} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                Nom de la procédure (ex: Certificat de Célibat)
              </label>
              <input
                type="text"
                required
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              />
            </div>
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">Catégorie</label>
              <select
                value={newCategory}
                onChange={(e) => setNewCategory(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              >
                {categories.filter(c => c !== "Toutes").map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">Difficulté</label>
              <select
                value={newDifficulty}
                onChange={(e) => setNewDifficulty(e.target.value as any)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              >
                <option value="Facile">Facile</option>
                <option value="Moyen">Moyen</option>
                <option value="Difficile">Difficile</option>
              </select>
            </div>
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">Coût (FCFA / Gratuit)</label>
              <input
                type="text"
                placeholder="ex: 5 000 FCFA"
                value={newCost}
                onChange={(e) => setNewCost(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              />
            </div>
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">Délai indicatif</label>
              <input
                type="text"
                placeholder="ex: 3 jours"
                value={newTimeline}
                onChange={(e) => setNewTimeline(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              />
            </div>
            <div className="md:col-span-2 flex justify-end gap-3 mt-2">
              <button type="button" className="btn-glass" onClick={() => setIsAdding(false)}>
                Annuler
              </button>
              <button type="submit" className="btn-primary">
                Enregistrer la procédure
              </button>
            </div>
          </form>
        </div>
      )}

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
            placeholder="Rechercher une procédure administrative..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-[42px] pl-[44px] pr-4 bg-surface border border-outline-variant rounded-2xl text-body-sm text-on-surface outline-none"
          />
        </div>

        <div className="flex gap-2 overflow-x-auto pb-1 w-full sm:w-auto">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className="btn-glass whitespace-nowrap"
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      <div className="stagger grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
        {filteredProcedures.map((proc) => {
          const diffColor = proc.difficulty === "Facile" ? "var(--accent-emerald)" :
                            proc.difficulty === "Moyen" ? "var(--accent-amber)" :
                            "var(--accent-rose)";

          return (
            <div key={proc.id} className="chart-container p-6 flex flex-col justify-between">
              <div>
                <div className="flex justify-between items-start mb-3">
                  <span className="text-[11px] font-bold text-accent-cyan bg-accent-cyan-glow px-2.5 py-1 rounded-2xl">
                    {proc.category}
                  </span>
                  <span className={`badge-status badge-${proc.status}`}>
                    {proc.status === "active" ? "Actif" : proc.status === "pending" ? "En attente" : "Terminé"}
                  </span>
                </div>

                <h3 className="text-[18px] font-bold text-on-surface mb-2 font-headline">
                  {proc.title}
                </h3>

                <p className="text-body-sm text-on-surface-variant mb-4">
                  Difficulté: <strong style={{ color: diffColor }}>{proc.difficulty}</strong> · {proc.stepsCount} étapes
                </p>

                <div className="flex gap-4 border-t border-outline-variant pt-3 mb-4">
                  <div>
                    <div className="text-[11px] text-on-surface-variant opacity-70">Coût</div>
                    <div className="text-body-sm font-semibold text-on-surface mt-0.5">{proc.cost}</div>
                  </div>
                  <div>
                    <div className="text-[11px] text-on-surface-variant opacity-70">Délai moyen</div>
                    <div className="text-body-sm font-semibold text-on-surface mt-0.5">{proc.timeline}</div>
                  </div>
                  <div>
                    <div className="text-[11px] text-on-surface-variant opacity-70">Taux</div>
                    <div className="text-body-sm font-semibold text-on-surface mt-0.5">{proc.successRate}</div>
                  </div>
                </div>
              </div>

              <div className="flex gap-2.5 mt-3">
                <button className="btn-glass flex-1 text-body-sm">Editer</button>
                <button className="btn-glass flex-1 text-body-sm border-accent-cyan">Voir Parcours</button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
