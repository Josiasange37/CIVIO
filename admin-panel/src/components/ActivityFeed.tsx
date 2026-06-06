"use client";

import React from "react";

export interface ActivityItem {
  id: string;
  icon: string;
  iconBg: string;
  iconColor: string;
  title: string;
  subtitle: string;
  time: string;
}

interface ActivityFeedProps {
  items: ActivityItem[];
}

export default function ActivityFeed({ items }: ActivityFeedProps) {
  return (
    <div className="glass-card rounded-xl p-lg shadow-sm">
      <div className="flex justify-between items-center mb-lg">
        <h3 className="font-headline-sm text-headline-sm text-on-background">
          Recent Activity
        </h3>
        <button className="text-primary text-label-md font-bold hover:underline">
          View All
        </button>
      </div>

      <div className="space-y-lg">
        {items.map((item, i) => {
          const showLine = i < items.length - 1;
          return (
            <div key={item.id} className="flex gap-md">
              <div className="relative">
                <div
                  className={`w-10 h-10 rounded-full ${item.iconBg} flex items-center justify-center relative z-10`}
                >
                  <span
                    className={`material-symbols-outlined text-[18px] ${item.iconColor}`}
                  >
                    {item.icon}
                  </span>
                </div>
                {showLine && (
                  <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[1px] h-full bg-outline-variant" />
                )}
              </div>
              <div className={showLine ? "pb-md" : ""}>
                <p className="text-body-sm font-medium text-on-background">
                  {item.title}
                </p>
                <p className="text-label-md text-on-surface-variant opacity-70">
                  {item.subtitle}
                </p>
                <p className="text-[11px] text-outline mt-1">{item.time}</p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
