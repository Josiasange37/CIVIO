"use client";

import React, { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { auth, db } from "@/lib/firebase";
import { signInWithPhoneNumber, RecaptchaVerifier, ConfirmationResult } from "firebase/auth";
import { doc, setDoc, getDoc } from "firebase/firestore";

export default function LoginPage() {
  const router = useRouter();
  const [phoneNumber, setPhoneNumber] = useState("");
  const [verificationCode, setVerificationCode] = useState("");
  const [step, setStep] = useState<"phone" | "code">("phone");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [confirmationResult, setConfirmationResult] = useState<ConfirmationResult | null>(null);
  const recaptchaRef = useRef<HTMLDivElement>(null);
  const verifierRef = useRef<RecaptchaVerifier | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;

    if (!verifierRef.current && recaptchaRef.current) {
      verifierRef.current = new RecaptchaVerifier(auth, recaptchaRef.current, {
        size: "invisible",
        callback: () => {},
      });
    }

    return () => {
      verifierRef.current?.clear();
      verifierRef.current = null;
    };
  }, []);

  const handleSendCode = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneNumber) {
      setError("Veuillez saisir votre numéro de téléphone");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const fullNumber = `+237${phoneNumber.replace(/\s/g, "")}`;
      if (!verifierRef.current) {
        verifierRef.current = new RecaptchaVerifier(auth, recaptchaRef.current!, {
          size: "invisible",
          callback: () => {},
        });
      }
      const result = await signInWithPhoneNumber(auth, fullNumber, verifierRef.current);
      setConfirmationResult(result);
      setStep("code");
    } catch (err: any) {
      setError(err.message || "Erreur d'envoi du code. Vérifiez le numéro.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyCode = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!verificationCode) {
      setError("Veuillez entrer le code de validation");
      return;
    }

    setLoading(true);
    setError("");

    try {
      if (!confirmationResult) throw new Error("Aucune confirmation en cours");
      const userCred = await confirmationResult.confirm(verificationCode);

      await setDoc(doc(db, "admin_users", userCred.user.uid), {
        phone: userCred.user.phoneNumber,
        lastLogin: new Date().toISOString(),
        email: userCred.user.email || "",
      }, { merge: true });

      router.push("/");
    } catch (err: any) {
      setError(err.message || "Code invalide. Veuillez réessayer.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100vh",
        padding: "20px",
        position: "relative",
        zIndex: 1,
      }}
    >
      <div
        className="glass-card-rainbow animate-fade-in-up"
        style={{
          width: "100%",
          maxWidth: 420,
          padding: 2,
        }}
      >
        <div
          className="glass-inner"
          style={{
            padding: "40px 32px",
            display: "flex",
            flexDirection: "column",
            alignItems: "stretch",
          }}
        >
          <div style={{ textAlign: "center", marginBottom: 32 }}>
            <div
              style={{
                width: 52,
                height: 52,
                borderRadius: "var(--radius-lg)",
                background: "linear-gradient(135deg, var(--accent-emerald), var(--accent-cyan))",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                fontWeight: 800,
                fontSize: 22,
                color: "white",
                marginBottom: 16,
                boxShadow: "0 0 20px var(--accent-emerald-glow)",
              }}
            >
              C
            </div>
            <h1
              style={{
                fontFamily: "Outfit",
                fontSize: 26,
                fontWeight: 700,
                color: "white",
                letterSpacing: "-0.5px",
              }}
            >
              CIVIO Admin
            </h1>
            <p
              style={{
                fontSize: 13,
                color: "var(--text-secondary)",
                marginTop: 6,
              }}
            >
              Panel de contrôle · Procédures Cameroun
            </p>
          </div>

          {error && (
            <div
              style={{
                background: "rgba(244, 63, 94, 0.1)",
                border: "1px solid var(--accent-rose)",
                borderRadius: "var(--radius-sm)",
                padding: "10px 14px",
                fontSize: 13,
                color: "var(--accent-rose)",
                marginBottom: 20,
                textAlign: "center",
              }}
            >
              {error}
            </div>
          )}

          <div ref={recaptchaRef} />

          {step === "phone" ? (
            <form onSubmit={handleSendCode} style={{ display: "flex", flexDirection: "column", gap: 20 }}>
              <div>
                <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                  Numéro de téléphone
                </label>
                <div style={{ position: "relative" }}>
                  <span
                    style={{
                      position: "absolute",
                      left: 14,
                      top: "50%",
                      transform: "translateY(-50%)",
                      fontSize: 14,
                      fontWeight: 600,
                      color: "var(--text-secondary)",
                    }}
                  >
                    +237
                  </span>
                  <input
                    type="tel"
                    placeholder="6XX XX XX XX"
                    required
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    style={{
                      width: "100%",
                      height: 46,
                      padding: "0 16px 0 54px",
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid var(--glass-border)",
                      borderRadius: "var(--radius-md)",
                      color: "white",
                      fontSize: 15,
                      fontWeight: 600,
                      outline: "none",
                      letterSpacing: "0.5px",
                    }}
                  />
                </div>
              </div>

              <button
                type="submit"
                className="btn-primary"
                disabled={loading}
                style={{
                  height: 46,
                  justifyContent: "center",
                  fontSize: 15,
                }}
              >
                {loading ? "Envoi du code..." : "Se connecter par SMS"}
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyCode} style={{ display: "flex", flexDirection: "column", gap: 20 }}>
              <div>
                <label style={{ fontSize: 12, color: "var(--text-secondary)", display: "block", marginBottom: 6 }}>
                  Code de validation (SMS)
                </label>
                <input
                  type="text"
                  placeholder="------"
                  maxLength={6}
                  required
                  value={verificationCode}
                  onChange={(e) => setVerificationCode(e.target.value)}
                  style={{
                    width: "100%",
                    height: 46,
                    padding: "0 16px",
                    background: "rgba(255,255,255,0.03)",
                    border: "1px solid var(--glass-border)",
                    borderRadius: "var(--radius-md)",
                    color: "white",
                    fontSize: 18,
                    fontWeight: 700,
                    textAlign: "center",
                    letterSpacing: "8px",
                    outline: "none",
                  }}
                />
              </div>

              <button
                type="submit"
                className="btn-primary"
                disabled={loading}
                style={{
                  height: 46,
                  justifyContent: "center",
                  fontSize: 15,
                }}
              >
                {loading ? "Vérification..." : "Valider le code"}
              </button>

              <button
                type="button"
                onClick={() => setStep("phone")}
                style={{
                  background: "transparent",
                  border: "none",
                  color: "var(--text-secondary)",
                  fontSize: 13,
                  cursor: "pointer",
                  textAlign: "center",
                  marginTop: 4,
                }}
              >
                ← Modifier le numéro
              </button>
            </form>
          )}

          <div
            style={{
              marginTop: 28,
              borderTop: "1px solid var(--glass-border)",
              paddingTop: 16,
              fontSize: 11,
              color: "var(--text-tertiary)",
              textAlign: "center",
              lineHeight: "1.4",
            }}
          >
            Authentification par téléphone via Firebase
          </div>
        </div>
      </div>
    </div>
  );
}
