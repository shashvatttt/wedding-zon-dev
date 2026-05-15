# PowerShell script to remove all comments from Dart files
# This script removes:
# - Single-line comments (//)
# - Multi-line comments (/* */)
# - Documentation comments (///)

Write-Host "Starting comment removal from Dart files..." -ForegroundColor Cyan

# Get all Dart files in the lib directory
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse -File

$totalFiles = $dartFiles.Count
$processedFiles = 0
$modifiedFiles = 0

Write-Host "Found $totalFiles Dart files to process" -ForegroundColor Yellow

foreach ($file in $dartFiles) {
    $processedFiles++
    Write-Progress -Activity "Removing comments" -Status "Processing $($file.Name)" -PercentComplete (($processedFiles / $totalFiles) * 100)
    
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    
    # Remove multi-line comments (/* ... */)
    # This regex handles nested cases and preserves strings
    $content = $content -replace '/\*[\s\S]*?\*/', ''
    
    # Remove single-line comments (// and ///)
    # This regex avoids removing // inside strings
    $lines = $content -split "`n"
    $newLines = @()
    
    foreach ($line in $lines) {
        # Check if line contains a comment
        if ($line -match '//') {
            # Find the position of //
            $inString = $false
            $inChar = $false
            $commentPos = -1
            
            for ($i = 0; $i -lt $line.Length - 1; $i++) {
                $char = $line[$i]
                $nextChar = $line[$i + 1]
                
                # Track if we're inside a string
                if ($char -eq '"' -and ($i -eq 0 -or $line[$i - 1] -ne '\')) {
                    $inString = -not $inString
                }
                
                # Track if we're inside a char literal
                if ($char -eq "'" -and ($i -eq 0 -or $line[$i - 1] -ne '\')) {
                    $inChar = -not $inChar
                }
                
                # Check for comment start
                if (-not $inString -and -not $inChar -and $char -eq '/' -and $nextChar -eq '/') {
                    $commentPos = $i
                    break
                }
            }
            
            if ($commentPos -ge 0) {
                # Remove the comment part
                $line = $line.Substring(0, $commentPos).TrimEnd()
            }
        }
        
        # Only add non-empty lines or lines with actual code
        if ($line.Trim() -ne '') {
            $newLines += $line
        }
    }
    
    $content = $newLines -join "`n"
    
    # Remove multiple consecutive blank lines (more than 2)
    $content = $content -replace '(\r?\n){3,}', "`n`n"
    
    # Trim trailing whitespace from each line
    $content = ($content -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n"
    
    # Only write if content changed
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $modifiedFiles++
        Write-Host "Modified: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Progress -Activity "Removing comments" -Completed

Write-Host "`nComment removal complete!" -ForegroundColor Cyan
Write-Host "Total files processed: $processedFiles" -ForegroundColor Yellow
Write-Host "Files modified: $modifiedFiles" -ForegroundColor Green
Write-Host "Files unchanged: $($processedFiles - $modifiedFiles)" -ForegroundColor Gray

# Ask if user wants to see a summary
$response = Read-Host "`nWould you like to see the list of modified files? (y/n)"
if ($response -eq 'y' -or $response -eq 'Y') {
    Write-Host "`nModified files:" -ForegroundColor Cyan
    Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse -File | ForEach-Object {
        Write-Host "  - $($_.FullName)" -ForegroundColor Gray
    }
}

Write-Host "`nDone! You may want to run 'flutter format lib' to clean up formatting." -ForegroundColor Yellow
