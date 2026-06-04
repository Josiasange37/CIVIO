"use client";

import React, { useEffect, useRef, useState } from "react";

/* ────────────────────────────────────────────────
   Mini SVG Chart — lightweight, no external deps
   ──────────────────────────────────────────────── */

interface MiniChartProps {
  data: number[];
  color: string;
  glow: string;
  height?: number;
  showArea?: boolean;
}

export function MiniLineChart({
  data,
  color,
  glow,
  height = 200,
  showArea = true,
}: MiniChartProps) {
  const ref = useRef<SVGSVGElement>(null);
  const [width, setWidth] = useState(600);

  useEffect(() => {
    const obs = new ResizeObserver(([entry]) =>
      setWidth(entry.contentRect.width)
    );
    if (ref.current?.parentElement) obs.observe(ref.current.parentElement);
    return () => obs.disconnect();
  }, []);

  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const padding = 20;
  const chartW = width - padding * 2;
  const chartH = height - padding * 2;

  const points = data.map((v, i) => ({
    x: padding + (i / (data.length - 1)) * chartW,
    y: padding + chartH - ((v - min) / range) * chartH,
  }));

  const linePath = points.map((p, i) => `${i === 0 ? "M" : "L"} ${p.x} ${p.y}`).join(" ");
  const areaPath = `${linePath} L ${points[points.length - 1].x} ${height - padding} L ${points[0].x} ${height - padding} Z`;

  return (
    <svg ref={ref} width="100%" height={height} style={{ display: "block" }}>
      <defs>
        <linearGradient id={`grad-${color}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.3" />
          <stop offset="100%" stopColor={color} stopOpacity="0" />
        </linearGradient>
        <filter id={`glow-${color}`}>
          <feGaussianBlur stdDeviation="4" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Grid lines */}
      {[0, 0.25, 0.5, 0.75, 1].map((ratio) => (
        <line
          key={ratio}
          x1={padding}
          y1={padding + chartH * ratio}
          x2={width - padding}
          y2={padding + chartH * ratio}
          stroke="rgba(255,255,255,0.04)"
          strokeDasharray="4 4"
        />
      ))}

      {/* Area fill */}
      {showArea && (
        <path d={areaPath} fill={`url(#grad-${color})`} />
      )}

      {/* Line */}
      <path
        d={linePath}
        fill="none"
        stroke={color}
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        filter={`url(#glow-${color})`}
      />

      {/* Dots */}
      {points.map((p, i) => (
        <circle
          key={i}
          cx={p.x}
          cy={p.y}
          r="3"
          fill={color}
          stroke="rgba(6,9,24,0.8)"
          strokeWidth="2"
          style={{ opacity: i === points.length - 1 ? 1 : 0.6 }}
        />
      ))}

      {/* Last value label */}
      <text
        x={points[points.length - 1].x + 8}
        y={points[points.length - 1].y + 4}
        fill={color}
        fontSize="12"
        fontWeight="700"
        fontFamily="Outfit, sans-serif"
      >
        {data[data.length - 1].toLocaleString()}
      </text>
    </svg>
  );
}

/* ── Bar Chart ── */

interface BarChartProps {
  data: { label: string; value: number }[];
  color: string;
  glow: string;
  height?: number;
}

export function MiniBarChart({ data, color, glow, height = 200 }: BarChartProps) {
  const max = Math.max(...data.map((d) => d.value));
  const barWidth = 100 / data.length;

  return (
    <div style={{ height, display: "flex", alignItems: "flex-end", gap: 6, padding: "0 8px" }}>
      {data.map((d, i) => {
        const h = (d.value / max) * (height - 40);
        return (
          <div
            key={i}
            style={{
              flex: 1,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 6,
            }}
          >
            <span
              style={{
                fontSize: 10,
                fontWeight: 600,
                color: "var(--text-secondary)",
                fontFamily: "Outfit, sans-serif",
              }}
            >
              {d.value}
            </span>
            <div
              style={{
                width: "100%",
                maxWidth: 32,
                height: h,
                background: `linear-gradient(180deg, ${color}, ${color}44)`,
                borderRadius: "6px 6px 2px 2px",
                boxShadow: `0 0 12px ${glow}`,
                transition: "height 0.6s cubic-bezier(0.34, 1.56, 0.64, 1)",
              }}
            />
            <span
              style={{
                fontSize: 10,
                color: "var(--text-tertiary)",
                whiteSpace: "nowrap",
              }}
            >
              {d.label}
            </span>
          </div>
        );
      })}
    </div>
  );
}
