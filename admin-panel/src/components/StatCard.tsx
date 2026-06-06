"use client";

import React from "react";

type Tone = "primary" | "secondary" | "tertiary";
type Trend = "up" | "down" | "stable";

interface StatCardProps {
  icon: string;
  label: string;
  value: string;
  change: string;
  trend: Trend;
  tone: Tone;
  sparklinePath: string;
}

const toneIconClass: Record<Tone, string> = {
  primary: "bg-primary-fixed text-primary",
  secondary: "bg-secondary-fixed text-secondary",
  tertiary: "bg-tertiary-fixed text-tertiary",
};

const toneStrokeClass: Record<Tone, string> = {
  primary: "stroke-primary",
  secondary: "stroke-secondary",
  tertiary: "stroke-tertiary",
};

const trendBadgeClass: Record<Trend, string> = {
  up: "text-green-600 bg-green-50",
  down: "text-red-600 bg-red-50",
  stable: "text-secondary-container bg-secondary/10",
};

const trendIcon: Record<Trend, string> = {
  up: "trending_up",
  down: "trending_down",
  stable: "remove",
};

export default function StatCard({
  icon,
  label,
  value,
  change,
  trend,
  tone,
  sparklinePath,
}: StatCardProps) {
  return (
    <div className="glass-card p-lg rounded-xl shadow-sm group">
      <div className="flex justify-between items-start mb-md">
        <div
          className={`w-10 h-10 rounded-lg ${toneIconClass[tone]} flex items-center justify-center`}
        >
          <span className="material-symbols-outlined">{icon}</span>
        </div>
        <div
          className={`flex items-center gap-xs px-2 py-1 rounded-full text-label-md font-semibold ${trendBadgeClass[trend]}`}
        >
          <span className="material-symbols-outlined text-[14px]">
            {trendIcon[trend]}
          </span>
          <span>{change}</span>
        </div>
      </div>

      <h3 className="text-on-surface-variant font-medium text-body-sm">
        {label}
      </h3>

      <div className="flex items-baseline gap-sm mt-xs">
        <span className="font-headline-lg text-headline-lg text-on-background">
          {value}
        </span>
        <div className="flex-1 h-8 ml-md">
          <svg
            className={`w-full h-full ${toneStrokeClass[tone]} fill-none stroke-[2] opacity-40`}
            viewBox="0 0 100 30"
          >
            <path d={sparklinePath} />
          </svg>
        </div>
      </div>
    </div>
  );
}
