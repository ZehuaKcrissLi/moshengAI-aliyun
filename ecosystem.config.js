module.exports = {
  apps: [
    {
      name: "tts-service",
      script: "./start_tts_wrapper.sh",
      interpreter: "/bin/bash",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      error_file: "./logs/tts-service-error.log",
      out_file: "./logs/tts-service-out.log",
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: "500M",
      env: {
        NODE_ENV: "production",
        PYTHONIOENCODING: "utf-8",
        PORT: "8080"
      }
    },
    {
      name: "backend-service",
      script: "./start_backend_wrapper.sh",
      interpreter: "/bin/bash",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      error_file: "./logs/backend-error.log",
      out_file: "./logs/backend-out.log",
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: "500M",
      env: {
        NODE_ENV: "production",
        PYTHONIOENCODING: "utf-8",
        PORT: "8000"
      }
    },
    {
      name: "frontend-service",
      cwd: "./moshengAI/frontend", // 根据实际前端代码位置调整
      script: "npm",
      args: "run dev",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      error_file: "./logs/frontend-error.log",
      out_file: "./logs/frontend-out.log",
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: "300M",
      env: {
        NODE_ENV: "production",
        PORT: "5173"
      }
    }
  ]
} 