# Complete Workflow Example: Building a Task Management App

This example shows how Cursor uses Supabase MCP tools to build a complete application from start to finish.

## 🚀 The Magic: Natural Language → Production App

### Step 1: Project Initiation
**You say to Cursor:**
> "Create a task management application with team collaboration features using Supabase"

**Cursor understands and executes:**
```bash
1. Creates new Supabase project: "TaskMaster"
2. Sets up authentication system
3. Designs database schema
4. Generates TypeScript types  
5. Creates Next.js application structure
6. Sets up CI/CD pipeline
```

### Step 2: Database Schema Creation
**Cursor automatically creates:**

```sql
-- Users table (from Supabase Auth)
-- Teams table
CREATE TABLE teams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Team memberships
CREATE TABLE team_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(team_id, user_id)
);

-- Projects
CREATE TABLE projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks
CREATE TABLE tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done')),
  priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  assignee_id UUID REFERENCES auth.users(id),
  created_by UUID REFERENCES auth.users(id),
  due_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies (automatically applied)
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Security policies
CREATE POLICY "Users can view teams they belong to" ON teams
  FOR SELECT USING (
    id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can view projects in their teams" ON projects
  FOR SELECT USING (
    team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
  );

-- ... more policies for complete security
```

### Step 3: TypeScript Types Generation
**Cursor automatically generates:**

```typescript
// types/database.ts
export interface Database {
  public: {
    Tables: {
      teams: {
        Row: {
          id: string
          name: string
          description: string | null
          owner_id: string | null
          created_at: string | null
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          owner_id?: string | null
          created_at?: string | null
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          owner_id?: string | null
          created_at?: string | null
        }
      }
      // ... all other tables
    }
  }
}

// Type helpers
export type Team = Database['public']['Tables']['teams']['Row']
export type Task = Database['public']['Tables']['tasks']['Row']
export type Project = Database['public']['Tables']['projects']['Row']
```

### Step 4: Frontend Components
**Cursor creates React components:**

```typescript
// components/TaskBoard.tsx
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Task } from '@/types/database'

export function TaskBoard({ projectId }: { projectId: string }) {
  const [tasks, setTasks] = useState<Task[]>([])
  
  useEffect(() => {
    // Real-time subscription
    const subscription = supabase
      .channel('tasks')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'tasks' },
        (payload) => {
          // Update UI in real-time
          handleTaskUpdate(payload)
        }
      )
      .subscribe()

    return () => subscription.unsubscribe()
  }, [])

  const updateTaskStatus = async (taskId: string, status: string) => {
    const { error } = await supabase
      .from('tasks')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', taskId)
    
    if (error) console.error('Error updating task:', error)
  }

  // ... component implementation
}
```

### Step 5: API Routes
**Cursor generates API endpoints:**

```typescript
// pages/api/tasks/[id].ts
import { NextApiRequest, NextApiResponse } from 'next'
import { supabase } from '@/lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query
  
  switch (req.method) {
    case 'GET':
      const { data: task, error } = await supabase
        .from('tasks')
        .select('*, assignee:auth.users(*), project:projects(*)')
        .eq('id', id)
        .single()
      
      if (error) return res.status(404).json({ error: 'Task not found' })
      return res.json(task)
      
    case 'PATCH':
      const { data: updated, error: updateError } = await supabase
        .from('tasks')
        .update(req.body)
        .eq('id', id)
        .select()
        .single()
      
      if (updateError) return res.status(400).json({ error: updateError.message })
      return res.json(updated)
      
    default:
      return res.status(405).json({ error: 'Method not allowed' })
  }
}
```

## 🎯 Advanced Features: Adding Real-time Collaboration

### Step 6: Real-time Features
**You say:**
> "Add real-time collaboration so team members can see live updates"

**Cursor implements:**

```typescript
// hooks/useRealTimeUpdates.ts
import { useEffect } from 'react'
import { supabase } from '@/lib/supabase'

export function useRealTimeUpdates(projectId: string) {
  useEffect(() => {
    const channel = supabase
      .channel(`project-${projectId}`)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'tasks',
        filter: `project_id=eq.${projectId}`
      }, (payload) => {
        // Broadcast to all components
        window.dispatchEvent(new CustomEvent('task-updated', { 
          detail: payload 
        }))
      })
      .subscribe()

    return () => supabase.removeChannel(channel)
  }, [projectId])
}
```

### Step 7: Performance Optimization
**You say:**
> "Optimize for teams with 1000+ tasks"

**Cursor adds:**

```sql
-- Database optimization
CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date) WHERE due_date IS NOT NULL;

-- Partial indexes for common queries
CREATE INDEX idx_active_tasks ON tasks(created_at DESC) 
  WHERE status IN ('todo', 'in_progress');
```

```typescript
// Frontend optimization
import { useMemo } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

export function VirtualizedTaskList({ tasks }: { tasks: Task[] }) {
  const parentRef = useRef<HTMLDivElement>(null)
  
  const virtualizer = useVirtualizer({
    count: tasks.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 60,
  })

  const virtualItems = virtualizer.getVirtualItems()

  return (
    <div ref={parentRef} className="h-96 overflow-auto">
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualItems.map((virtualItem) => (
          <TaskItem 
            key={virtualItem.key}
            task={tasks[virtualItem.index]}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${virtualItem.start}px)`,
            }}
          />
        ))}
      </div>
    </div>
  )
}
```

## 🔐 Security & Compliance

### Step 8: Enterprise Security
**You say:**
> "Make this enterprise-ready with audit logging and RBAC"

**Cursor implements:**

```sql
-- Audit logging
CREATE TABLE audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL,
  record_id UUID NOT NULL,
  operation VARCHAR(20) NOT NULL,
  old_values JSONB,
  new_values JSONB,
  user_id UUID REFERENCES auth.users(id),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_logs (
    table_name, record_id, operation, old_values, new_values, user_id
  ) VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    to_jsonb(OLD),
    to_jsonb(NEW),
    auth.uid()
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables
CREATE TRIGGER audit_tasks AFTER INSERT OR UPDATE OR DELETE ON tasks
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

## 📊 Analytics & Reporting

### Step 9: Business Intelligence
**You say:**
> "Add analytics dashboard for project managers"

**Cursor creates:**

```sql
-- Analytics views
CREATE VIEW team_productivity AS
SELECT 
  t.name as team_name,
  COUNT(tasks.id) as total_tasks,
  COUNT(CASE WHEN tasks.status = 'done' THEN 1 END) as completed_tasks,
  ROUND(
    COUNT(CASE WHEN tasks.status = 'done' THEN 1 END)::numeric / 
    NULLIF(COUNT(tasks.id), 0) * 100, 2
  ) as completion_rate,
  AVG(EXTRACT(DAY FROM (tasks.updated_at - tasks.created_at))) as avg_completion_days
FROM teams t
LEFT JOIN projects p ON t.id = p.team_id
LEFT JOIN tasks ON p.id = tasks.project_id
WHERE tasks.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY t.id, t.name;
```

```typescript
// components/AnalyticsDashboard.tsx
import { useQuery } from '@tanstack/react-query'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js'
import { Bar } from 'react-chartjs-2'

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

export function AnalyticsDashboard() {
  const { data: analytics } = useQuery({
    queryKey: ['team-analytics'],
    queryFn: async () => {
      const { data } = await supabase
        .from('team_productivity')
        .select('*')
      return data
    }
  })

  const chartData = {
    labels: analytics?.map(team => team.team_name) || [],
    datasets: [{
      label: 'Completion Rate (%)',
      data: analytics?.map(team => team.completion_rate) || [],
      backgroundColor: 'rgba(54, 162, 235, 0.6)',
      borderColor: 'rgba(54, 162, 235, 1)',
      borderWidth: 1,
    }]
  }

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-4">Team Analytics</h2>
      <Bar data={chartData} />
    </div>
  )
}
```

## 🚀 Deployment & Monitoring

### Step 10: Production Deployment
**Cursor automatically sets up:**

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Apply database migrations
        run: |
          npx supabase db push --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          
      - name: Generate types
        run: |
          npx supabase gen types typescript --project-id ${{ secrets.SUPABASE_PROJECT_REF }} > types/database.ts
          
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

## 🎉 Final Result

**From a single sentence to a production app:**

✅ **Complete task management system**
✅ **Real-time collaboration** 
✅ **Team management & RBAC**
✅ **Mobile-responsive UI**
✅ **Type-safe throughout**
✅ **Enterprise security**
✅ **Analytics dashboard**
✅ **Automated deployment**
✅ **Performance optimized**
✅ **Fully documented**

**Total development time:** Hours instead of weeks
**Code quality:** Production-ready from day one
**Maintenance:** Minimal - mostly automated

This is the power of Cursor + Supabase MCP integration!
