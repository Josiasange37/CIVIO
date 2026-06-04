"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import TopBar from "@/components/TopBar";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

interface DocLog {
  id: string;
  citizenName: string;
  docType: string;
  dateGenerated: string;
  validationCode: string;
  size: string;
  status: "active" | "completed" | "error";
}

interface DocTemplate {
  id: string;
  title: string;
  desc: string;
  count: string;
}

export default function DocumentsPage() {
  const [logs, setLogs] = useState<DocLog[]>([]);
  const [templates, setTemplates] = useState<DocTemplate[]>([]);
  const [verifyCode, setVerifyCode] = useState("");
  const [verificationResult, setVerificationResult] = useState<string | null>(null);

  useEffect(() => {
    const unsubLogs = onSnapshot(collection(db, "documents"), (snap) => {
      setLogs(snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as DocLog)));
    });

    const unsubTemplates = onSnapshot(collection(db, "documentTemplates"), (snap) => {
      setTemplates(snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as DocTemplate)));
    });

    return () => {
      unsubLogs();
      unsubTemplates();
    };
  }, []);

  const handleVerify = (e: React.FormEvent) => {
    e.preventDefault();
    if (!verifyCode.trim()) return;

    const matchedDoc = logs.find(
      (log) => log.validationCode.toLowerCase() === verifyCode.toLowerCase()
    );

    if (matchedDoc) {
      setVerificationResult(
        `SUCCESS: Le document "${matchedDoc.docType}" pour "${matchedDoc.citizenName}" a été généré avec succès par Civio le ${matchedDoc.dateGenerated}. Code de validation valide.`
      );
    } else {
      setVerificationResult(
        "ERROR: Code de validation invalide. Aucun document correspondant n'a été trouvé dans le registre officiel Civio."
      );
    }
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
              <h1 className="page-title">Documents & Modèles</h1>
              <p className="page-subtitle">
                Gérez les templates de formulaires administratifs et vérifiez l&apos;authenticité des documents générés.
              </p>
            </div>
          </div>

          {/* Verification Tools (Liquid Glass Card) */}
          <div className="stagger" style={{ display: "grid", gridTemplateColumns: "1.2fr 1fr", gap: 24, marginBottom: 32 }}>
            {/* Form list templates */}
            <div className="glass-card" style={{ padding: 24 }}>
              <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 16 }}>
                Modèles de documents disponibles (Offline)
              </h2>
              <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
                {templates.map((tpl) => (
                  <div
                    key={tpl.id}
                    style={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "space-between",
                      padding: 14,
                      background: "rgba(255, 255, 255, 0.02)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      transition: "transform 0.2s",
                    }}
                  >
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 14 }}>{tpl.title}</div>
                      <div style={{ fontSize: 12, color: "var(--text-secondary)", marginTop: 4 }}>{tpl.desc}</div>
                    </div>
                    <span style={{ fontSize: 11, fontWeight: 700, color: "var(--accent-purple)", background: "var(--accent-purple-glow)", padding: "2px 8px", borderRadius: 10 }}>
                      {tpl.count}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Validation Verification Tool */}
            <div className="glass-card" style={{ padding: 24, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
              <div>
                <h2 style={{ fontFamily: "Outfit", fontSize: 18, fontWeight: 600, marginBottom: 12, color: "var(--accent-emerald)" }}>
                  Vérificateur d&apos;authenticité CIVIO
                </h2>
                <p style={{ fontSize: 13, color: "var(--text-secondary)", marginBottom: 16 }}>
                  Saisissez le code de validation imprimé au bas du document généré pour authentifier sa provenance.
                </p>

                <form onSubmit={handleVerify} style={{ display: "flex", flexDirection: "column", gap: 12 }}>
                  <input
                    type="text"
                    placeholder="Code de validation (ex: CIVIO-8392-CM)"
                    value={verifyCode}
                    onChange={(e) => setVerifyCode(e.target.value)}
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
                  <button type="submit" className="btn-primary" style={{ alignSelf: "flex-start" }}>
                    Vérifier le document
                  </button>
                </form>

                {verificationResult && (
                  <div
                    style={{
                      marginTop: 16,
                      padding: 12,
                      borderRadius: "var(--radius-md)",
                      fontSize: 12,
                      lineHeight: 1.5,
                      background: verificationResult.startsWith("SUCCESS") ? "rgba(16, 185, 129, 0.12)" : "rgba(244, 63, 94, 0.12)",
                      border: `1px solid ${verificationResult.startsWith("SUCCESS") ? "var(--accent-emerald)" : "var(--accent-rose)"}`,
                      color: verificationResult.startsWith("SUCCESS") ? "var(--accent-emerald)" : "var(--accent-rose)",
                    }}
                  >
                    {verificationResult.replace("SUCCESS: ", "").replace("ERROR: ", "")}
                  </div>
                )}
              </div>

              <div style={{ marginTop: 24, fontSize: 11, color: "var(--text-tertiary)", borderTop: "1px solid rgba(255,255,255,0.04)", paddingTop: 16 }}>
                Chaque document généré possède un code de signature cryptographique unique stocké dans la base de données.
              </div>
            </div>
          </div>

          {/* Generated Documents History Table */}
          <div className="chart-container animate-fade-in-up" style={{ padding: 0, overflow: "hidden" }}>
            <div className="chart-header" style={{ padding: "20px 24px 16px" }}>
              <div>
                <div className="chart-title">Historique des documents générés</div>
                <p style={{ fontSize: 13, color: "var(--text-tertiary)", marginTop: 4 }}>
                  Registre en temps réel des documents officiels générés en PDF par les citoyens.
                </p>
              </div>
            </div>

            <table className="glass-table">
              <thead>
                <tr>
                  <th>Citoyen</th>
                  <th>Type de Document</th>
                  <th>Généré le</th>
                  <th>Code de Validation</th>
                  <th>Taille</th>
                  <th>Statut</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {logs.map((log) => (
                  <tr key={log.id}>
                    <td style={{ color: "white", fontWeight: 600 }}>{log.citizenName}</td>
                    <td>{log.docType}</td>
                    <td>{log.dateGenerated}</td>
                    <td style={{ fontFamily: "monospace", fontSize: 13, color: "var(--accent-cyan)" }}>
                      {log.validationCode}
                    </td>
                    <td>{log.size}</td>
                    <td>
                      <span className={`badge-status badge-${log.status}`}>
                        {log.status === "active" ? "En cours" : "Vérifié"}
                      </span>
                    </td>
                    <td>
                      <button className="btn-glass" style={{ padding: "4px 10px", fontSize: 11 }}>
                        Télécharger
                      </button>
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
