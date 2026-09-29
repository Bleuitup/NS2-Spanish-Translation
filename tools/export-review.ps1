# Exports the reviewer's columns of work/batchN/batchN-review.xlsx to work/batchN/decisions.tsv:
#   key, proposed Spanish, decision, reviewer Spanish, reviewer notes
# usage: powershell -ExecutionPolicy Bypass -File tools/export-review.ps1 1
# ASCII-only on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

param([Parameter(Mandatory = $true)][int]$Batch)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $root ("work\batch" + $Batch)
$src = Join-Path $dir ("batch" + $Batch + "-review.xlsx")
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("export-" + [guid]::NewGuid() + ".xlsx")
[System.IO.File]::Copy($src, $tmp, $true)

function Clean($v) { return ([string]$v).Replace("`t", " ").Replace("`r", "").Replace("`n", "\n").Trim() }

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
try {
    $wb = $xl.Workbooks.Open($tmp, 0, $true)
    $ws = $wb.Worksheets.Item("Review")
    $last = $ws.Cells($ws.Rows.Count, 2).End(-4162).Row
    $sb = New-Object System.Text.StringBuilder
    $decided = 0
    for ($r = 2; $r -le $last; $r++) {
        # B key, E proposed, J decision, K reviewer Spanish, L notes
        $vals = @((Clean $ws.Cells($r, 2).Value2), (Clean $ws.Cells($r, 5).Value2), (Clean $ws.Cells($r, 10).Value2),
                  (Clean $ws.Cells($r, 11).Value2), (Clean $ws.Cells($r, 12).Value2))
        if ($vals[2] -ne "") { $decided++ }
        [void]$sb.Append(($vals -join "`t") + "`n")
    }
    $wb.Close($false)
    $out = Join-Path $dir "decisions.tsv"
    [System.IO.File]::WriteAllText($out, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    Write-Output "exported $($last - 1) rows, $decided decided"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
