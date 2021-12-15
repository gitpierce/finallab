function Test-CloudFlare {

<#
.SYNOPSIS
Cmdlet to test network connection from a remote computer.

.DESCRIPTION
This cmdlet creates a remote session to one or more computers
on local network, then tests the remote computer(s) internet
connection.

.PARAMETER ComputerName
Mandatory parameter that sets a value for a computer name.

.EXAMPLE 
PS> Test-CloudFlare -ComputerName <IP or computer name>

Performs net test on specified computer.

.NOTES
Author: Pierce Shultz
Last Edit: 12-14-2021
Version 1.0

CHANGELOG:
-Removed output function, moved to its own tool
-Added BEGIN, PROCESS, END blocks

#>


    [CmdletBinding()]
    
    #Setting parameters
    param (
        [Parameter(mandatory=$True,
        ValueFromPipeline=$True)]
        [Alias('CN','Name')]
        [string[]]$ComputerName
        
)#param

BEGIN{}

PROCESS{
#Setting process for each computer listed in ComputerName parameter
    foreach ($computer in $ComputerName){
        try {
    $datetime=Get-Date
    $params=@{
        'ComputerName'=$computer
        'ErrorAction'='Stop'
    }
    Write-Host "Connecting to $Computer..." -ForegroundColor black -BackgroundColor yellow
    $session=New-PSSession @params
    Enter-PSSession $session
    Write-Host "Running connection test on $Computer..." -ForegroundColor black -BackgroundColor yellow
    $TestCF=test-netconnection -computername one.one.one.one -informationlevel detailed
    #Creating PSObject that contains properties to be listed in output
    Write-Host "Receiving results..." -ForegroundColor black -BackgroundColor yellow
    $OBJ=[PSCustomObject]@{
        'ComputerName'=$computer
        'PingSuccess'=$TestCF.PingSucceeded
        'NameResolve'=$TestCF.NameResolutionSucceeded
        'ResolvedAddresses'=$TestCF.ResolvedAddresses
    }
    Exit-PSSession
    Remove-PSSession $session
}#try
catch{  #Writes failure message if any command in try block fails to run
    Write-Host "Remote connection to $computer failed." -ForegroundColor Red
}#catch
}#foreach
}#process
END{
Write-Host "Test complete." -ForegroundColor black -BackgroundColor yellow
$OBJ
}#end
}#function

function Get-PipeResults {
<#
.SYNOPSIS
Cmdlet used to output results provided through the pipeline.

.DESCRIPTION
This cmdlet takes input given to it from the pipeline and outputs 
the results of the original command in desired format.

.PARAMETER path
The desired filepath to set location to and export job
output file to.

.PARAMETER Output
Mandatory parameter that decides how test results will be output.
Options are host (output in terminal), text (output in .txt file),
and csv (output in .csv file).

.EXAMPLE 
PS> Get-Process | Get-PipeResults

Performs net test of specified computer.


.NOTES
Author: Pierce Shultz
Last Edit: 12-14-2021
Version 1.0

CHANGELOG:
-Moved functionality to a completely separate function
-Added parameter that accepts pipeline input
-Streamlined output, took out fluff and now only show results

#>
    [CmdletBinding()]

    param (
        [Parameter(mandatory=$true,
        ValueFromPipeline=$true)]
        [Object]$object,   #Parameter that takes pipeline input to then be output
        
        [Parameter(mandatory=$true)]
        [ValidateSet('Host','Text','CSV')]
        [string]$Output,
        
        [Parameter(mandatory=$false)]
        [string]$path = $env:USERPROFILE,
        
        [Parameter(mandatory=$false)]
        [string]$FileName = 'PipeResults'
    )#param



BEGIN{}
PROCESS{
    Write-Host "Generating results in $Output..." -ForegroundColor black -BackgroundColor yellow    
    #Switch using $Output parameter to decide output method   
    switch ($Output) {
        "Host" {            
            $object
        }
        "CSV" {
            $object | Out-File $path\$FileName.csv            
        }
        "Text" {
            $object | Out-File $path\$FileName.txt            
        }
    }#switch

    
}#process
END{
    switch ($Output) {
        "Text" {
            notepad.exe $path\$FileName.txt
        }
    }#switch
}#end
}#function