"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { auth, db } from "@/lib/firebase";
import { signInWithEmailAndPassword } from "firebase/auth";
import { doc, setDoc } from "firebase/firestore";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError("Veuillez saisir votre email et mot de passe");
      return;
    }
    setLoading(true);
    setError("");
    try {
      const userCred = await signInWithEmailAndPassword(auth, email, password);
      await setDoc(doc(db, "admin_users", userCred.user.uid), {
        email: userCred.user.email,
        lastLogin: new Date().toISOString(),
      }, { merge: true });
      router.push("/");
    } catch (err: any) {
      const msg =
        err.code === "auth/user-not-found" || err.code === "auth/wrong-password" || err.code === "auth/invalid-credential"
          ? "Email ou mot de passe incorrect"
          : err.code === "auth/invalid-email"
          ? "Format d'email invalide"
          : err.code === "auth/too-many-requests"
          ? "Trop de tentatives. Réessayez plus tard."
          : "Erreur de connexion. Vérifiez vos identifiants.";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-5 bg-[#f5fafa]">
      <div className="w-full max-w-[420px] animate-fade-in-up">
        <div className="chart-container p-8 sm:p-10 flex flex-col items-stretch">
          <div className="text-center mb-8">
            <div className="w-[52px] h-[52px] rounded-2xl bg-primary flex items-center justify-center font-extrabold text-[22px] text-white mx-auto mb-4 shadow-lg">
              C
            </div>
            <h1 className="text-[26px] font-bold text-primary font-headline tracking-tight">
              CIVIO Admin
            </h1>
            <p className="text-body-sm text-on-surface-variant mt-1.5">
              Panel de contrôle · Procédures Cameroun
            </p>
          </div>

          {error && (
            <div className="bg-error-container border border-error rounded-lg px-3.5 py-2.5 text-body-sm text-on-error-container mb-5 text-center">
              {error}
            </div>
          )}

          <form onSubmit={handleLogin} className="flex flex-col gap-5">
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                Email
              </label>
              <input
                type="email"
                placeholder="admin@civio.cm"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full h-[46px] px-4 bg-surface border border-outline-variant rounded-xl text-body-md text-on-surface outline-none"
              />
            </div>
            <div>
              <label className="font-label-md text-label-md text-on-surface-variant block mb-1.5">
                Mot de passe
              </label>
              <input
                type="password"
                placeholder="••••••••"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-[46px] px-4 bg-surface border border-outline-variant rounded-xl text-body-md text-on-surface outline-none"
              />
            </div>
            <button
              type="submit"
              disabled={loading}
              className="btn-primary w-full h-[46px] justify-center text-[15px]"
            >
              {loading ? "Connexion..." : "Se connecter"}
            </button>
          </form>

          <div className="mt-7 pt-4 border-t border-outline-variant text-[11px] text-on-surface-variant opacity-70 text-center leading-tight">
            Authentification via Firebase
          </div>
        </div>
      </div>
    </div>
  );
}
