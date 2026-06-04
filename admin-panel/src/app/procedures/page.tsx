"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, addDoc, doc, setDoc } from "firebase/firestore";

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

  // New Procedure Form State
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
    <>
      <Sidebar />
      <main className="main-content">
        <TopBar />
        <div className="page-container">
          {/* Header */}
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
              {isAdding ? "Fermer le formulaire" : "Nouvelle Procédure"}
            </button>
          </div>

          {/* Quick Stats Banner (Liquid Glass Style) */}
          <div
            className="animate-fade-in-up"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
              marginBottom: 32,
            }}
          >
            <div className="glass-card" style={{ padding: "16px 20px" }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Total Procédures</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-cyan)", marginTop: 4 }}>
                {procedures.length}
              </div>
            </div>
            <div className="glass-card" style={{ padding: "16px 20px" }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Actives</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-emerald)", marginTop: 4 }}>
                {procedures.filter(p => p.status === "active").length}
              </div>
            </div>
            <div className="glass-card" style={{ padding: "16px 20px" }}>
              <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Moyenne Coût</div>
              <div style={{ fontFamily: "Outfit", fontSize: 24, fontWeight: 700, color: "var(--accent-amber)", marginTop: 4 }}>
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

          {/* Add Procedure Section (Form in Glass Card) */}
          {isAdding && (
            <div className="glass-card animate-fade-in-up" style={{ padding: 24, marginBottom: 32, border: "1px solid var(--accent-emerald)" }}>
              <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 20, color: "var(--accent-emerald)" }}>
                Créer un nouveau guide de procédure admin
              </h2>
              <form onSubmit={handleAddProcedure} style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
                <div style={{ gridColumn: "1 / -1" }}>
                  <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                    Nom de la procédure (ex: Certificat de Célibat)
                  </label>
                  <input
                    type="text"
                    required
                    value={newTitle}
                    onChange={(e) => setNewTitle(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      outline: "none",
                    }}
                  />
                </div>
                <div>
                  <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>Catégorie</label>
                  <select
                    value={newCategory}
                    onChange={(e) => setNewCategory(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--bg-secondary)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      outline: "none",
                    }}
                  >
                    {categories.filter(c => c !== "Toutes").map(cat => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>Difficulté</label>
                  <select
                    value={newDifficulty}
                    onChange={(e) => setNewDifficulty(e.target.value as any)}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--bg-secondary)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      outline: "none",
                    }}
                  >
                    <option value="Facile">Facile</option>
                    <option value="Moyen">Moyen</option>
                    <option value="Difficile">Difficile</option>
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>Coût (FCFA / Gratuit)</label>
                  <input
                    type="text"
                    placeholder="ex: 5 000 FCFA"
                    value={newCost}
                    onChange={(e) => setNewCost(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      outline: "none",
                    }}
                  />
                </div>
                <div>
                  <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>Délai indicatif</label>
                  <input
                    type="text"
                    placeholder="ex: 3 jours"
                    value={newTimeline}
                    onChange={(e) => setNewTimeline(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      outline: "none",
                    }}
                  />
                </div>
                <div style={{ gridColumn: "1 / -1", display: "flex", justifyContent: "flex-end", gap: 12, marginTop: 10 }}>
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

          {/* Search and Filters Bar */}
          <div
            className="animate-fade-in-up"
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 16,
              marginBottom: 24,
              flexWrap: "wrap",
            }}
          >
            {/* Search Input */}
            <div style={{ position: "relative", flex: 1, minWidth: 260 }}>
              <input
                type="text"
                placeholder="Rechercher une procédure administrative..."
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

            {/* Category tabs */}
            <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 4 }}>
              {categories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setSelectedCategory(cat)}
                  className="btn-glass"
                  style={{
                    padding: "8px 16px",
                    borderRadius: "20px",
                    fontSize: 12,
                    background: selectedCategory === cat ? "linear-gradient(135deg, rgba(16, 185, 129, 0.15), rgba(6, 182, 212, 0.1))" : "var(--glass-bg)",
                    borderColor: selectedCategory === cat ? "var(--accent-emerald)" : "var(--glass-border)",
                    color: selectedCategory === cat ? "white" : "var(--text-secondary)",
                  }}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          {/* Procedures Grid */}
          <div
            className="stagger"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))",
              gap: 20,
            }}
          >
            {filteredProcedures.map((proc, index) => {
              const diffColor = proc.difficulty === "Facile" ? "var(--accent-emerald)" :
                                proc.difficulty === "Moyen" ? "var(--accent-amber)" :
                                "var(--accent-rose)";

              return (
                <div key={proc.id} className="glass-card" style={{ padding: 24, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                  <div>
                    {/* Header line of card */}
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                      <span
                        style={{
                          fontSize: 11,
                          fontWeight: 700,
                          color: "var(--accent-cyan)",
                          background: "rgba(6, 182, 212, 0.12)",
                          padding: "3px 10px",
                          borderRadius: 20,
                        }}
                      >
                        {proc.category}
                      </span>
                      <span className={`badge-status badge-${proc.status}`}>
                        {proc.status === "active" ? "Actif" : proc.status === "pending" ? "En attente" : "Terminé"}
                      </span>
                    </div>

                    {/* Title */}
                    <h3 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 700, color: "white", marginBottom: 8 }}>
                      {proc.title}
                    </h3>

                    {/* Meta info */}
                    <p style={{ fontSize: 13, color: "var(--text-secondary)", marginBottom: 16 }}>
                      Difficulté: <strong style={{ color: diffColor }}>{proc.difficulty}</strong> · {proc.stepsCount} étapes dans le parcours.
                    </p>

                    {/* Quick details */}
                    <div style={{ display: "flex", gap: 16, borderTop: "1px solid rgba(255,255,255,0.04)", paddingTop: 12, marginBottom: 16 }}>
                      <div>
                        <div style={{ fontSize: 11, color: "var(--text-tertiary)" }}>Coût</div>
                        <div style={{ fontSize: 13, fontWeight: 600, color: "white", marginTop: 2 }}>{proc.cost}</div>
                      </div>
                      <div>
                        <div style={{ fontSize: 11, color: "var(--text-tertiary)" }}>Délai moyen</div>
                        <div style={{ fontSize: 13, fontWeight: 600, color: "white", marginTop: 2 }}>{proc.timeline}</div>
                      </div>
                      <div>
                        <div style={{ fontSize: 11, color: "var(--text-tertiary)" }}>Taux d&apos;utilisateurs</div>
                        <div style={{ fontSize: 13, fontWeight: 600, color: "white", marginTop: 2 }}>{proc.successRate}</div>
                      </div>
                    </div>
                  </div>

                  {/* Actions */}
                  <div style={{ display: "flex", gap: 10, marginTop: 12 }}>
                    <button className="btn-glass" style={{ flex: 1, padding: "8px 12px", fontSize: 12 }}>
                      Editer
                    </button>
                    <button className="btn-glass" style={{ flex: 1, padding: "8px 12px", fontSize: 12, borderColor: "var(--accent-cyan)" }}>
                      Voir Parcours
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </main>
    </>
  );
}
