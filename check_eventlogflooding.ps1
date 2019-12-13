#Made by Nathan Safran
#12/13/2019
#https://github.com/nsafran1217
#Checks the number of events logged in the last x seconds
#Useful for checking if the event log is being flooded.
Param (
    [Parameter()]
    [int]$secondsToMeasure = 5,
    [Parameter()]
    [int]$warnThreshold = 10,
    [Parameter()]
    [int]$criticalThreshold = 20
)

$exitvar = 3
try {
    $endtime = get-date
    $starttime = $endtime.AddSeconds(-$secondsToMeasure)
    $log = Get-EventLog -LogName Application -After $starttime -Before $endtime
    $numOfLogs = $log.Count
    if ($numOfLogs -ge $warnThreshold -and $numOfLogs -lt $critical) {
        $message = $log.Message[0].Replace("`n","")
        $output = "Warning: $numOfLogs events in the last $secondsToMeasure seconds. Last Message: $message"
        $exitvar = 1
    }
    elseif ($numOfLogs -ge $criticalThreshold) {
        $message = $log.Message[0]
        $output = "Critical: $numOfLogs events in the last $secondsToMeasure seconds. Last Message: $message"
        $exitvar = 2
    }
    else {
        $output = "OK. $numOfLogs events in the last $secondsToMeasure seconds."
        $exitvar = 0
    }
    $output += "|errors=$numOfLogs;$warnThreshold;$criticalThreshold`n"
}
catch {
    $output = "Unknown error occured."
}
Write-Output $output
exit $exitvar