/*
 * YARA Rule: Suspicious PowerShell Activity Detection
 * Author: Maher Mansour Mahyoub Ghaleb
 * Description: Detects obfuscated PowerShell scripts, encoded payloads,
 *              and common attack frameworks like PowerSploit, Empire.
 * MITRE ATT&CK: T1059.001 - PowerShell
 *              T1027 - Obfuscated Files or Information
 *              T1027.010 - Command Obfuscation
 * Severity: HIGH
 */

rule PowerShell_Suspicious_Patterns
{
    meta:
        description = "Detects obfuscated PowerShell with suspicious patterns"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1059.001, T1027, T1027.010"
        severity = "high"
        confidence = "medium-high"

    strings:
        // Encoded command patterns
        $enc1 = "-EncodedCommand" ascii nocase wide
        $enc2 = "-enc " ascii nocase wide
        $enc3 = "FromBase64String" ascii nocase wide
        $enc4 = "ToBase64String" ascii nocase wide

        // Hidden window execution
        $hidden1 = "-WindowStyle Hidden" ascii nocase wide
        $hidden2 = "-w hidden" ascii nocase wide
        $hidden3 = "-NonInteractive" ascii nocase wide

        // Execution policy bypass
        $bypass1 = "ExecutionPolicy Bypass" ascii nocase wide
        $bypass2 = "-ep bypass" ascii nocase wide
        $bypass3 = "-ExecutionPolicy Unrestricted" ascii nocase wide

        // Download cradles
        $download1 = "DownloadString" ascii nocase wide
        $download2 = "DownloadFile" ascii nocase wide
        $download3 = "DownloadData" ascii nocase wide
        $download4 = "IEX (New-Object" ascii nocase wide
        $download5 = "Invoke-Expression" ascii nocase wide
        $download6 = "IEX([System.Text.Encoding]" ascii nocase wide

        // PowerSploit framework
        $psploit1 = "Invoke-DllInjection" ascii nocase wide
        $psploit2 = "Invoke-ReflectivePEInjection" ascii nocase wide
        $psploit3 = "Invoke-Shellcode" ascii nocase wide
        $psploit4 = "Get-GPPPassword" ascii nocase wide
        $psploit5 = "Invoke-Kerberoast" ascii nocase wide
        $psploit6 = "Invoke-CredentialInjection" ascii nocase wide
        $psploit7 = "Invoke-NinjaCopy" ascii nocase wide
        $psploit8 = "Invoke-TokenManipulation" ascii nocase wide

        // Empire framework
        $empire1 = "Invoke-Empire" ascii nocase wide
        $empire2 = "Invoke-ShellcodeMSIL" ascii nocase wide
        $empire3 = "Invoke-BypassUAC" ascii nocase wide

        // AMSI bypass
        $amsi1 = "AmsiUtils" ascii nocase wide
        $amsi2 = "amsiInitFailed" ascii nocase wide
        $amsi3 = "amsiContext" ascii nocase wide

        // Reflection-based loading
        $reflect1 = "System.Reflection.Assembly" ascii nocase wide
        $reflect2 = "Reflection.Assembly]::Load" ascii nocase wide

    condition:
        // File should be reasonably small (scripts)
        filesize < 5MB and
        (
            // 3+ general suspicious patterns
            3 of ($enc*, $hidden*, $bypass*) or
            // 2+ download cradle patterns
            2 of ($download*) or
            // Any PowerSploit indicator
            2 of ($psploit*) or
            // Any Empire indicator
            any of ($empire*) or
            // AMSI bypass + any other suspicious pattern
            (any of ($amsi*) and 2 of ($enc*, $hidden*, $bypass*, $reflect*)) or
            // Reflection loading with suspicious patterns
            (any of ($reflect*) and 1 of ($enc*, $download*))
        )
}
