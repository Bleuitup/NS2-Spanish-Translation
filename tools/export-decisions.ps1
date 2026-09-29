# Exports the decisions filled in work/terminology-decisions.xlsx to UTF-8 TSV files, so they can be
# read by the other tools and diffed in git:
#   work/decisions-terms.tsv  term, suggested, suggested Spanish, decision, Spanish term, article, notes
#   work/decisions-style.tsv  topic, suggested, decision, notes
# usage: powershell -ExecutionPolicy Bypass -File tools/export-decisions.ps1
# ASCII-only on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root "work\terminology-decisions.xlsx"
# Excel cannot open paths with [ ] reliably, and the user may have the file open: work on a copy.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("decisions-" + [guid]::NewGuid() + ".xlsx")
[System.IO.File]::Copy($src, $tmp, $true)

function Clean($v) { return ([string]$v).Replace("`t", " ").Replace("`r", " ").Replace("`n", " ").Trim() }

function Export-Sheet($sheet, $cols, $outName) {
    $last = $sheet.Cells($sheet.Rows.Count, 1).End(-4162).Row   # xlUp
    $sb = New-Object System.Text.StringBuilder
    for ($r = 2; $r -le $last; $r++) {
        $vals = foreach ($c in $cols) { Clean $sheet.Cells($r, $c).Value2 }
        [void]$sb.Append(($vals -join "`t") + "`n")
    }
    $path = Join-Path $root ("work\" + $outName)
    [System.IO.File]::WriteAllText($path, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    return ($last - 1)
}

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
try {
    $wb = $xl.Workbooks.Open($tmp, 0, $true)
    # Terms: B term, F suggested, G suggested Spanish, L decision, M Spanish term, N article, O notes
    $n1 = Export-Sheet $wb.Worksheets.Item("Terms") @(2, 6, 7, 12, 13, 14, 15) "decisions-terms.tsv"
    # Style: A topic, C suggested, E decision, F notes
    $n2 = Export-Sheet $wb.Worksheets.Item("Style") @(1, 3, 5, 6) "decisions-style.tsv"
    $wb.Close($false)
    Write-Output "exported $n1 terms, $n2 style rows"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
