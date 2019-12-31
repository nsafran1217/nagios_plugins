#Made by Nathan Safran
#11/26/2019
#https://github.com/nsafran1217
#Check arcserve job status. Calls ca_qmgr -list
#requries NT AUTHORITY\SYSTEM to have permissions in arcserve. Create a local account and set an equivalence.
#"C:\Program Files (x86)\CA\ARCserve Backup\"
#ca_auth -user add nagiosxi long_password_here -assignrole 8
#ca_auth -equiv add "NT AUTHORITY\SYSTEM" hostname_here nagiosxi

$timeout = 40 #seconds
$timer = [Diagnostics.Stopwatch]::StartNew()
$exitvar = 3
$job = Start-Job -name jobcheck -ScriptBlock {
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "C:\Program Files (x86)\CA\ARCserve Backup\ca_qmgr.exe" ##64 Bit OS install
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = "-list"
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        sleep 20
        $p.waitforexit()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stdout
    }
    catch {
    }
}
while (Get-Job -Name jobcheck | where State -ne "Completed") {
    Start-Sleep -Seconds 1
    if ($timer.Elapsed.TotalSeconds -gt $Timeout) {
        Write-Output "ERROR - Check has timed-out."
        $exitvar = 3
        get-process ca_qmgr | Stop-Process -Force -Confirm:$false
        Remove-Job -Force -Job $job
        exit $exitvar #Exit with unknown
    }
}
$output = (Get-Job | Receive-Job -AutoRemoveJob -Wait)
$results = $output -split ("`n")

if ($results -and $results -notmatch "Command failed") {
    $exitvar = 0
    foreach ($line in $results) {
        if ([bool]($line -match "BACKUP")) {
            if ($line -match "FAILED") {
                $exitvar = 2
                $str = ("JOB FAILED:" + ($line -replace '(?:\r|\n)', ''))
                Write-Output $str
            } 
        }  
    }
}
else {
    $exitvar = 3
}
if ($exitvar -eq 0) {
    Write-Output "OK. No Jobs Failed"
}
Write-Output $output
exit $exitvar