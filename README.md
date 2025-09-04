# Minimal Cursor Rules System

A **focused, project-specific** Cursor rules system that actually provides value.

## Philosophy

Instead of 6,000+ lines of generic programming advice that AI already knows, this system focuses on:

- **Project-specific context** that AI can't guess
- **Business rules** unique to your domain
- **Team decisions** and the reasoning behind them
- **Minimal overhead** (3-4 files, ~300 total lines)

## What's Different

❌ **Old Approach**: Generic programming tutorials repeated across 11 files
✅ **New Approach**: Project-specific context that actually helps AI understand your codebase

❌ **Old Approach**: 1,164 lines telling AI about Docker best practices
✅ **New Approach**: 50 lines about YOUR deployment constraints and business requirements

## Quick Start

### For New Projects

```bash
# Clone this repo
git clone [this-repo] cursor-rules-templates

# Initialize rules in your project
cd your-project
/path/to/cursor-rules-templates/init-project-rules.sh

# Set up Git tracking (optional)
export SUPABASE_ANON_KEY="your_key_here"
./setup-git-hooks.sh "your-project-name"

# Customize the templates with YOUR project details
# Edit .cursor/rules/00-project-context.mdc with your specific context
```

### For Existing Projects

```bash
# Copy just the templates you need
cp cursor-rules-templates/.cursor/rules/00-project-context.mdc .cursor/rules/
cp cursor-rules-templates/.cursor/rules/01-business-rules.mdc .cursor/rules/
cp cursor-rules-templates/.cursor/rules/02-team-conventions.mdc .cursor/rules/

# Customize with your project details
```

## The Rules

### 📋 `00-project-context.mdc` (~60 lines)
**Always Applied** - What makes THIS project unique
- Business domain and constraints
- Technical stack and limitations  
- Compliance requirements
- Integration points

### 🏢 `01-business-rules.mdc` (~100 lines)
**Domain-specific** - Business logic that AI can't know
- Entity states and transitions
- Validation rules specific to your domain
- Integration constraints
- Compliance and audit requirements

### 👥 `02-team-conventions.mdc` (~80 lines)
**Team decisions** - Choices you've made and why
- Architectural decisions with reasoning
- Code patterns your team prefers
- Testing strategies
- Known technical debt

### ⚡ `03-[type]-patterns.mdc` (~60 lines, optional)
**Project-type specific** patterns
- API conventions
- Frontend patterns  
- Data pipeline standards
- CLI tool conventions

### 🔗 `04-git-hooks-automation.mdc` (~200 lines, optional)
**Git automation** and Supabase integration
- Automatic Git hook setup
- Supabase project tracking
- Commit automation
- Dashboard integration

### 🧠 `05-memory-automation.mdc` (~300 lines, optional)
**Memory management** and knowledge storage
- Automatic knowledge storage
- Decision tracking
- Pattern recognition
- Cross-project learning

## Example: What Good Rules Look Like

**Instead of generic advice:**
```yaml
# ❌ Generic (AI already knows this)
- Use meaningful variable names
- Write unit tests
- Handle errors properly
```

**Document specific context:**
```yaml
# ✅ Project-specific (AI needs this context)
- Orders over $1000 require credit check before processing
- All API responses must include request_id for compliance tracking
- User data deletion requires 30-day grace period (GDPR Article 17)
- Payment webhooks must be idempotent (Stripe sends duplicates)
```

## Why This Works

### 🎯 **Focused Context**
- 300 lines total vs 6,000+ in the old system
- Only information AI actually needs
- No cognitive overload

### 🏗️ **Project-Specific Value**
- Business rules unique to your domain
- Technical constraints AI can't guess
- Team decisions with historical context

### 🔧 **Easy Maintenance**
- Templates, not rigid frameworks
- Update only what changes
- No complex versioning or conflicts

### 📏 **Right-Sized**
- Small enough to read and understand
- Large enough to provide real value
- Focused on what matters for YOUR project

## When to Use This

### ✅ **Good Candidates**
- Projects with domain-specific business rules
- Teams with established conventions
- Applications with compliance requirements
- Complex integrations with specific constraints

### ❌ **Skip It For**
- Simple scripts or utilities
- Standard CRUD applications
- Solo projects with common patterns
- Prototypes or experiments

## Maintenance

### Update When
- Business requirements change
- New team members join
- Technical architecture evolves
- You discover new edge cases

### Keep It Fresh
- Review monthly in team retrospectives
- Remove outdated information
- Add newly discovered constraints
- Document new team decisions

## 🚀 New: Git Automation & Supabase Integration

### Automatic Project Tracking

This system now includes **automatic Git hook setup** for Supabase project tracking:

```bash
# Cursor will automatically detect when to set up Git tracking
# Just say: "Set up Git tracking for this project"

# Or manually:
export SUPABASE_ANON_KEY="your_key"
./setup-git-hooks.sh "project-name"
```

### What Gets Tracked Automatically

- **Git commits** with file changes and statistics
- **Project operations** and deployments  
- **Cross-project analytics** and health monitoring
- **Real-time dashboard** in Supabase
- **Knowledge and decisions** in memory graph
- **Patterns and learnings** across projects

### Cursor Integration

When you start a new project, Cursor will:

1. **Detect** if Git tracking is needed
2. **Create** the setup script automatically
3. **Configure** environment variables
4. **Install** Git hooks for automatic tracking
5. **Set up** Supabase project monitoring
6. **Store** project knowledge in memory graph
7. **Track** decisions and patterns automatically

## Migration from Old System

If you're coming from a bloated rules system:

1. **Start fresh** - don't try to salvage generic content
2. **Extract specific context** - what makes your project unique?
3. **Document decisions** - why did your team choose specific patterns?
4. **Focus on business rules** - what domain knowledge does AI need?
5. **Add Git automation** - track your projects automatically

---

**Philosophy**: Give AI the context it needs about YOUR specific project, not generic programming advice it already knows.