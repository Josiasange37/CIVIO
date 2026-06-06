"use client";

import React, { useEffect, useState } from "react";
import { collection, onSnapshot } from "firebase/firestore";
import { db } from "@/lib/firebase";

interface Day {
  label: string;
  newCases: number;
  resolved: number;
}

const DAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export default function ProceduresBars() {
  const [days, setDays] = useState<Day[]>([]);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, "recentActivity"), (snap) => {
      const dayBuckets: Record<number, { newCases: number; resolved: number }> = {};
      for (let i = 0; i < 7; i++) {
        dayBuckets[i] = { newCases: 0, resolved: 0 };
      }

      snap.docs.forEach((d) => {
        const data = d.data();
        const ts = data.timestamp?.toDate?.();
        if (!ts) return;
        const dayIdx = ts.getDay();
        const day = (dayIdx + 6) % 7;

        const action = (data.action || data.title || "").toLowerCase();
        if (action.includes("new") || action.includes("create") || action.includes("début") || action.includes("nouveau")) {
          dayBuckets[day].newCases += 1;
        } else if (action.includes("complete") || action.includes("done") || action.includes("fini") || action.includes("résolu")) {
          dayBuckets[day].resolved += 1;
        } else if (data.status === "completed") {
          dayBuckets[day].resolved += 1;
        } else {
          dayBuckets[day].newCases += 1;
        }
      });

      const maxVal = Math.max(
        ...Object.values(dayBuckets).map((b) => Math.max(b.newCases, b.resolved, 1)),
      );

      const result: Day[] = DAY_LABELS.map((label, i) => ({
        label,
        newCases: Math.round((dayBuckets[i].newCases / maxVal) * 100),
        resolved: Math.round((dayBuckets[i].resolved / maxVal) * 100),
      }));

      setDays(result);
    });

    return () => unsub();
  }, []);

  return (
    <div className="glass-card rounded-xl p-lg shadow-sm">
      <div className="flex justify-between items-center mb-xl">
        <div>
          <h3 className="font-headline-sm text-headline-sm text-on-background">
            Procedures Overview
          </h3>
          <p className="text-body-sm text-on-surface-variant">
            Volume of new vs. resolved cases
          </p>
        </div>
        <div className="flex items-center gap-md">
          <div className="flex items-center gap-xs">
            <div className="w-3 h-3 rounded-full bg-primary" />
            <span className="text-label-md font-semibold text-on-surface-variant">
              New Cases
            </span>
          </div>
          <div className="flex items-center gap-xs">
            <div className="w-3 h-3 rounded-full bg-secondary-fixed-dim" />
            <span className="text-label-md font-semibold text-on-surface-variant">
              Resolved
            </span>
          </div>
        </div>
      </div>

      <div className="h-64 flex items-end justify-between gap-sm relative pb-8">
        <div className="absolute left-0 bottom-0 w-full h-[1px] bg-outline-variant" />

        {days.length === 0 ? (
          <div className="w-full text-center text-on-surface-variant text-body-sm py-12">
            No activity data yet.
          </div>
        ) : (
          days.map((d) => (
            <div
              key={d.label}
              className="flex flex-col items-center gap-xs w-full relative"
            >
              <div
                className="w-full max-w-[40px] bg-primary rounded-t-lg transition-all hover:opacity-80"
                style={{ height: `${d.newCases}%` }}
              />
              <div
                className="w-full max-w-[40px] bg-secondary-fixed-dim rounded-t-lg transition-all hover:opacity-80"
                style={{ height: `${d.resolved}%` }}
              />
              <span className="absolute -bottom-6 text-label-md opacity-60 font-medium text-on-surface-variant">
                {d.label}
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
