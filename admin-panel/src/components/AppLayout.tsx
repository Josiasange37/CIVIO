"use client";

import React, { useState } from "react";
import { usePathname } from "next/navigation";
import Sidebar from "./Sidebar";
import TopBar from "./TopBar";

export function AppLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const pathname = usePathname();

  if (pathname === "/login") {
    return <>{children}</>;
  }

  return (
    <div className="flex min-h-screen bg-[#f5fafa]">
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Mobile top bar */}
      <TopBar onMenuToggle={() => setSidebarOpen(true)} />

      <div className="flex-1 md:ml-64">
        <main className="main-content pt-16 md:pt-0">
          {children}
        </main>
      </div>
    </div>
  );
}
