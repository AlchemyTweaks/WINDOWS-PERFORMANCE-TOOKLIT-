param (
    [string]$OutputLocation = "C:\PerfMon"
)

# Execute the process 31 times
for ($iteration = 1; $iteration -le 31; $iteration++) {
    # Find the number of the last executed test
    $lastTestNumber = 1
    while (Test-Path (Join-Path -Path $OutputLocation -ChildPath "TEST $lastTestNumber")) {
        $lastTestNumber++
    }

    # Create a folder for test results for the current iteration
    $testFolder = Join-Path -Path $OutputLocation -ChildPath "TEST $lastTestNumber"
    New-Item -Path $testFolder -ItemType Directory

    $date = Get-Date -Format "yyyyMMdd-hhmm" # Get the current date and time in the correct format

    # Check if the trace.etl file exists and delete it if it does
    $traceEtlPath = Join-Path -Path $testFolder -ChildPath "trace.etl"
    if (Test-Path $traceEtlPath) {
        Remove-Item $traceEtlPath
    }

    # Start DPC/ISR recording
    xperf -on Latency -stackwalk profile -BufferSize 1024

    # Countdown for 5 seconds
    for ($i = 5; $i -ge 1; $i--) {
        Write-Host "Recording in progress... Time remaining: $i seconds"
        Start-Sleep -Seconds 1
    }

    Write-Host "Started"

    # Countdown for 5 seconds
    for ($i = 5; $i -ge 1; $i--) {
        Write-Host "Recording in progress... Time remaining: $i seconds"
        Start-Sleep -Seconds 1
    }

    # Stop DPC/ISR recording
    xperf -d $traceEtlPath

    # Copy the recorded file with the correct name
    $traceTxtPath = Join-Path -Path $testFolder -ChildPath "$date.txt"
    xperf -i $traceEtlPath -o $traceTxtPath -a dpcisr

    # Print completion message
    Write-Host "Test $lastTestNumber completed. Results saved in $testFolder"

    # Save the current iteration number to a file
    $iterationFile = Join-Path -Path $testFolder -ChildPath "iteration.txt"
    Set-Content -Path $iterationFile -Value "Iteration: $iteration"
}
