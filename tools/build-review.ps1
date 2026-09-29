# Builds work/batchN/batchN-review.xlsx from work/batchN/review.tsv (tools/assemble-batch.lua).
# usage: powershell -ExecutionPolicy Bypass -File tools/build-review.ps1 1
# ASCII-only on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

param([Parameter(Mandatory = $true)][int]$Batch)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $root ("work\batch" + $Batch)
$out = Join-Path $dir ("batch" + $Batch + "-review.xlsx")

$lines = [System.IO.File]::ReadAllLines((Join-Path $dir "review.tsv"), [System.Text.Encoding]::UTF8)
$rows = @($lines | Where-Object { $_ -ne "" } | ForEach-Object { ,($_.TrimStart([char]0xFEFF) -split "`t") })

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$xl.ScreenUpdating = $false
try {
    $wb = $xl.Workbooks.Add()
    while ($wb.Worksheets.Count -lt 2) { [void]$wb.Worksheets.Add([Type]::Missing, $wb.Worksheets.Item($wb.Worksheets.Count)) }
    $wb.Styles.Item("Normal").Font.Name = "Arial"
    $wb.Styles.Item("Normal").Font.Size = 10

    # ---------------- Review sheet ----------------
    $ws = $wb.Worksheets.Item(2)
    $ws.Name = "Review"
    # Source columns: 1 section, 2 key, 3 English, 4 current Spanish, 5 proposed, 6 change, 7 flag, 8 note, 9 auto
    $headers = @("Section", "Key", "English", "Current Spanish", "Proposed Spanish", "Change", "Flag", "Translator note",
                 "Automatic checks", "Your decision", "Your Spanish", "Your notes")
    for ($c = 0; $c -lt $headers.Count; $c++) { $ws.Cells(1, $c + 1).Value2 = $headers[$c] }
    $h = $ws.Range("A1:L1")
    $h.Font.Bold = $true
    $h.Font.Color = 0xFFFFFF
    $h.Interior.Color = 0x5A3A1F
    $h.WrapText = $true
    $ws.Range("J1:L1").Interior.Color = 0x2C8BB8
    $last = $rows.Count + 1
    $ws.Range("A2").Resize($rows.Count, 12).NumberFormat = "@"
    for ($r = 0; $r -lt $rows.Count; $r++) {
        $row = $rows[$r]
        $excelRow = $r + 2
        for ($c = 0; $c -lt 9; $c++) {
            $v = if ($c -lt $row.Count) { [string]$row[$c] } else { "" }
            if ($v -ne "") { $ws.Cells($excelRow, $c + 1).Value2 = $v.Replace('\"', '"').Replace('\n', [string][char]10) }
        }
        $flag = if ($row.Count -gt 6) { $row[6] } else { "" }
        $auto = if ($row.Count -gt 8) { $row[8] } else { "" }
        $change = $row[5]
        if ($change -eq "Fixed") { $ws.Cells($excelRow, 6).Interior.Color = 0xB4E1FF }     # light orange
        if ($change -eq "New") { $ws.Cells($excelRow, 6).Interior.Color = 0xDDF0E2 }       # light green
        if ($flag -ne "") { $ws.Cells($excelRow, 7).Interior.Color = 0x9CD8F8 }            # orange
        if ($auto -ne "") { $ws.Cells($excelRow, 9).Interior.Color = 0xC7C7FF }            # light red
    }
    $ws.Range("J2:L$last").Interior.Color = 0xCCF2FF
    $v = $ws.Range("J2:J$last").Validation
    $v.Delete()
    $v.Add(3, 1, 1, "OK,Use my Spanish,Keep current,Discuss")
    $widths = @(14, 26, 44, 34, 44, 8, 7, 34, 26, 14, 40, 26)
    for ($c = 0; $c -lt $widths.Count; $c++) { $ws.Columns($c + 1).ColumnWidth = $widths[$c] }
    $ws.Range("C2:E$last").WrapText = $true
    $ws.Range("H2:I$last").WrapText = $true
    $ws.Range("K2:L$last").WrapText = $true
    $ws.Range("A2:L$last").VerticalAlignment = -4160
    $ws.Range("B2:B$last").Font.Size = 8
    $ws.Range("B2:B$last").Font.Color = 0x808080
    $ws.Range("E2:E$last").Font.Bold = $true
    $ws.Range("A1:L$last").AutoFilter() | Out-Null
    $ws.Activate()
    $xl.ActiveWindow.SplitRow = 1
    $xl.ActiveWindow.SplitColumn = 3
    $xl.ActiveWindow.FreezePanes = $true

    # ---------------- How to use ----------------
    $hs = $wb.Worksheets.Item(1)
    $hs.Name = "How to use"
    $text = @(
        @("Batch $Batch review", ""),
        @("", ""),
        @("What to do", "Read the Proposed Spanish (bold) against the English. In 'Your decision' pick OK to accept it, 'Use my Spanish' after writing your version in 'Your Spanish', 'Keep current' to keep the existing Spanish line, or 'Discuss'."),
        @("Where to start", "Filter 'Flag' (orange) first: lines where the translator was unsure or changed an existing line (FIX), with the reason in 'Translator note'. Then 'Automatic checks' (red), then the rest."),
        @("Change", "New = had no Spanish before. Kept = existing Spanish unchanged. Fixed = existing Spanish changed; see the note for why."),
        @("Automatic checks", "Placeholders (%s, BIND_..., \n), style-guide words, glossary terms, and lines much longer than the English. A warning is not always an error; say so in Your notes."),
        @("Example", "Key MENU_QUICK_JOIN: proposed UNIRSE RAPIDO, flag FIX. If you prefer ENTRAR RAPIDO, write it in 'Your Spanish' and pick 'Use my Spanish'."),
        @("", ""),
        @("Progress", ""),
        @("Decided", ""),
        @("Left", ""),
        @("Flagged left", "")
    )
    for ($r = 0; $r -lt $text.Count; $r++) {
        $hs.Cells($r + 1, 1).Value2 = $text[$r][0]
        $hs.Cells($r + 1, 2).Value2 = $text[$r][1]
    }
    $hs.Cells(10, 2).Formula = "=COUNTA(Review!J2:J$last)"
    $hs.Cells(11, 2).Formula = "=ROWS(Review!J2:J$last)-COUNTA(Review!J2:J$last)"
    $hs.Cells(12, 2).Formula = "=COUNTIFS(Review!G2:G$last,""?*"",Review!J2:J$last,"""")"
    $hs.Range("B10:B12").HorizontalAlignment = -4131
    $hs.Columns(1).ColumnWidth = 18
    $hs.Columns(2).ColumnWidth = 110
    $hs.Range("B1:B12").WrapText = $true
    $hs.Range("A1:B12").VerticalAlignment = -4160
    $hs.Range("A1:A12").Font.Bold = $true
    $hs.Cells(1, 1).Font.Size = 14
    $hs.Activate()

    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("review-" + [guid]::NewGuid() + ".xlsx")
    $wb.SaveAs($tmp, 51)
    $wb.Close($false)
    if ([System.IO.File]::Exists($out)) { [System.IO.File]::Delete($out) }
    [System.IO.File]::Move($tmp, $out)
    Write-Output "wrote $out ($($rows.Count) rows)"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
}
