"use client";

import React from "react";
import { useAuth } from "@/lib/AuthContext";

interface TopBarProps {
  onMenuToggle: () => void;
}

export default function TopBar({ onMenuToggle }: TopBarProps) {
  const { user, logout } = useAuth();

  return (
    <header className="h-16 lg:hidden flex items-center justify-between px-4 bg-surface border-b border-outline-variant sticky top-0 z-40">
      <div className="flex items-center gap-3">
        <button
          onClick={onMenuToggle}
          className="w-10 h-10 flex items-center justify-center rounded-lg text-on-surface-variant hover:bg-surface-container-high transition-colors"
          aria-label="Open menu"
        >
          <span className="material-symbols-outlined">menu</span>
        </button>
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
            <span
              className="material-symbols-outlined text-white text-sm"
              style={{ fontVariationSettings: "'FILL' 1" }}
            >
              account_balance
            </span>
          </div>
          <div>
            <span className="font-bold text-primary text-sm leading-none">Civio</span>
            <p className="text-[10px] text-on-surface-variant opacity-70 uppercase tracking-widest leading-tight">
              Civic Admin
            </p>
          </div>
        </div>
      </div>

      <div className="flex items-center gap-2">
        <button
          onClick={logout}
          className="w-9 h-9 flex items-center justify-center rounded-lg text-on-surface-variant hover:bg-surface-container-high transition-colors"
          aria-label="Sign out"
        >
          <span className="material-symbols-outlined text-[20px]">logout</span>
        </button>
        {user && (
          <div className="w-8 h-8 rounded-full bg-primary-fixed-dim text-primary flex items-center justify-center text-xs font-bold">
            {(user.email || user.phoneNumber || "A")[0].toUpperCase()}
          </div>
        )}
      </div>
    </header>
  );
}
