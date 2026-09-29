# Builds work/glossary-review.xlsx from glossary/glossary.tsv: every term with its handling,
# Spanish and article, proposed articles highlighted, and input columns for corrections.
# usage: powershell -ExecutionPolicy Bypass -File tools/build-glossary-review.ps1
# ASCII-only on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "work\glossary-review.xlsx"

$lines = [System.IO.File]::ReadAllLines((Join-Path $root "glossary\glossary.tsv"), [System.Text.Encoding]::UTF8)
$rows = @($lines | Select-Object -Skip 1 | Where-Object { $_ -ne "" } | ForEach-Object { ,($_ -split "`t") })

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
try {
    $wb = $xl.Workbooks.Add()
    $wb.Styles.Item("Normal").Font.Name = "Arial"
    $wb.Styles.Item("Normal").Font.Size = 10
    $ws = $wb.Worksheets.Item(1)
    $ws.Name = "Glossary"
    $headers = @("Category", "English", "Handling", "Spanish", "Article", "Notes", "Correct article", "Correct Spanish", "Your notes")
    for ($c = 0; $c -lt $headers.Count; $c++) { $ws.Cells(1, $c + 1).Value2 = $headers[$c] }
    $h = $ws.Range("A1:I1")
    $h.Font.Bold = $true
    $h.Font.Color = 0xFFFFFF
    $h.Interior.Color = 0x5A3A1F
    $ws.Range("G1:I1").Interior.Color = 0x2C8BB8
    $ws.Range("A2").Resize($rows.Count, 9).NumberFormat = "@"
    $proposed = 0
    for ($r = 0; $r -lt $rows.Count; $r++) {
        $row = $rows[$r]
        for ($c = 0; $c -lt 6; $c++) {
            $v = if ($c -lt $row.Count) { [string]$row[$c] } else { "" }
            if ($c -eq 4 -and $v -like "* (proposed)") {
                $v = $v.Replace(" (proposed)", "")
                $ws.Cells($r + 2, 5).Interior.Color = 0x9CD8F8   # orange: proposed, please check
                $proposed++
            }
            if ($v -ne "") { $ws.Cells($r + 2, $c + 1).Value2 = $v }
        }
    }
    $last = $rows.Count + 1
    $ws.Range("G2:I$last").Interior.Color = 0xCCF2FF
    $v = $ws.Range("G2:G$last").Validation
    $v.Delete()
    $v.Add(3, 1, 1, "el,la,los,las")
    $widths = @(18, 22, 10, 26, 9, 50, 12, 24, 30)
    for ($c = 0; $c -lt $widths.Count; $c++) { $ws.Columns($c + 1).ColumnWidth = $widths[$c] }
    $ws.Range("F2:F$last").WrapText = $true
    $ws.Range("I2:I$last").WrapText = $true
    $ws.Range("A2:I$last").VerticalAlignment = -4160
    $ws.Range("A1:I$last").AutoFilter() | Out-Null
    $ws.Activate()
    $xl.ActiveWindow.SplitRow = 1
    $xl.ActiveWindow.SplitColumn = 2
    $xl.ActiveWindow.FreezePanes = $true

    $note = $last + 2
    $ws.Cells($note, 1).Value2 = "How to use"
    $ws.Cells($note, 1).Font.Bold = $true
    $ws.Cells($note, 2).Value2 = "Orange articles are proposals: pick the right one in 'Correct article' only where the proposal is wrong. Use 'Correct Spanish' to change a term. Example: if 'la Shade' should be 'el Shade', pick 'el' in Correct article on the Shade row."

    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("glossary-" + [guid]::NewGuid() + ".xlsx")
    $wb.SaveAs($tmp, 51)
    $wb.Close($false)
    if ([System.IO.File]::Exists($out)) { [System.IO.File]::Delete($out) }
    [System.IO.File]::Move($tmp, $out)
    Write-Output "wrote $out ($($rows.Count) terms, $proposed proposed articles)"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
}
