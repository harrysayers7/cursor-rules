#!/bin/bash

# Cursor Rules System Validation Script
# This script validates the structure and integrity of the cursor rules system

set -e

RULES_DIR=".cursor/rules"
TOTAL_RULES=0
VALID_RULES=0
ERRORS=()

echo "🔍 Validating Cursor Rules System..."
echo "=================================="

# Check if rules directory exists
if [ ! -d "$RULES_DIR" ]; then
    echo "❌ Error: Rules directory '$RULES_DIR' not found"
    exit 1
fi

echo "✅ Rules directory found: $RULES_DIR"

# Function to validate MDC file structure
validate_mdc_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    TOTAL_RULES=$((TOTAL_RULES + 1))
    
    echo "  📄 Validating: $filename"
    
    # Check if file has frontmatter
    if ! head -n 1 "$file" | grep -q "^---$"; then
        ERRORS+=("$filename: Missing frontmatter start")
        return 1
    fi
    
    # Check if frontmatter is properly closed
    if ! sed -n '2,20p' "$file" | grep -q "^---$"; then
        ERRORS+=("$filename: Missing frontmatter end")
        return 1
    fi
    
    # Check for required frontmatter fields
    if ! grep -q "^description:" "$file"; then
        ERRORS+=("$filename: Missing 'description' field")
        return 1
    fi
    
    if ! grep -q "^globs:" "$file"; then
        ERRORS+=("$filename: Missing 'globs' field")
        return 1
    fi
    
    if ! grep -q "^alwaysApply:" "$file"; then
        ERRORS+=("$filename: Missing 'alwaysApply' field")
        return 1
    fi
    
    # Check if file has content after frontmatter
    local content_lines=$(sed -n '/^---$/,/^---$/!p' "$file" | sed '/^$/d' | wc -l)
    if [ "$content_lines" -lt 10 ]; then
        ERRORS+=("$filename: Insufficient content (less than 10 non-empty lines)")
        return 1
    fi
    
    VALID_RULES=$((VALID_RULES + 1))
    echo "    ✅ Valid"
    return 0
}

# Validate core rules
echo ""
echo "🏗️  Validating Core Rules..."
echo "----------------------------"

for file in "$RULES_DIR"/*.mdc; do
    if [ -f "$file" ]; then
        validate_mdc_file "$file"
    fi
done

# Validate category rules
echo ""
echo "📁 Validating Category Rules..."
echo "-------------------------------"

categories=(
    "coding"
    "project" 
    "python"
    "javascript"
    "api"
    "database"
    "security"
    "testing"
    "devops"
)

for category in "${categories[@]}"; do
    category_dir="$RULES_DIR/$category"
    if [ -d "$category_dir" ]; then
        echo "  📂 Category: $category"
        for file in "$category_dir"/*.mdc; do
            if [ -f "$file" ]; then
                validate_mdc_file "$file"
            fi
        done
    else
        echo "  ❌ Missing category directory: $category"
        ERRORS+=("Missing category directory: $category")
    fi
done

# Check for always-applied rules
echo ""
echo "🔧 Validating Always-Applied Rules..."
echo "------------------------------------"

always_applied_count=$(grep -l "alwaysApply: true" "$RULES_DIR"/*.mdc 2>/dev/null | wc -l)
echo "  Always-applied rules found: $always_applied_count"

if [ "$always_applied_count" -eq 0 ]; then
    ERRORS+=("No always-applied rules found")
fi

# Validate glob patterns
echo ""
echo "🎯 Validating Glob Patterns..."
echo "-----------------------------"

# Check specific patterns for key categories
if [ -f "$RULES_DIR/python/01-python-best-practices.mdc" ]; then
    if grep -q "*.py" "$RULES_DIR/python/01-python-best-practices.mdc"; then
        echo "  ✅ python: Has appropriate glob patterns"
    else
        echo "  ⚠️  python: May need glob pattern review"
    fi
fi

if [ -f "$RULES_DIR/javascript/01-javascript-typescript-best-practices.mdc" ]; then
    if grep -q "*.js\|*.ts" "$RULES_DIR/javascript/01-javascript-typescript-best-practices.mdc"; then
        echo "  ✅ javascript: Has appropriate glob patterns"
    else
        echo "  ⚠️  javascript: May need glob pattern review"
    fi
fi

if [ -f "$RULES_DIR/api/01-api-design-best-practices.mdc" ]; then
    if grep -q "api" "$RULES_DIR/api/01-api-design-best-practices.mdc"; then
        echo "  ✅ api: Has appropriate glob patterns"
    else
        echo "  ⚠️  api: May need glob pattern review"
    fi
fi

if [ -f "$RULES_DIR/testing/01-testing-best-practices.mdc" ]; then
    if grep -q "test" "$RULES_DIR/testing/01-testing-best-practices.mdc"; then
        echo "  ✅ testing: Has appropriate glob patterns"
    else
        echo "  ⚠️  testing: May need glob pattern review"
    fi
fi

# Summary
echo ""
echo "📊 Validation Summary"
echo "===================="
echo "Total rules validated: $TOTAL_RULES"
echo "Valid rules: $VALID_RULES"
echo "Errors found: ${#ERRORS[@]}"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Errors found:"
    for error in "${ERRORS[@]}"; do
        echo "  - $error"
    done
    exit 1
else
    echo ""
    echo "🎉 All rules validation passed!"
    echo ""
    echo "Your Cursor Rules system is ready for use!"
    echo ""
    echo "To use these rules in a project:"
    echo "1. Copy the .cursor directory to your project root"
    echo "2. Open your project in Cursor"
    echo "3. Start coding - rules will activate automatically"
    echo ""
    echo "For more information, see README.md"
fi
