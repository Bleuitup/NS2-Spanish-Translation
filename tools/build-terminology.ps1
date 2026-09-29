# Builds work/terminology-decisions.xlsx from work/terminology.tsv (tools/terms.lua) and
# work/style-questions.tsv, through Excel itself (COM), so formatting and dropdowns are native.
# usage (from the repo root): powershell -ExecutionPolicy Bypass -File tools/build-terminology.ps1
# Kept ASCII-only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI. Spanish text comes from the TSVs.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "work\terminology-decisions.xlsx"

function Read-Tsv($path) {
    $lines = [System.IO.File]::ReadAllLines((Join-Path $root $path), [System.Text.Encoding]::UTF8)
    return ,@($lines | Where-Object { $_ -ne "" } | ForEach-Object { ,($_.TrimStart([char]0xFEFF) -split "`t") })
}

function Put-Rows($sheet, $firstRow, $rows, $cols) {
    $range = $sheet.Cells($firstRow, 1).Resize($rows.Count, $cols)
    $range.NumberFormat = "@"   # text: game strings starting with = + - must not be read as formulas
    # Cell by cell: a few thousand cells, and PowerShell's COM binder will not pass a 2D array to Value2.
    for ($r = 0; $r -lt $rows.Count; $r++) {
        for ($c = 0; $c -lt $cols; $c++) {
            $v = if ($c -lt $rows[$r].Count) { [string]$rows[$r][$c] } else { "" }
            if ($v -eq "") { continue }
            $cell = $sheet.Cells($firstRow + $r, $c + 1)
            if ($v -match '^\d+$') { $cell.NumberFormat = "0"; $cell.Value2 = [int]$v } else { $cell.Value2 = $v }
        }
    }
    return ,$range   # the comma stops PowerShell unrolling the Range into its cells
}

function Style-Header($sheet, $headers, $inputFrom) {
    for ($c = 0; $c -lt $headers.Count; $c++) { $sheet.Cells(1, $c + 1).Value2 = $headers[$c] }
    $h = $sheet.Range($sheet.Cells(1, 1), $sheet.Cells(1, $headers.Count))
    $h.Font.Bold = $true
    $h.Interior.Color = 0x5A3A1F     # dark blue (BGR)
    $h.Font.Color = 0xFFFFFF
    $h.WrapText = $true
    $h.VerticalAlignment = -4108     # center
    if ($inputFrom) {
        $sheet.Range($sheet.Cells(1, $inputFrom), $sheet.Cells(1, $headers.Count)).Interior.Color = 0x2C8BB8  # amber
    }
}

$terms = Read-Tsv "work\terminology.tsv"
$style = Read-Tsv "work\style-questions.tsv"

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
try {
    $wb = $xl.Workbooks.Add()
    while ($wb.Worksheets.Count -lt 3) { [void]$wb.Worksheets.Add([Type]::Missing, $wb.Worksheets.Item($wb.Worksheets.Count)) }
    $wb.Styles.Item("Normal").Font.Name = "Arial"
    $wb.Styles.Item("Normal").Font.Size = 10

    # ---------------- Terms ----------------
    $ts = $wb.Worksheets.Item(2)
    $ts.Name = "Terms"
    $headers = @("Category", "English term", "Uses in English file", "Translated lines using it", "...of those keeping the English word",
                 "Suggested", "Suggested Spanish", "Why", "Example (English)", "Example (current Spanish)", "Example key",
                 "Your decision", "Your Spanish term", "Article (el / la)", "Your notes")
    Style-Header $ts $headers 12
    $rows = New-Object System.Collections.ArrayList
    foreach ($t in $terms) { [void]$rows.Add(@($t[0], $t[1], $t[2], $t[3], $t[4], $t[5], $t[6], $t[7], $t[8], $t[9], $t[10], "", "", "", "")) }
    $body = Put-Rows $ts 2 $rows $headers.Count
    $last = $rows.Count + 1
    $widths = @(16, 20, 10, 11, 12, 16, 20, 34, 46, 46, 22, 20, 20, 10, 30)
    for ($c = 0; $c -lt $widths.Count; $c++) { $ts.Columns($c + 1).ColumnWidth = $widths[$c] }
    $body.VerticalAlignment = -4160  # top
    $ts.Range("H2:J$last").WrapText = $true
    $ts.Range("O2:O$last").WrapText = $true
    $ts.Range("C2:E$last").HorizontalAlignment = -4108
    $ts.Range("K2:K$last").Font.Color = 0x808080
    $ts.Range("K2:K$last").Font.Size = 8
    $ts.Range("L2:O$last").Interior.Color = 0xCCF2FF   # light yellow input cells
    $v = $ts.Range("L2:L$last").Validation
    $v.Delete()
    $v.Add(3, 1, 1, "OK as suggested,Keep English,Translate,English name + Spanish noun")
    $v.IgnoreBlank = $true
    $v2 = $ts.Range("N2:N$last").Validation
    $v2.Delete()
    $v2.Add(3, 1, 1, "el,la,los,las")
    $ts.Range("A1:O$last").AutoFilter() | Out-Null
    $ts.Activate()
    $xl.ActiveWindow.SplitRow = 1
    $xl.ActiveWindow.SplitColumn = 2
    $xl.ActiveWindow.FreezePanes = $true
    $ts.Rows(1).RowHeight = 42

    # ---------------- Style ----------------
    $ss = $wb.Worksheets.Item(3)
    $ss.Name = "Style"
    $sh = @("Topic", "Question", "Suggested", "Evidence / notes", "Your decision", "Your notes")
    Style-Header $ss $sh 5
    $srows = New-Object System.Collections.ArrayList
    foreach ($s in $style) { [void]$srows.Add(@($s[0], $s[1], $s[2], $s[3], "", "")) }
    $sbody = Put-Rows $ss 2 $srows $sh.Count
    $slast = $srows.Count + 1
    $sw = @(16, 34, 50, 55, 34, 30)
    for ($c = 0; $c -lt $sw.Count; $c++) { $ss.Columns($c + 1).ColumnWidth = $sw[$c] }
    $sbody.WrapText = $true
    $sbody.VerticalAlignment = -4160
    $ss.Range("A2:A$slast").Font.Bold = $true
    $ss.Range("E2:F$slast").Interior.Color = 0xCCF2FF
    $ss.Activate()
    $xl.ActiveWindow.SplitRow = 1
    $xl.ActiveWindow.FreezePanes = $true

    # ---------------- How to use ----------------
    $hs = $wb.Worksheets.Item(1)
    $hs.Name = "How to use"
    $lines = @(
        @("NS2 Spanish translation - terminology and style decisions", ""),
        @("", ""),
        @("What this is", "Phase 1 of the translation: decide how each game term and each style question is handled, before any new text is translated. The AI pass follows these decisions, so later review is about wording, not terms."),
        @("Source", "Snapshot of ns2/gamestrings/enUS.txt and esES.txt from Ghoul's ns2-game repo, beta branch, commit c94ff24af (2026-09-28)."),
        @("", ""),
        @("Terms sheet", "One row per game term. Columns A-K are filled in for you: how often the term appears, how the current Spanish file handles it (col. E: how many translated lines keep the English word), a suggestion, and a real example pair."),
        @("", "Fill in the yellow columns: Your decision (dropdown), Your Spanish term (when translating), Article (el/la, for English names used in Spanish sentences) and Your notes."),
        @("", "Pick 'OK as suggested' to accept the suggestion as is. Leave a row blank if you want to discuss it."),
        @("Example", "Term 'Hive': suggested Keep English. You pick 'OK as suggested', Article 'la' (la Hive). Term 'Flamethrower': suggested Translate / lanzallamas. You pick 'OK as suggested', Article 'el'."),
        @("", ""),
        @("Style sheet", "General rules (tu vs usted, 'presiona' vs 'pulsa', button wording, gender of English names...). Fill in Your decision (or write OK) and Your notes."),
        @("", ""),
        @("Progress", ""),
        @("Terms decided", ""),
        @("Terms left", ""),
        @("Style questions decided", ""),
        @("Style questions left", "")
    )
    for ($r = 0; $r -lt $lines.Count; $r++) {
        $hs.Cells($r + 1, 1).Value2 = $lines[$r][0]
        $hs.Cells($r + 1, 2).Value2 = $lines[$r][1]
    }
    $hs.Cells(14, 2).Formula = "=COUNTA(Terms!L2:L$last)"
    $hs.Cells(15, 2).Formula = "=ROWS(Terms!L2:L$last)-COUNTA(Terms!L2:L$last)"
    $hs.Cells(16, 2).Formula = "=COUNTA(Style!E2:E$slast)"
    $hs.Cells(17, 2).Formula = "=ROWS(Style!E2:E$slast)-COUNTA(Style!E2:E$slast)"
    $hs.Range("B14:B17").HorizontalAlignment = -4131  # left
    $hs.Columns(1).ColumnWidth = 24
    $hs.Columns(2).ColumnWidth = 110
    $hs.Range("B1:B17").WrapText = $true
    $hs.Range("A1:B17").VerticalAlignment = -4160
    $hs.Range("A1:A17").Font.Bold = $true
    $hs.Cells(1, 1).Font.Size = 14
    $hs.Range("B7").Interior.Color = 0xCCF2FF
    $hs.Activate()

    # Excel cannot save to a path containing [ ] (the Drive folders are named "[01] ..."), so save
    # to a temp file and move it into place.
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("terminology-" + [guid]::NewGuid() + ".xlsx")
    $wb.SaveAs($tmp, 51)
    $wb.Close($false)
    if ([System.IO.File]::Exists($out)) { [System.IO.File]::Delete($out) }
    [System.IO.File]::Move($tmp, $out)
    Write-Output "wrote $out ($($rows.Count) terms, $($srows.Count) style questions)"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
}
