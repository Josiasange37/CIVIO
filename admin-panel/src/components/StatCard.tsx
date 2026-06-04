"use client";

import React from "react";

interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string;
  change: string;
  positive?: boolean;
  glowColor: "emerald" | "cyan" | "purple" | "amber";
  delay?: number;
}

export default function StatCard({
  icon,
  label,
  value,
  change,
  positive = true,
  glowColor,
  delay = 0,
}: StatCardProps) {
  return (
    <div
      className={`stat-card stat-glow-${glowColor}`}
      style={{ animationDelay: `${delay}ms` }}
    >
      <div className="stat-card-icon">{icon}</div>
      <div className="stat-card-label">{label}</div>
      <div className="stat-card-value">{value}</div>
      <div className={`stat-card-change ${positive ? "positive" : "negative"}`}>
        <span>{positive ? "↑" : "↓"}</span>
        <span>{change}</span>
      </div>
    </div>
  );
}
