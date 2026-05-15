# PowerShell script to safely remove all comments from Dart files
# This script:
# - Creates a backup before modifying files
# - Removes single-line comments (//)
# - Removes multi-line comments (/* */)
# - Removes documentation comments (///)
# - Preserves comments inside strings

param(
    [switch]$NoBackup,
    [switch]$DryRun
)

Write-Host "=== Dart Comment Removal Tool ===" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be modified" -ForegroundColor Yellow
    Write-Host ""
}

# Create backup directory if not in dry run mode and backup is enabled
if (-not $NoBackup -and -not $DryRun) {
    $backupDir = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Creating backup in: $backupDir" -ForegroundColor Yellow
    
    if (Test-Path "lib") {
        Copy-Item -Path "lib" -Destination $backupDir -Recurse
        Write-Host "Backup created successfully!" -ForegroundColor Green
        Write-Host ""
    }
}

# Get all Dart files in the lib directory
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse -File

$totalFiles = $dartFiles.Count
$processedFiles = 0
$modifiedFiles = 0
$errorFiles = 0

Write-Host "Found $totalFiles Dart files to process" -ForegroundColor Yellow
Write-Host ""

function Remove-DartComments {
    param([string]$content)
    
    # Remove multi-line comments (/* ... */ and /** ... */)
    $content = $content -replace '/\*\*?[\s\S]*?\*/', ''
    
    # Process line by line for single-line comments
    $lines = $content -split "`r?`n"
    $newLines = @()
    
    foreach ($line in $lines) {
        $processedLine = $line
        
        # Find comment position (avoiding strings)
        if ($line -match '//') {
            $inString = $false
            $inChar = $false
            $escaped = $false
            $commentPos = -1
            
            for ($i = 0; $i -lt $line.Length - 1; $i++) {
                $char = $line[$i]
                $nextChar = $line[$i + 1]
                
                # Handle escape sequences
                if ($char -eq '\') {
                    $escaped = -not $escaped
                    continue
                }
                
                # Track string state
                if ($char -eq '"' -and -not $escaped -and -not $inChar) {
                    $inString = -not $inString
                }
                
                # Track char literal state
                if ($char -eq "'" -and -not $escaped -and -not $inString) {
                    $inChar = -not $inChar
                }
                
                # Find comment start
                if (-not $inString -and -not $inChar -and $char -eq '/' -and $nextChar -eq '/') {
                    $commentPos = $i
                    break
                }
                
                if ($char -ne '\') {
                    $escaped = $false
                }
            }
            
            if ($commentPos -ge 0) {
                $processedLine = $line.Substring(0, $commentPos).TrimEnd()
            }
        }
        
        # Keep the line (even if empty, to preserve structure)
        $newLines += $processedLine
    }
    
    $result = $newLines -join "`n"
    
    # Remove excessive blank lines (more than 2 consecutive)
    $result = $result -replace '(\r?\n\s*){3,}', "`n`n"
    
    # Trim trailing whitespace from lines
    $result = ($result -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n"
    
    return $result
}

foreach ($file in $dartFiles) {
    $processedFiles++
    $percentComplete = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
    Write-Progress -Activity "Removing comments" -Status "Processing $($file.Name) ($processedFiles/$totalFiles)" -PercentComplete $percentComplete
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        $originalContent = $content
        
        # Remove comments
        $newContent = Remove-DartComments -content $content
        
        # Check if content changed
        if ($newContent -ne $originalContent) {
            if ($DryRun) {
                Write-Host "[DRY RUN] Would modify: $($file.FullName)" -ForegroundColor Cyan
                $modifiedFiles++
            } else {
                Set-Content -Path $file.FullName -Value $newContent -NoNewline -ErrorAction Stop
                Write-Host "[MODIFIED] $($file.FullName)" -ForegroundColor Green
                $modifiedFiles++
            }
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
        $errorFiles++
    }
}

Write-Progress -Activity "Removing comments" -Completed

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total files processed: $processedFiles" -ForegroundColor White
Write-Host "Files modified: $modifiedFiles" -ForegroundColor Green
Write-Host "Files unchanged: $($processedFiles - $modifiedFiles - $errorFiles)" -ForegroundColor Gray
if ($errorFiles -gt 0) {
    Write-Host "Files with errors: $errorFiles" -ForegroundColor Red
}

if (-not $DryRun) {
    Write-Host ""
    Write-Host "Recommendations:" -ForegroundColor Yellow
    Write-Host "1. Run 'flutter format lib' to clean up formatting" -ForegroundColor White
    Write-Host "2. Run 'flutter analyze' to check for any issues" -ForegroundColor White
    Write-Host "3. Test your app thoroughly" -ForegroundColor White
    
    if (-not $NoBackup) {
        Write-Host ""
        Write-Host "Backup location: $backupDir" -ForegroundColor Cyan
        Write-Host "To restore: Remove current 'lib' folder and rename backup folder to 'lib'" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
