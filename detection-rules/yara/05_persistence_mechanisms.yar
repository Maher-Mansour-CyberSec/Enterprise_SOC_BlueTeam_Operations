/*
 * YARA Rule: Persistence Mechanism Detection
 * Author: Maher Mansour Mahyoub Ghaleb
 * Description: Detects common persistence mechanisms including scheduled tasks,
 *              WMI subscriptions, services, startup scripts, and registry keys.
 * MITRE ATT&CK: T1053.005 - Scheduled Task
 *              T1546.003 - WMI Event Subscription
 *              T1543.003 - Windows Service
 *              T1547.001 - Registry Run Keys
 * Severity: HIGH
 */

rule Persistence_Scheduled_Task_Suspicious
{
    meta:
        description = "Detects suspicious scheduled task XML definitions"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1053.005"
        severity = "high"

    strings:
        $xml_root = "<Task" ascii wide
        $xml_root2 = "<Tasks" ascii wide

        // Suspicious command patterns within tasks
        $cmd1 = "<Command>powershell" ascii nocase wide
        $cmd2 = "<Command>cmd" ascii nocase wide
        $cmd3 = "<Command>wscript" ascii nocase wide
        $cmd4 = "<Command>mshta" ascii nocase wide
        $cmd5 = "<Command>rundll32" ascii nocase wide
        $cmd6 = "<Command>regsvr32" ascii nocase wide

        // Suspicious arguments
        $arg1 = "-EncodedCommand" ascii nocase wide
        $arg2 = "-enc " ascii nocase wide
        $arg3 = "DownloadString" ascii nocase wide
        $arg4 = "IEX (New-Object" ascii nocase wide
        $arg5 = "FromBase64String" ascii nocase wide

        // Suspicious execution paths
        $path1 = "\\AppData\\" ascii nocase wide
        $path2 = "\\Temp\\" ascii nocase wide
        $path3 = "\\Public\\" ascii nocase wide
        $path4 = "\\ProgramData\\" ascii nocase wide
        $path5 = "C:\\Users\\Public" ascii nocase wide

        // PowerShell hidden execution
        $hidden1 = "-WindowStyle Hidden" ascii nocase wide
        $hidden2 = "-w hidden" ascii nocase wide
        $hidden3 = "CreateNoWindow" ascii nocase wide

        // Suspicious scheduling
        $sched1 = "<LogonTrigger>" ascii wide
        $sched2 = "<BootTrigger>" ascii wide
        $sched3 = "<CalendarTrigger>" ascii wide

    condition:
        // XML-based scheduled task file
        filesize < 100KB and
        any of ($xml_root*) and
        (
            // Suspicious command + suspicious arg
            (any of ($cmd*) and any of ($arg*)) or
            // Suspicious path + any execution
            (any of ($path*) and any of ($cmd*)) or
            // Hidden execution + any suspicious pattern
            (any of ($hidden*) and (any of ($cmd*) or any of ($arg*))) or
            // Encoded + download patterns
            (any of ($arg1, $arg2, $arg3, $arg4, $arg5) and any of ($cmd1))
        )
}

/*
 * Rule: WMI Event Subscription Persistence
 * Detects malicious WMI event consumers and bindings
 */
rule Persistence_WMI_Event_Subscription
{
    meta:
        description = "Detects suspicious WMI event consumer persistence"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1546.003"
        severity = "critical"

    strings:
        // MOF file format
        $mof1 = "instance of __EventConsumer" ascii wide
        $mof2 = "instance of __EventFilter" ascii wide
        $mof3 = "instance of __FilterToConsumerBinding" ascii wide

        // CommandLineEventConsumer
        $consumer1 = "CommandLineEventConsumer" ascii wide
        $consumer2 = "ActiveScriptEventConsumer" ascii wide
        $consumer3 = "ScriptingStandardConsumerSetting" ascii wide

        // Suspicious commands in consumers
        $cmd1 = "powershell" ascii nocase wide
        $cmd2 = "cmd.exe" ascii nocase wide
        $cmd3 = "DownloadString" ascii nocase wide
        $cmd4 = "-EncodedCommand" ascii nocase wide
        $cmd5 = "rundll32" ascii nocase wide

        // Suspicious paths
        $path1 = "AppData" ascii nocase wide
        $path2 = "Temp" ascii nocase wide
        $path3 = "ProgramData" ascii nocase wide

    condition:
        filesize < 50KB and
        any of ($mof*) and
        any of ($consumer*) and
        (
            any of ($cmd*) or
            any of ($path*)
        )
}

/*
 * Rule: Suspicious Windows Service Installation
 * Detects service installations pointing to suspicious paths or commands
 */
rule Persistence_Windows_Service_Suspicious
{
    meta:
        description = "Detects suspicious Windows service installations"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1543.003"
        severity = "high"

    strings:
        $reg_service = "SYSTEM\\CurrentControlSet\\services\\" ascii nocase wide

        // Service executable patterns
        $exe1 = "ImagePath" ascii wide
        $exe2 = "ServiceDll" ascii wide

        // Suspicious service paths
        $path1 = "AppData\\Local\\Temp" ascii nocase wide
        $path2 = "\\Users\\Public" ascii nocase wide
        $path3 = "C:\\Temp\\" ascii nocase wide
        $path4 = "C:\\Windows\\Temp" ascii nocase wide
        $path5 = "%TEMP%" ascii nocase wide
        $path6 = "%APPDATA%" ascii nocase wide

        // Suspicious commands
        $cmd1 = "powershell" ascii nocase wide
        $cmd2 = "cmd.exe /c" ascii nocase wide
        $cmd3 = "mshta" ascii nocase wide
        $cmd4 = "rundll32" ascii nocase wide
        $cmd5 = "regsvr32" ascii nocase wide

        // Encoded/obfuscated
        $enc1 = "-enc" ascii nocase wide
        $enc2 = "-EncodedCommand" ascii nocase wide
        $enc3 = "FromBase64String" ascii nocase wide

    condition:
        // Registry export or service config file
        filesize < 1MB and
        $reg_service and
        (
            // Suspicious service path
            any of ($path*) or
            // Service runs suspicious command
            (any of ($cmd*) and any of ($exe*)) or
            // Encoded payload in service
            (any of ($enc*) and any of ($exe*))
        )
}
