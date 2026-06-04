const fs = require('fs');

let css = fs.readFileSync('/home/almight/ekema/admin-panel/src/app/globals.css', 'utf8');

const lightVars = `
.light {
  --bg-primary: #f8fafc;
  --bg-secondary: #ffffff;
  --bg-tertiary: #f1f5f9;

  --glass-bg: rgba(255, 255, 255, 0.7);
  --glass-bg-hover: rgba(255, 255, 255, 0.9);
  --glass-bg-active: rgba(255, 255, 255, 1);
  --glass-border: rgba(0, 0, 0, 0.05);
  --glass-border-hover: rgba(0, 0, 0, 0.1);
  --glass-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);

  --liquid-refract: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.5) 0%,
    rgba(255, 255, 255, 0.0) 40%,
    rgba(255, 255, 255, 0.3) 60%,
    rgba(255, 255, 255, 0.0) 100%
  );
  --liquid-shine: linear-gradient(
    105deg,
    transparent 40%,
    rgba(255, 255, 255, 0.6) 45%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 55%
  );

  --text-primary: #0f172a;
  --text-secondary: #475569;
  --text-tertiary: #94a3b8;
  
  --accent-emerald-glow: rgba(16, 185, 129, 0.15);
  --accent-cyan-glow: rgba(6, 182, 212, 0.15);
  --accent-purple-glow: rgba(139, 92, 246, 0.15);
  --accent-amber-glow: rgba(245, 158, 11, 0.15);
  --accent-rose-glow: rgba(244, 63, 94, 0.15);
  --accent-blue-glow: rgba(59, 130, 246, 0.15);
}

.light .sidebar {
  background: rgba(255, 255, 255, 0.85);
  border-right: 1px solid var(--glass-border);
}

.light .topbar {
  background: rgba(255, 255, 255, 0.6);
}

.light .orb {
  opacity: 0.15;
}
`;

css = css.replace(
  /:root {([^}]*)}/, 
  (match) => match + '\n' + lightVars
);

fs.writeFileSync('/home/almight/ekema/admin-panel/src/app/globals.css', css);
