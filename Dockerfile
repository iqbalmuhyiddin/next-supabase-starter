# Smart Dockerfile for Next.js 15.3 + Supabase (Dev/Prod in one)
FROM node:20-alpine AS base

# Build argument to determine environment
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i$(if [ "$NODE_ENV" = "production" ]; then echo " --frozen-lockfile"; fi); \
  elif [ -f package-lock.json ]; then npm ci$(if [ "$NODE_ENV" = "production" ]; then echo ""; else echo " --include=dev"; fi); \
  else echo "Lockfile not found." && exit 1; \
  fi

# Conditional builder stage (only for production)
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

# Only build in production
RUN \
  if [ "$NODE_ENV" = "production" ]; then \
    if [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm build; \
    else npm run build; \
    fi \
  fi

# Runtime stage
FROM base AS runner
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Production: Copy built application
# Development: Copy dependencies and source (will be volume mounted)
RUN \
  if [ "$NODE_ENV" = "production" ]; then \
    echo "Setting up production runtime..."; \
  else \
    echo "Setting up development runtime..."; \
  fi

COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules

# Production: Copy built application files
# Development: Skip copying, files will be volume mounted
RUN \
  if [ "$NODE_ENV" = "production" ]; then \
    echo "Production: Will copy built files..."; \
  else \
    echo "Development: Skipping build files (will use volume mount)"; \
  fi

# Production build stage to copy artifacts from
FROM builder AS production-artifacts

# Production runner
FROM runner AS production-runner
COPY --from=production-artifacts --chown=nextjs:nodejs /app/public ./public
COPY --from=production-artifacts --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=production-artifacts --chown=nextjs:nodejs /app/.next/static ./.next/static

# Development runner (no build artifacts needed)
FROM runner AS development-runner
RUN mkdir -p ./public ./.next && chown -R nextjs:nodejs ./public ./.next

# Add health check and common setup to both stages
FROM production-runner AS production-final
RUN echo '#!/usr/bin/env node\nconst http = require("http");\nconst options = { host: "localhost", port: 3000, timeout: 2000 };\nconst request = http.request(options, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); });\nrequest.on("error", () => process.exit(1));\nrequest.end();' > healthcheck.js
USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD node healthcheck.js
CMD ["node", "server.js"]

FROM development-runner AS development-final
RUN echo '#!/usr/bin/env node\nconst http = require("http");\nconst options = { host: "localhost", port: 3000, timeout: 2000 };\nconst request = http.request(options, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); });\nrequest.on("error", () => process.exit(1));\nrequest.end();' > healthcheck.js
USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD node healthcheck.js
CMD ["npm", "run", "dev"]