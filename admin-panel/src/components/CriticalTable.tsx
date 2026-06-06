"use client";

import React from "react";

export interface CriticalProcedure {
  id: string;
  title: string;
  code: string;
  assignedTo: string;
  initials: string;
  initialsClass: string;
  dueDate: string;
  status: "overdue" | "in review" | "pending" | "completed";
}

interface CriticalTableProps {
  rows: CriticalProcedure[];
}

const statusPill: Record<CriticalProcedure["status"], string> = {
  overdue: "bg-error-container text-on-error-container",
  pending: "bg-secondary-container text-on-secondary-container",
  "in review": "bg-secondary-container text-on-secondary-container",
  completed: "bg-primary-fixed text-primary",
};

const statusLabel: Record<CriticalProcedure["status"], string> = {
  overdue: "Overdue",
  pending: "Pending",
  "in review": "In Review",
  completed: "Completed",
};

export default function CriticalTable({ rows }: CriticalTableProps) {
  return (
    <div className="mt-gutter glass-card rounded-xl overflow-hidden shadow-sm">
      <div className="p-lg border-b border-outline-variant flex justify-between items-center">
        <h3 className="font-headline-sm text-headline-sm text-on-background">
          Critical Procedures
        </h3>
        <select
          className="bg-transparent border border-outline-variant rounded-lg text-body-sm py-1.5 px-3 focus:ring-primary focus:outline-none text-on-background"
          defaultValue="high"
        >
          <option value="high">High Priority</option>
          <option value="medium">Medium Priority</option>
        </select>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left">
          <thead>
            <tr className="bg-surface-container-low text-on-surface-variant text-label-md border-b border-outline-variant">
              <th className="px-lg py-md font-medium">PROCEDURE NAME</th>
              <th className="px-lg py-md font-medium">ASSIGNED TO</th>
              <th className="px-lg py-md font-medium">DUE DATE</th>
              <th className="px-lg py-md font-medium">STATUS</th>
              <th className="px-lg py-md font-medium">ACTIONS</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-outline-variant">
            {rows.map((row) => (
              <tr
                key={row.id}
                className="hover:bg-primary-fixed/30 transition-colors"
              >
                <td className="px-lg py-md">
                  <div className="flex flex-col">
                    <span className="font-medium text-body-sm text-on-background">
                      {row.title}
                    </span>
                    <span className="text-[12px] text-on-surface-variant">
                      ID: {row.code}
                    </span>
                  </div>
                </td>
                <td className="px-lg py-md">
                  <div className="flex items-center gap-sm">
                    <div
                      className={`w-6 h-6 rounded-full ${row.initialsClass} text-[10px] flex items-center justify-center font-bold`}
                    >
                      {row.initials}
                    </div>
                    <span className="text-body-sm text-on-background">
                      {row.assignedTo}
                    </span>
                  </div>
                </td>
                <td className="px-lg py-md text-body-sm text-on-surface-variant">
                  {row.dueDate}
                </td>
                <td className="px-lg py-md">
                  <span
                    className={`px-sm py-xs rounded-full text-[11px] font-bold uppercase ${statusPill[row.status]}`}
                  >
                    {statusLabel[row.status]}
                  </span>
                </td>
                <td className="px-lg py-md">
                  <button className="material-symbols-outlined text-outline hover:text-primary transition-colors">
                    more_vert
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
