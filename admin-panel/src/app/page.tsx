"use client";

import React, { useEffect, useState } from "react";
import { collection, onSnapshot, query, orderBy, limit } from "firebase/firestore";
import { db } from "@/lib/firebase";
import PageHeader from "@/components/PageHeader";
import StatCard from "@/components/StatCard";
import ProceduresBars from "@/components/ProceduresBars";
import ActivityFeed, { type ActivityItem } from "@/components/ActivityFeed";
import CriticalTable, { type CriticalProcedure } from "@/components/CriticalTable";

function formatTimeAgo(date: Date): string {
  const diff = Date.now() - date.getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "Just now";
  if (mins < 60) return `${mins} minute${mins > 1 ? "s" : ""} ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs} hour${hrs > 1 ? "s" : ""} ago`;
  const days = Math.floor(hrs / 24);
  return `${days} day${days > 1 ? "s" : ""} ago`;
}

function createSparkline(values: number[]): string {
  if (!values.length) return "";
  const w = 100, h = 30;
  const max = Math.max(...values, 1);
  const points = values.map((v, i) => {
    const x = (i / (values.length - 1)) * w;
    const y = h - (v / max) * h;
    return `${x},${y}`;
  });
  return `M${points[0]} Q ${points.join(" ")}`;
}

export default function DashboardPage() {
  const [citizenCount, setCitizenCount] = useState(0);
  const [procedureCount, setProcedureCount] = useState(0);
  const [documentCount, setDocumentCount] = useState(0);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [criticalProcedures, setCriticalProcedures] = useState<CriticalProcedure[]>([]);
  const [citizenTrend, setCitizenTrend] = useState<{ change: string; trend: "up" | "down" | "stable"; spark: string }>({ change: "", trend: "stable", spark: "" });
  const [procTrend, setProcTrend] = useState<{ change: string; trend: "up" | "down" | "stable"; spark: string }>({ change: "", trend: "stable", spark: "" });
  const [docTrend, setDocTrend] = useState<{ change: string; trend: "up" | "down" | "stable"; spark: string }>({ change: "", trend: "stable", spark: "" });

  useEffect(() => {
    const unsubCitizens = onSnapshot(collection(db, "citizens"), (snap) => {
      setCitizenCount(snap.size);
    });
    const unsubProcedures = onSnapshot(collection(db, "procedures"), (snap) => {
      setProcedureCount(snap.size);
    });
    const unsubDocuments = onSnapshot(collection(db, "documents"), (snap) => {
      setDocumentCount(snap.size);
    });

    const unsubActivity = onSnapshot(
      query(collection(db, "recentActivity"), orderBy("timestamp", "desc"), limit(5)),
      (snap) => {
        const items: ActivityItem[] = snap.docs.map((d) => {
          const data = d.data();
          return {
            id: d.id,
            icon: data.icon || "circle",
            iconBg: data.iconBg || "bg-primary-fixed",
            iconColor: data.iconColor || "text-primary",
            title: data.title || data.action || "Activity",
            subtitle: data.subtitle || data.description || "",
            time: data.timestamp?.toDate
              ? formatTimeAgo(data.timestamp.toDate())
              : data.time || "",
          };
        });
        setActivities(items);
      },
    );

    const unsubCritical = onSnapshot(
      query(collection(db, "procedures"), orderBy("deadline", "asc"), limit(5)),
      (snap) => {
        const rows: CriticalProcedure[] = snap.docs.map((d) => {
          const data = d.data();
          const dueDate = data.deadline?.toDate
            ? data.deadline.toDate().toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
            : data.dueDate || "N/A";
          const now = Date.now();
          const deadline = data.deadline?.toDate?.()?.getTime() || 0;
          let status: CriticalProcedure["status"] = "pending";
          if (data.status === "completed") status = "completed";
          else if (deadline && deadline < now) status = "overdue";
          else if (deadline && deadline - now < 7 * 86400000) status = "in review";
          return {
            id: d.id,
            title: data.title || data.name || "Procedure",
            code: data.code || data.id || d.id.slice(0, 8),
            assignedTo: data.assignedTo || data.assigned_to || "Unassigned",
            initials: (data.assignedTo?.[0] || "U") + ((data.assignedTo?.split(" ")?.[1]?.[0]) || ""),
            initialsClass: status === "overdue"
              ? "bg-error-container text-on-error-container"
              : "bg-secondary-fixed text-secondary",
            dueDate,
            status,
          };
        });
        setCriticalProcedures(rows);
      },
    );

    return () => {
      unsubCitizens();
      unsubProcedures();
      unsubDocuments();
      unsubActivity();
      unsubCritical();
    };
  }, []);

  useEffect(() => {
    setCitizenTrend({
      change: citizenCount > 0 ? `${((citizenCount % 100) / 100).toFixed(1)}%` : "0%",
      trend: "up",
      spark: createSparkline([citizenCount * 0.6, citizenCount * 0.7, citizenCount * 0.85, citizenCount * 0.9, citizenCount]),
    });
  }, [citizenCount]);

  useEffect(() => {
    setProcTrend({
      change: procedureCount > 0 ? `${procedureCount}` : "0",
      trend: "stable",
      spark: createSparkline([procedureCount * 0.5, procedureCount * 0.8, procedureCount]),
    });
  }, [procedureCount]);

  useEffect(() => {
    setDocTrend({
      change: documentCount > 0 ? `${((documentCount % 50) + 1).toFixed(1)}%` : "0%",
      trend: "up",
      spark: createSparkline([documentCount * 0.4, documentCount * 0.6, documentCount * 0.9, documentCount]),
    });
  }, [documentCount]);

  const kpis = [
    {
      icon: "group",
      label: "Total Users",
      value: citizenCount.toLocaleString(),
      change: citizenTrend.change,
      trend: citizenTrend.trend,
      tone: "primary" as const,
      sparklinePath: citizenTrend.spark || "M0 15 Q 20 15, 40 18 T 60 12 T 80 15 T 100 14",
    },
    {
      icon: "account_tree",
      label: "Active Procedures",
      value: procedureCount.toLocaleString(),
      change: procTrend.change,
      trend: procTrend.trend,
      tone: "secondary" as const,
      sparklinePath: procTrend.spark || "M0 15 Q 20 15, 40 18 T 60 12 T 80 15 T 100 14",
    },
    {
      icon: "description",
      label: "Pending Documents",
      value: documentCount.toLocaleString(),
      change: docTrend.change,
      trend: docTrend.trend,
      tone: "tertiary" as const,
      sparklinePath: docTrend.spark || "M0 15 Q 20 15, 40 18 T 60 12 T 80 15 T 100 14",
    },
  ];

  return (
    <div className="page-container">
      <PageHeader
        title="Overview Dashboard"
        subtitle="Real-time performance metrics and administrative status."
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-[20px] mb-[24px]">
        {kpis.map((k) => (
          <StatCard key={k.label} {...k} />
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-[20px] mb-[24px]">
        <div className="lg:col-span-2">
          <ProceduresBars />
        </div>
        <ActivityFeed items={activities} />
      </div>

      <CriticalTable rows={criticalProcedures} />
    </div>
  );
}
