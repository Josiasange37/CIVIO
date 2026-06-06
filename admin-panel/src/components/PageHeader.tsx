"use client";

import React from "react";

interface PageHeaderProps {
  title: string;
  subtitle?: string;
}

export default function PageHeader({ title, subtitle }: PageHeaderProps) {
  return (
    <div className="flex justify-between items-end mb-xl">
      <div>
        <h2 className="font-headline-lg text-headline-lg text-primary">{title}</h2>
        {subtitle && (
          <p className="text-on-surface-variant mt-1 text-body-sm">{subtitle}</p>
        )}
      </div>
      <div className="flex gap-sm">
        <button className="px-md py-sm glass-card rounded-lg flex items-center gap-xs font-medium text-on-surface-variant hover:bg-surface-container-highest transition-colors text-body-sm">
          <span className="material-symbols-outlined text-[20px]">calendar_today</span>
          <span>Last 30 Days</span>
        </button>
        <button className="px-md py-sm glass-card rounded-lg flex items-center gap-xs font-medium text-on-surface-variant hover:bg-surface-container-highest transition-colors text-body-sm">
          <span className="material-symbols-outlined text-[20px]">filter_list</span>
          <span>Filters</span>
        </button>
      </div>
    </div>
  );
}
