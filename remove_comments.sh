#!/bin/bash

# Bash script to remove all comments from Dart files
# Usage: ./remove_comments.sh [--dry-run] [--no-backup]

DRY_RUN=false
NO_BACKUP=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        *)
            ;;
    esac
done

echo "=== Dart Comment Removal Tool ==="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE - No files will be modified"
    echo ""
fi

# Create backup
if [ "$NO_BACKUP" = false ] && [ "$DRY_RUN" = false ]; then
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in: $BACKUP_DIR"
    
    if [ -d "lib" ]; then
        cp -r lib "$BACKUP_DIR"
        echo "Backup created successfully!"
        echo ""
    fi
fi

# Find all Dart files
DART_FILES=$(find lib -name "*.dart" -type f)
TOTAL_FILES=$(echo "$DART_FILES" | wc -l)
PROCESSED=0
MODIFIED=0

echo "Found $TOTAL_FILES Dart files to process"
echo ""

# Process each file
while IFS= read -r file; do
    PROCESSED=$((PROCESSED + 1))
    
    # Use sed to remove comments
    # This is a simplified version - may not handle all edge cases
    if [ "$DRY_RUN" = true ]; then
        # Check if file would be modified
        TEMP_FILE=$(mktemp)
        sed -e 's|//.*$||g' \
            -e '/\/\*/,/\*\//d' \
            "$file" > "$TEMP_FILE"
        
        if ! cmp -s "$file" "$TEMP_FILE"; then
            echo "[DRY RUN] Would modify: $file"
            MODIFIED=$((MODIFIED + 1))
        fi
        rm "$TEMP_FILE"
    else
        # Create temp file
        TEMP_FILE=$(mktemp)
        
        # Remove comments
        sed -e 's|//.*$||g' \
            -e '/\/\*/,/\*\//d' \
            "$file" > "$TEMP_FILE"
        
        # Check if content changed
        if ! cmp -s "$file" "$TEMP_FILE"; then
            mv "$TEMP_FILE" "$file"
            echo "[MODIFIED] $file"
            MODIFIED=$((MODIFIED + 1))
        else
            rm "$TEMP_FILE"
        fi
    fi
    
    # Progress indicator
    PERCENT=$((PROCESSED * 100 / TOTAL_FILES))
    echo -ne "Progress: $PERCENT% ($PROCESSED/$TOTAL_FILES)\r"
    
done <<< "$DART_FILES"

echo ""
echo ""
echo "=== Summary ==="
echo "Total files processed: $PROCESSED"
echo "Files modified: $MODIFIED"
echo "Files unchanged: $((PROCESSED - MODIFIED))"

if [ "$DRY_RUN" = false ]; then
    echo ""
    echo "Recommendations:"
    echo "1. Run 'flutter format lib' to clean up formatting"
    echo "2. Run 'flutter analyze' to check for any issues"
    echo "3. Test your app thoroughly"
    
    if [ "$NO_BACKUP" = false ]; then
        echo ""
        echo "Backup location: $BACKUP_DIR"
        echo "To restore: rm -rf lib && mv $BACKUP_DIR lib"
    fi
fi

echo ""
echo "Done!"
