# Supabase MCP Setup for New Projects

## 🚀 Quick Start Guide

### Step 1: Create Project Structure
```bash
my-new-app/
├── .cursor/
│   └── rules/
│       ├── 00-project-context.mdc      # Project-specific context
│       ├── 01-business-rules.mdc       # Domain logic
│       ├── 02-team-conventions.mdc     # Team preferences  
│       └── 99-personal-profile.mdc     # Your MCP tools config
├── supabase/
│   ├── config.toml                     # Supabase config
│   ├── migrations/                     # Database migrations
│   └── seed.sql                        # Initial data
├── src/                                # Your app code
├── docs/                               # Documentation
└── README.md
```

### Step 2: Configure Supabase MCP in Cursor Rules

Add to your `.cursor/rules/99-personal-profile.mdc`:

```markdown
## Available MCP Tools

### Supabase Integration
- **Supabase MCP**: Database and backend services
  - Use for: Database setup, API generation, authentication, migrations
  - Commands: 
    - `mcp_supabase_create_project`
    - `mcp_supabase_list_tables` 
    - `mcp_supabase_execute_sql`
    - `mcp_supabase_apply_migration`
    - `mcp_supabase_generate_typescript_types`

### Natural Language Database Operations
You can now use plain English for database operations:
- "Create a users table with email and password fields"
- "Add a posts table linked to users"
- "Generate TypeScript types for my database"
- "Create a migration for adding user profiles"
- "Show me all tables in my database"
```

### Step 3: Project Configuration

Create `supabase-config.json`:
```json
{
  "projects": {
    "MyApp": {
      "id": "YOUR_PROJECT_ID",
      "region": "ap-southeast-2",
      "status": "ACTIVE_HEALTHY",
      "gitops": {
        "migration_path": "supabase/migrations/",
        "schema_docs_path": "docs/database/",
        "auto_generate_types": true,
        "auto_generate_docs": true
      }
    }
  },
  "gitops": {
    "default_project": "MyApp",
    "auto_commit": false,
    "require_review": true,
    "security_checks": true
  }
}
```

### Step 4: How Cursor Uses It

#### Natural Language Database Operations
```bash
# You say this to Cursor:
"Create a blog application database schema"

# Cursor understands and executes:
1. Creates users table
2. Creates posts table  
3. Creates comments table
4. Sets up relationships
5. Applies RLS policies
6. Generates TypeScript types
7. Creates migration files
8. Updates documentation
```

#### Automatic Integration
```bash
# You say:
"Add authentication to my app"

# Cursor does:
1. Enables Supabase Auth
2. Generates auth components
3. Creates protected routes
4. Sets up user management
5. Integrates with your existing schema
```

### Step 5: Development Workflow

#### Making Changes
```bash
# Natural language commands:
"Add a 'bio' field to the user profile"
"Create a likes table for posts"  
"Add full-text search to posts"
"Generate API documentation"

# Cursor automatically:
- Creates migration files
- Updates TypeScript types
- Modifies API endpoints
- Updates documentation
- Runs tests
```

## 🎯 Benefits for New Projects

### 1. Zero Configuration
- Cursor recognizes MCP tools automatically
- No manual SDK setup required
- Built-in best practices

### 2. Natural Language Development
- Speak your requirements naturally
- No need to remember SQL syntax
- Automatic code generation

### 3. Full Stack Integration
- Database changes → TypeScript types
- Schema updates → API docs
- Migrations → Git commits
- All automated

### 4. Safety & Best Practices
- Automatic security checks
- RLS policies by default
- Migration reviews
- Rollback capabilities

## 🚀 Example: Complete App Setup

### 1. Initial Setup
```bash
"Create a task management app with Supabase"
```

**Cursor generates:**
- Database schema (users, projects, tasks)
- Authentication system
- TypeScript types
- API routes
- Basic UI components

### 2. Feature Addition
```bash
"Add team collaboration features"
```

**Cursor adds:**
- Teams table
- Member permissions
- Invitation system
- Real-time updates
- UI for team management

### 3. Scaling
```bash
"Optimize for 10,000+ users"
```

**Cursor implements:**
- Database indexes
- Query optimization
- Caching layer
- Performance monitoring
- Load testing

## 🔧 Integration Points

### Frontend (React/Next.js)
```typescript
// Auto-generated types
import { Database } from './types/supabase'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

### Backend API
```typescript
// Auto-generated API routes
app.get('/api/posts', async (req, res) => {
  const { data } = await supabase
    .from('posts')
    .select('*, author:users(*)')
  res.json(data)
})
```

### Database Migrations
```sql
-- Auto-generated migration
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  author_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Auto-applied RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

## 📚 Documentation

All documentation is auto-generated:
- Database schema docs
- API endpoint documentation  
- TypeScript interface docs
- Security policy documentation
- Performance optimization guides

## 🎉 Result

You get a production-ready app with:
- ✅ Secure database with RLS
- ✅ Type-safe frontend and backend
- ✅ Auto-generated API documentation
- ✅ Git-based migration workflow
- ✅ Performance monitoring
- ✅ Security auditing
- ✅ Team collaboration features

All through natural language commands to Cursor!
