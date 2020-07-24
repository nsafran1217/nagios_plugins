#Add all disk used together and report


$disks = Get-WmiObject Win32_LogicalDisk | where drivetype -eq 3 | where deviceID -ne 'C:'



$used = 0
# Iterate through our disks array to get our free space and total size values in bytes for each disk
# We append each array with the drive letter and its respective value
foreach ($disk in $disks) {
    # Eliminating DVD drives and anything else with no usage so we can avoid division-by-zero errors
    if ($disk.Size -ne $disk.FreeSpace) {
        $used =$used + ($disk.Size - $disk.FreeSpace)
    }


}

$used = [math]::round($used/1GB, 1)
    $statusmessage = "OK - $Used GB Used on all disks | used=$used;;;"

Write-Host $statusmessage
#exit 0