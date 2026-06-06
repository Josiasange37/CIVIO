"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/lib/AuthContext";

const navItems = [
  { label: "Dashboard", href: "/", icon: "dashboard" },
  { label: "Procedures", href: "/procedures", icon: "account_tree" },
  { label: "Documents", href: "/documents", icon: "description" },
  { label: "Analytics", href: "/analytics", icon: "analytics" },
  { label: "Map", href: "/map", icon: "map" },
  { label: "Users", href: "/users", icon: "group" },
  { label: "Settings", href: "/settings", icon: "settings" },
];

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

export default function Sidebar({ open, onClose }: SidebarProps) {
  const pathname = usePathname();
  const { logout, user } = useAuth();

  const isActive = (href: string) =>
    href === "/" ? pathname === "/" : pathname.startsWith(href);

  const sidebarContent = (
    <aside
      className={[
        "h-full bg-surface border-r border-outline-variant shadow-sm flex flex-col p-md z-50",
        "w-64",
      ].join(" ")}
    >
      <div className="flex items-center gap-sm mb-xl px-sm">
        <div className="w-10 h-10 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
          <span
            className="material-symbols-outlined text-white"
            style={{ fontVariationSettings: "'FILL' 1" }}
          >
            account_balance
          </span>
        </div>
        <div>
          <h1 className="font-headline-md text-headline-md font-bold text-primary leading-none">
            Civio
          </h1>
          <p className="font-label-md text-label-md text-on-surface-variant opacity-70 uppercase tracking-widest mt-1">
            Civic Admin
          </p>
        </div>
      </div>

      <nav className="flex-1 space-y-1">
        {navItems.map((item) => {
          const active = isActive(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onClose}
              className={[
                "flex items-center gap-md px-md py-sm rounded-lg",
                "transition-transform duration-150 active:scale-95",
                active
                  ? "text-primary bg-primary-fixed font-bold"
                  : "text-on-surface-variant hover:bg-surface-container-high transition-colors",
              ].join(" ")}
            >
              <span
                className="material-symbols-outlined"
                style={{ fontVariationSettings: active ? "'FILL' 1" : "'FILL' 0" }}
              >
                {item.icon}
              </span>
              <span className="text-body-sm">{item.label}</span>
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto pt-lg space-y-1 border-t border-outline-variant">
        {user && (
          <div className="px-md py-sm flex items-center gap-sm">
            <div className="w-7 h-7 rounded-full bg-primary-fixed-dim text-primary flex items-center justify-center text-xs font-bold flex-shrink-0">
              {user.email?.[0]?.toUpperCase() || "A"}
            </div>
            <span className="text-body-sm text-on-surface-variant truncate">
              {user.phoneNumber || user.email || "Admin"}
            </span>
          </div>
        )}
        <div className="px-md py-sm">
          <button
            onClick={logout}
            className="w-full py-sm px-md bg-surface-container-high text-on-surface-variant rounded-lg font-medium hover:bg-error-container hover:text-on-error-container transition-all text-body-sm flex items-center justify-center gap-sm"
          >
            <span className="material-symbols-outlined text-[18px]">logout</span>
            Sign Out
          </button>
        </div>
      </div>
    </aside>
  );

  return (
    <>
      {/* Desktop sidebar */}
      <div className="hidden md:block fixed left-0 top-0 h-full z-50">
        {sidebarContent}
      </div>

      {/* Mobile sidebar overlay */}
      {open && (
        <div className="sidebar-overlay md:hidden" onClick={onClose} />
      )}

      {/* Mobile sidebar drawer */}
      <div
        className={[
          "md:hidden fixed left-0 top-0 h-full z-50 transition-transform duration-300",
          open ? "translate-x-0" : "-translate-x-full",
        ].join(" ")}
      >
        {sidebarContent}
      </div>
    </>
  );
}
