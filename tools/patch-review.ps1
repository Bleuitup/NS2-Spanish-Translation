# Updates the proposed Spanish (column E) of specific rows in work/batchN/batchN-review.xlsx in
# place, keeping the reviewer's columns. Rows are found by key (column B). Input: a UTF-8 file of
# key<TAB>Spanish lines, escaped as in the game file.
# usage: powershell -ExecutionPolicy Bypass -File tools/patch-review.ps1 7 work/batch7/patch.tsv
# ASCII-only on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

param([Parameter(Mandatory = $true)][int]$Batch, [Parameter(Mandatory = $true)][string]$PatchFile)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root ("work\batch" + $Batch + "\batch" + $Batch + "-review.xlsx")
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("patch-" + [guid]::NewGuid() + ".xlsx")
[System.IO.File]::Copy($src, $tmp, $true)

$patch = @{}
foreach ($line in [System.IO.File]::ReadAllLines((Join-Path $root $PatchFile), (New-Object System.Text.UTF8Encoding($false)))) {
    $i = $line.IndexOf("`t")
    if ($i -gt 0) { $patch[$line.Substring(0, $i)] = $line.Substring($i + 1) }
}

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
try {
    $wb = $xl.Workbooks.Open($tmp)
    $ws = $wb.Worksheets.Item("Review")
    $last = $ws.Cells($ws.Rows.Count, 2).End(-4162).Row
    $done = 0
    for ($r = 2; $r -le $last; $r++) {
        $key = [string]$ws.Cells($r, 2).Value2
        if ($patch.ContainsKey($key)) {
            $ws.Cells($r, 5).Value2 = $patch[$key].Replace('\"', '"').Replace('\n', [string][char]10)
            $done++
        }
    }
    $wb.Save()
    $wb.Close($false)
    Write-Output "patched $done of $($patch.Count) rows"
}
finally {
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
}
[System.IO.File]::Copy($tmp, $src, $true)
Remove-Item $tmp
