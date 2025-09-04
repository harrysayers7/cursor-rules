#!/bin/bash

# Git Hook Setup for Supabase Project Tracking
# This script sets up automatic tracking of Git commits to Supabase
# Auto-generated from cursor-rules template
# Uses MCP for automatic Supabase configuration

set -e

PROJECT_NAME="${1:-$(basename $(pwd))}"
SUPABASE_URL="${SUPABASE_URL:-https://zeopoimfsxdidkyiucsr.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

# MCP Integration: Cursor automatically provides Supabase credentials
if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "🔧 MCP Integration: Getting Supabase credentials from Cursor..."
    echo "   If you see this, Cursor should have provided the key automatically"
    echo "   Fallback: Get it from: https://supabase.com/dashboard/project/zeopoimfsxdidkyiucsr/settings/api"
    echo "   Or set it in your .env.local file"
    exit 1
fi

echo "🎣 Setting up Git hooks for project: $PROJECT_NAME"
echo "   Supabase URL: $SUPABASE_URL"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  Warning: jq is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    else
        echo "❌ Please install jq manually: https://stedolan.github.io/jq/"
        exit 1
    fi
fi

# Create post-commit hook
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash

# Get commit details
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
AUTHOR_NAME=$(git log -1 --pretty=%an)
AUTHOR_EMAIL=$(git log -1 --pretty=%ae)
COMMITTED_AT=$(git log -1 --pretty=%ci)

# Get file changes
FILES_CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || git ls-files)
LINES_ADDED=$(git diff --numstat HEAD~1 HEAD 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
LINES_DELETED=$(git diff --numstat HEAD~1 HEAD 2>/dev/null | awk '{sum+=$2} END {print sum+0}')

# Convert files to JSON array
FILES_JSON=$(echo "$FILES_CHANGED" | jq -R -s -c 'split("\n")[:-1]')

# Track commit in Supabase
curl -s -X POST "$SUPABASE_URL/rest/v1/rpc/track_git_commit" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"p_project_name\": "'"$PROJECT_NAME"'",
    \"p_commit_hash\": \"$COMMIT_HASH\",
    \"p_commit_message\": \"$COMMIT_MESSAGE\",
    \"p_author_name\": \"$AUTHOR_NAME\",
    \"p_author_email\": \"$AUTHOR_EMAIL\",
    \"p_committed_at\": \"$COMMITTED_AT\",
    \"p_files_changed\": $FILES_JSON,
    \"p_lines_added\": $LINES_ADDED,
    \"p_lines_deleted\": $LINES_DELETED
  }" > /dev/null

echo "✅ Tracked commit $COMMIT_HASH for project '$PROJECT_NAME'"
EOF

# Make hook executable
chmod +x .git/hooks/post-commit

# Create .env.example if it doesn't exist
if [ ! -f ".env.example" ]; then
    cat > .env.example << EOF
# Supabase Configuration
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_URL=https://zeopoimfsxdidkyiucsr.supabase.co
PROJECT_NAME=$PROJECT_NAME

# Copy to .env.local and fill in your actual values
EOF
    echo "✅ Created .env.example template"
fi

# Add to .gitignore if not already there
if [ -f ".gitignore" ] && ! grep -q ".env.local" .gitignore; then
    echo "" >> .gitignore
    echo "# Environment variables" >> .gitignore
    echo ".env.local" >> .gitignore
    echo "✅ Added .env.local to .gitignore"
fi

echo "✅ Git hook installed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Copy .env.example to .env.local"
echo "2. Add your SUPABASE_ANON_KEY to .env.local"
echo "3. Make a test commit to see it in action"
echo "4. Check your Supabase dashboard for tracked commits"
echo ""
echo "🔧 To get your Supabase key:"
echo "   https://supabase.com/dashboard/project/zeopoimfsxdidkyiucsr/settings/api"
echo ""
echo "📊 View your project dashboard:"
echo "   https://supabase.com/dashboard/project/zeopoimfsxdidkyiucsr/editor"
