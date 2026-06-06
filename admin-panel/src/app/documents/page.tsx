"use client";

import React, { useState, useEffect } from "react";
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
    <div className="page-container">
      <div className="page-header animate-fade-in-up">
        <div>
          <h1 className="page-title">Documents & Modèles</h1>
          <p className="page-subtitle">
            Gérez les templates de formulaires administratifs et vérifiez l&apos;authenticité des documents générés.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6 mb-8 stagger">
        <div className="lg:col-span-3 chart-container p-6">
          <h2 className="text-headline-md font-bold text-on-surface mb-4">
            Modèles de documents disponibles (Offline)
          </h2>
          <div className="flex flex-col gap-3">
            {templates.map((tpl) => (
              <div
                key={tpl.id}
                className="flex items-center justify-between p-3.5 bg-surface border border-outline-variant rounded-xl hover:bg-surface-container-high transition-colors"
              >
                <div>
                  <div className="font-semibold text-body-md text-on-surface">{tpl.title}</div>
                  <div className="text-body-sm text-on-surface-variant mt-1">{tpl.desc}</div>
                </div>
                <span className="text-[11px] font-bold text-accent-purple bg-accent-purple-glow px-2 py-0.5 rounded-xl flex-shrink-0 ml-2">
                  {tpl.count}
                </span>
              </div>
            ))}
            {templates.length === 0 && (
              <div className="text-body-sm text-on-surface-variant italic">
                Aucun modèle disponible. Ajoutez-en dans la collection <strong>documentTemplates</strong>.
              </div>
            )}
          </div>
        </div>

        <div className="lg:col-span-2 chart-container p-6 flex flex-col justify-between">
          <div>
            <h2 className="text-headline-md font-bold text-accent-emerald mb-3">
              Vérificateur d&apos;authenticité CIVIO
            </h2>
            <p className="text-body-sm text-on-surface-variant mb-4">
              Saisissez le code de validation imprimé au bas du document généré pour authentifier sa provenance.
            </p>

            <form onSubmit={handleVerify} className="flex flex-col gap-3">
              <input
                type="text"
                placeholder="Code de validation (ex: CIVIO-8392-CM)"
                value={verifyCode}
                onChange={(e) => setVerifyCode(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-surface border border-outline-variant rounded-xl text-body-sm text-on-surface outline-none"
              />
              <button type="submit" className="btn-primary self-start">
                Vérifier le document
              </button>
            </form>

            {verificationResult && (
              <div
                className="mt-4 p-3 rounded-xl text-body-sm leading-relaxed"
                style={{
                  background: verificationResult.startsWith("SUCCESS")
                    ? "rgba(16, 185, 129, 0.12)"
                    : "rgba(244, 63, 94, 0.12)",
                  border: `1px solid ${
                    verificationResult.startsWith("SUCCESS")
                      ? "var(--accent-emerald)"
                      : "var(--accent-rose)"
                  }`,
                  color: verificationResult.startsWith("SUCCESS")
                    ? "var(--accent-emerald)"
                    : "var(--accent-rose)",
                }}
              >
                {verificationResult.replace("SUCCESS: ", "").replace("ERROR: ", "")}
              </div>
            )}
          </div>

          <div className="mt-6 text-[11px] text-on-surface-variant opacity-70 border-t border-outline-variant pt-4">
            Chaque document généré possède un code de signature cryptographique unique stocké dans la base de données.
          </div>
        </div>
      </div>

      <div className="chart-container animate-fade-in-up overflow-hidden">
        <div className="chart-header">
          <div>
            <div className="chart-title">Historique des documents générés</div>
            <p className="text-body-sm text-on-surface-variant mt-1">
              Registre en temps réel des documents officiels générés en PDF par les citoyens.
            </p>
          </div>
        </div>

        <div className="table-responsive">
          <table className="glass-table">
            <thead>
              <tr>
                <th>Citoyen</th>
                <th>Type de Document</th>
                <th className="hide-mobile">Généré le</th>
                <th>Code de Validation</th>
                <th className="hide-mobile">Taille</th>
                <th>Statut</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {logs.map((log) => (
                <tr key={log.id}>
                  <td className="font-semibold text-on-surface">{log.citizenName}</td>
                  <td>{log.docType}</td>
                  <td className="hide-mobile">{log.dateGenerated}</td>
                  <td className="font-mono text-body-sm text-accent-cyan">{log.validationCode}</td>
                  <td className="hide-mobile">{log.size}</td>
                  <td>
                    <span className={`badge-status badge-${log.status}`}>
                      {log.status === "active" ? "En cours" : "Vérifié"}
                    </span>
                  </td>
                  <td>
                    <button className="btn-glass text-[11px] px-2.5 py-1">
                      Télécharger
                    </button>
                  </td>
                </tr>
              ))}
              {logs.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center text-on-surface-variant italic py-8">
                    Aucun document généré pour le moment.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
