# Next.js 15.3 + Supabase + TypeScript + Docker Starter

A modern, production-ready starter template for building full-stack applications with Next.js 15.3, Supabase, TypeScript, Tailwind CSS v4, and Docker deployment.

## 🚀 Features

- **Next.js 15.3** with App Router and Server Components
- **Supabase** for authentication and database (hosted)
- **TypeScript** with strict mode for type safety
- **Tailwind CSS v4** for modern styling
- **shadcn/ui** component library
- **Docker** - Production-ready containerization with dev/prod modes
- **Authentication** - Complete auth flow with sign up, sign in, and protected routes
- **Database Migrations** - Migration-first development with type generation
- **Vitest** for testing
- **Zod** for schema validation
- Pre-configured development tools (ESLint, Prettier)

## 📋 Prerequisites

**Choose your development approach:**

### Option A: Docker (Recommended)
- [Docker Desktop](https://docs.docker.com/get-docker/) installed and running
- A Supabase account at [supabase.com](https://supabase.com)

### Option B: Local Development
- Node.js 18+ 
- npm/yarn/pnpm
- Supabase CLI (`brew install supabase/tap/supabase`)

## 🛠️ Getting Started

### 1. Clone and Install

```bash
git clone <your-repo-url>
cd my-app
npm install
```

### 2. Set Up Supabase

**Create a Supabase project:**

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Go to Settings → API in your Supabase dashboard
3. Copy your Project URL and API keys

### 3. Configure Environment

**For Docker development:**
```bash
# Copy the template
cp .env.local.example .env.local

# Edit .env.local with your Supabase credentials
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

**For production deployment:**
```bash
# Copy the production template
cp .env.production.example .env.production

# Edit .env.production with your production Supabase credentials
```

**For local development (without Docker):**
```bash
# Copy both templates
cp .env.local.example .env.local
cp .env.development.example .env.development

# Edit both files with your Supabase credentials
```

### 4. Run Development Server

**With Docker (Recommended):**
```bash
# Development mode (hot reload, source mapping)
npm run docker:dev

# Production mode (optimized build)
npm run docker:prod

# Stop containers
npm run docker:stop

# Clean up containers and volumes
npm run docker:clean
```

**Without Docker:**
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see your app.

### Docker Commands

```bash
# Development workflow
npm run docker:dev    # Start dev container with hot reload
npm run docker:stop   # Stop all containers
npm run docker:clean  # Remove containers, volumes, and prune system

# Production deployment
npm run docker:prod   # Build and run production container
npm run docker:build  # Build production image only

# Container logs
docker logs next-supabase-app -f  # Follow logs
docker logs next-supabase-app     # View recent logs
```

## 📁 Project Structure

```
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth routes (signin, signup)
│   ├── (dashboard)/       # Protected dashboard routes
│   └── layout.tsx         # Root layout
├── components/            
│   ├── ui/                # shadcn/ui components
│   └── features/          # Feature-specific components
│       └── auth/          # Auth form components
├── lib/
│   ├── supabase/         # Supabase client configs
│   ├── env.ts            # Environment validation
│   └── utils.ts          # Utility functions
├── server/
│   ├── actions/          # Server Actions
│   │   └── auth.ts       # Auth actions (signUp, signIn, signOut)
│   └── queries/          # Database queries
├── hooks/                # React hooks
├── supabase/
│   ├── migrations/       # Database migrations
│   └── config.toml       # Supabase configuration
├── types/                # TypeScript types
│   └── supabase.ts       # Generated DB types
└── middleware.ts         # Auth middleware
```

## 🔧 Available Scripts

```bash
# Development
npm run dev              # Start dev server with Turbopack
npm run build           # Build for production
npm run start           # Start production server
npm run lint            # Run ESLint

# Docker
npm run docker:dev      # Start development container
npm run docker:prod     # Start production container
npm run docker:build    # Build production image
npm run docker:stop     # Stop containers
npm run docker:clean    # Clean containers and volumes

# Database
npm run db:start        # Start local Supabase
npm run db:stop         # Stop local Supabase
npm run db:reset        # Reset database
npm run db:types        # Generate TypeScript types
npm run db:push         # Push migrations to remote

# Testing
npm run test            # Run tests in watch mode
npm run test:ui         # Open Vitest UI
```

## 🏗️ Development Workflow

### Docker Development

**First time setup:**
```bash
# 1. Set up environment
cp .env.local.example .env.local
# Edit .env.local with your Supabase credentials

# 2. Start development
npm run docker:dev
```

**Daily development:**
```bash
npm run docker:dev    # Start containers
# Your code changes will be reflected immediately
npm run docker:stop   # Stop when done
```

**Troubleshooting:**
```bash
npm run docker:clean  # Clean everything and start fresh
npm run docker:dev    # Rebuild and start
```

### Database Changes

1. Create a migration:
```bash
supabase migration new create_posts_table
```

2. Apply locally and regenerate types:
```bash
npm run db:reset
npm run db:types
```

### Adding UI Components

```bash
npx shadcn@latest add button card dialog
```

### Creating Features

1. Use Server Components by default
2. Add `'use client'` only when needed
3. Separate server and client Supabase instances
4. Use Server Actions for mutations

## 🧪 Testing

Write tests for:
- Business logic in utilities and hooks
- Server Actions with mocked Supabase
- Component behavior (not visual appearance)
- Error states and edge cases

```bash
npm run test
```

## 📚 Key Concepts

### Server Components First

```typescript
// ✅ Server Component (default)
export default async function Page() {
  const data = await getServerData()
  return <ClientComponent initialData={data} />
}
```

### Supabase Client Separation

```typescript
// Client-side (browser)
import { createClient } from '@/lib/supabase/client'

// Server-side (Node.js)
import { createClient } from '@/lib/supabase/server'
```

### Type-Safe Database Queries

```typescript
import type { Database } from '@/types/supabase'

type Post = Database['public']['Tables']['posts']['Row']
```

### Authentication Flow

The starter includes a complete auth setup:
- Sign up/in pages at `/signup` and `/signin`
- Protected routes under `(dashboard)`
- Server actions for auth operations
- Automatic profile creation on signup
- Session management via middleware

## 🐳 Docker Architecture

This project includes a sophisticated Docker setup that supports both development and production:

### Multi-Stage Dockerfile
- **Smart build detection**: Automatically detects pnpm, npm, or yarn
- **Development mode**: Hot reload with volume mounting
- **Production mode**: Optimized build with health checks
- **Security**: Non-root user, minimal attack surface

### Environment-Based Builds
- **Development**: `NODE_ENV=development` - No build step, fast startup
- **Production**: `NODE_ENV=production` - Optimized build, standalone deployment

### Health Checks
Both dev and production containers include health checks on port 3000.

## 🚨 Important Guidelines

1. **Always regenerate types** after schema changes
2. **Use migrations** for all database changes  
3. **Enable RLS** on all tables
4. **Validate environment variables** with Zod
5. **Test business logic**, not implementation details
6. **Use Docker for consistent environments** across team members

## 📝 Environment Variables

Required environment variables:

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

## 🤝 Contributing

1. Create feature branch
2. Make changes following the patterns in CLAUDE.md
3. Write/update tests
4. Submit PR

## 📄 License

MIT