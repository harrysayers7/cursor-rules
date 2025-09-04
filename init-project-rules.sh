#!/bin/bash

# Cursor Rules Project Initialization
# Usage: ./init-project-rules.sh [target-directory]

set -e

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$TARGET_DIR/.cursor/rules"

echo "🎯 Initializing Cursor Rules for project..."
echo "Target directory: $TARGET_DIR"

# Create rules directory if it doesn't exist
mkdir -p "$RULES_DIR"

# Function to copy and customize template
copy_template() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ -f "$dest" ]; then
        read -p "⚠️  $name already exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "   Skipped $name"
            return
        fi
    fi
    
    cp "$src" "$dest"
    echo "✅ Created $name"
}

# Copy template files
echo ""
echo "📋 Copying rule templates..."

copy_template "$SCRIPT_DIR/.cursor/rules/00-project-context.mdc" \
              "$RULES_DIR/00-project-context.mdc" \
              "Project Context"

copy_template "$SCRIPT_DIR/.cursor/rules/01-business-rules.mdc" \
              "$RULES_DIR/01-business-rules.mdc" \
              "Business Rules"

copy_template "$SCRIPT_DIR/.cursor/rules/02-team-conventions.mdc" \
              "$RULES_DIR/02-team-conventions.mdc" \
              "Team Conventions"

# Ask about personal profile
echo ""
read -p "📝 Include your personal development profile? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    copy_template "$SCRIPT_DIR/.cursor/rules/99-personal-profile.mdc" \
                  "$RULES_DIR/99-personal-profile.mdc" \
                  "Personal Profile"
fi

# Create optional additional rules based on project type
echo ""
echo "🔧 Optional project-specific rules:"
echo "1) Web API project"
echo "2) Frontend project" 
echo "3) Data/ML project"
echo "4) CLI tool"
echo "5) Skip (minimal setup only)"

read -p "Select project type (1-5): " -n 1 -r PROJECT_TYPE
echo

case $PROJECT_TYPE in
    1)
        echo "📡 Adding API-specific rules..."
        cat > "$RULES_DIR/03-api-patterns.mdc" << 'EOF'
---
description: API-specific patterns and constraints
globs: **/api/**, **/routes/**, **/endpoints/**
alwaysApply: false
---

# API Patterns

## Request/Response Standards
- All responses include `request_id` for tracing
- Use consistent error format: `{"error": {"code": "ERROR_CODE", "message": "Human readable"}}`
- Pagination: `{"data": [], "pagination": {"page": 1, "total": 100}}`

## Authentication
[Document your auth pattern here]

## Rate Limiting
[Document rate limits and policies]

## Validation
[Document input validation standards]
EOF
        echo "✅ Created API patterns"
        ;;
    2)
        echo "🎨 Adding Frontend-specific rules..."
        cat > "$RULES_DIR/03-frontend-patterns.mdc" << 'EOF'
---
description: Frontend-specific patterns and constraints
globs: **/components/**, **/pages/**, **/hooks/**, **/*.tsx, **/*.jsx
alwaysApply: false
---

# Frontend Patterns

## Component Standards
- Use functional components with hooks
- Props interfaces in same file as component
- Extract custom hooks for complex state logic

## State Management
[Document Redux/Zustand/Context patterns]

## Error Boundaries
[Document error handling strategy]

## Performance
- Lazy load routes and heavy components
- Memoize expensive calculations
- Virtual scrolling for large lists
EOF
        echo "✅ Created Frontend patterns"
        ;;
    3)
        echo "📊 Adding Data/ML-specific rules..."
        cat > "$RULES_DIR/03-data-patterns.mdc" << 'EOF'
---
description: Data and ML-specific patterns
globs: **/models/**, **/pipelines/**, **/*.ipynb, **/data/**
alwaysApply: false
---

# Data & ML Patterns

## Data Pipeline Standards
- All data transformations are reproducible
- Version control for datasets and model artifacts
- Data quality checks at each pipeline stage

## Model Management
[Document model versioning and deployment]

## Experiment Tracking
[Document MLflow/Weights&Biases usage]

## Data Privacy
[Document data handling and privacy requirements]
EOF
        echo "✅ Created Data patterns"
        ;;
    4)
        echo "⚡ Adding CLI-specific rules..."
        cat > "$RULES_DIR/03-cli-patterns.mdc" << 'EOF'
---
description: CLI tool patterns and conventions
globs: **/cli/**, **/commands/**, **/__main__.py, **/main.*
alwaysApply: false
---

# CLI Tool Patterns

## Command Structure
- Use subcommands for different actions
- Consistent flag naming across commands
- Help text for every command and option

## Error Handling
- Exit codes: 0 (success), 1 (user error), 2 (system error)
- Clear error messages with suggested fixes
- No stack traces unless --debug flag

## Configuration
[Document config file format and precedence]

## Output Formatting
[Document --json, --quiet, --verbose options]
EOF
        echo "✅ Created CLI patterns"
        ;;
    5)
        echo "⚡ Minimal setup complete"
        ;;
    *)
        echo "❓ Unknown option, skipping project-specific rules"
        ;;
esac

# Create .gitignore entry if needed
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q ".cursor/" "$TARGET_DIR/.gitignore"; then
        echo ""
        read -p "📝 Add .cursor/ to .gitignore? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo "" >> "$TARGET_DIR/.gitignore"
            echo "# Cursor rules (keep rules but ignore other cursor files)" >> "$TARGET_DIR/.gitignore"
            echo ".cursor/*" >> "$TARGET_DIR/.gitignore"
            echo "!.cursor/rules/" >> "$TARGET_DIR/.gitignore"
            echo "✅ Updated .gitignore"
        fi
    fi
fi

echo ""
echo "🎉 Cursor Rules initialization complete!"
echo ""
echo "📁 Created files:"
echo "   .cursor/rules/00-project-context.mdc"
echo "   .cursor/rules/01-business-rules.mdc" 
echo "   .cursor/rules/02-team-conventions.mdc"
if [ -f "$RULES_DIR/99-personal-profile.mdc" ]; then
    echo "   .cursor/rules/99-personal-profile.mdc"
fi
if [ "$PROJECT_TYPE" != "5" ] && [ "$PROJECT_TYPE" != "" ]; then
    echo "   .cursor/rules/03-*-patterns.mdc"
fi
echo ""
echo "🚀 Next steps:"
echo "1. Edit 00-project-context.mdc with your project details"
echo "2. Fill in 01-business-rules.mdc with domain-specific logic"
echo "3. Document team decisions in 02-team-conventions.mdc"
if [ -f "$RULES_DIR/99-personal-profile.mdc" ]; then
    echo "4. Customize 99-personal-profile.mdc with your tools and preferences"
    echo "5. Remove template instructions and placeholder text"
else
    echo "4. Remove template instructions and placeholder text"
fi
echo ""
echo "💡 Pro tip: These rules work best when they contain project-specific"
echo "   context that AI wouldn't know from general training data."
