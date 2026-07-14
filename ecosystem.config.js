// ──────────────────────────────────────────────
// PM2 Ecosystem Configuration
// ──────────────────────────────────────────────
// Manages application processes on the production
// server. Applications run natively (not in Docker).
//
// Env file: /etc/orivastra.env contains secrets
// and per-environment overrides (not committed).
//
// Usage:
//   pm2 start ecosystem.config.js
//   pm2 restart ecosystem.config.js
//   pm2 logs
//   pm2 save && pm2 startup   (enable auto-start on boot)
// ──────────────────────────────────────────────

module.exports = {
  apps: [
    {
      name: 'backend',
      cwd: './apps/backend',
      script: 'dist/main.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: '3001',
      },
      env_file: '/etc/orivastra.env',
      kill_timeout: 5000,
      error_file: './logs/backend.err.log',
      out_file: './logs/backend.out.log',
      merge_logs: true,
    },
    {
      name: 'frontend',
      cwd: './apps/frontend',
      script: 'node_modules/.bin/next',
      args: 'start',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: '3000',
      },
      env_file: '/etc/orivastra.env',
      kill_timeout: 5000,
      error_file: './logs/frontend.err.log',
      out_file: './logs/frontend.out.log',
      merge_logs: true,
    },
  ],
};
