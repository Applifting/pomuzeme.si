apiVersion: v1
kind: Secret
metadata:
  name: pomuzeme-si-env
data:
  SECRET_KEY_BASE: ${SECRET_KEY_BASE}
  DATABASE_URL: ${DATABASE_URL}
  SENTRY_DSN: ${SENTRY_DSN}
