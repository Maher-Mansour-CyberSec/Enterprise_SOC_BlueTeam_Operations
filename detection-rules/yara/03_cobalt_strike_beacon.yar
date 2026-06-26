/*
 * YARA Rule: Cobalt Strike Beacon Detection
 * Author: Maher Mansour Mahyoub Ghaleb
 * Description: Detects Cobalt Strike Beacon payloads and common configurations
 *              based on characteristic strings, PE features, and default patterns.
 * MITRE ATT&CK: T1071.001 - Web Protocols (C2)
 *              T1055 - Process Injection
 *              T1095 - Non-Application Layer Protocol
 * Severity: CRITICAL
 */

rule CobaltStrike_Beacon_Generic
{
    meta:
        description = "Detects Cobalt Strike Beacon and common variations"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        reference = "https://www.cobaltstrike.com/"
        mitre_attack = "T1071.001, T1055, T1095"
        severity = "critical"
        confidence = "medium-high"

    strings:
        // Default Cobalt Strike configuration markers
        $config1 = "%s as %s\\%s: %d" ascii wide
        $config2 = "beacon.dll" ascii nocase wide
        $config3 = "beacon.x64.dll" ascii nocase wide
        $config4 = "beacon_exe" ascii wide

        // Malleable C2 indicators
        $c2_1 = "Malformed request" ascii wide
        $c2_2 = "%s received. %d bytes" ascii wide
        $c2_3 = "Could not send" ascii wide
        $c2_4 = "Invalid Response" ascii wide
        $c2_5 = "%s HTTP/1.1 200 OK" ascii wide
        $c2_6 = "%s HTTP/1.1 404" ascii wide

        // Process injection APIs (commonly used in CS)
        $api1 = "VirtualAllocEx" ascii
        $api2 = "WriteProcessMemory" ascii
        $api3 = "CreateRemoteThread" ascii
        $api4 = "NtMapViewOfSection" ascii
        $api5 = "RtlCreateUserThread" ascii

        // Beacon sleep/masking
        $sleep1 = "SleepMask" ascii wide
        $sleep2 = "sleep_mask" ascii wide
        $sleep3 = "BeaconSleepMask" ascii wide

        // DNS beacon indicators
        $dns1 = "beacon_dns" ascii wide
        $dns2 = "DNS Beacon" ascii wide
        $dns3 = "dns_txt_record" ascii wide
        $dns4 = "%s.%s" ascii wide

        // Network indicators
        $net1 = "%windir%\\syswow64" ascii wide
        $net2 = "\\\\%s\\pipe\\%s" ascii wide

        // Watermark detection (CS uses watermarks)
        $wm1 = { 2E 2E 2E ?? ?? ?? ?? ?? 2E 2E 2E }
        $wm2 = { 2E ?? ?? ?? ?? ?? 2E }

    condition:
        uint16(0) == 0x5A4D and
        filesize < 5MB and
        (
            // Strong indicators
            2 of ($config*) or
            2 of ($c2_*) or
            // Sleep mask + injection APIs
            (any of ($sleep*) and 2 of ($api*)) or
            // DNS beacon + any network indicator
            (any of ($dns*) and any of ($net*)) or
            // Watermark pattern (high confidence)
            any of ($wm*)
        )
}

/*
 * Rule: Cobalt Strike DLL Beacon
 * Detects DLL-based CS beacons based on exported function patterns
 */
rule CobaltStrike_Beacon_DLL
{
    meta:
        description = "Detects Cobalt Strike Beacon DLL artifacts"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1071.001, T1055.001"
        severity = "critical"

    strings:
        $dll_export1 = "DllMain" ascii
        $dll_export2 = "StartW" ascii wide
        $dll_export3 = "Beacon" ascii
        $dll_export4 = "ReflectiveLoader" ascii

        $config = { 00 01 00 01 00 02 ?? ?? 00 02 00 02 ?? ?? 00 03 00 02 }

    condition:
        uint16(0) == 0x5A4D and
        filesize < 2MB and
        (
            (3 of ($dll_export*) and uint32(uint32(0x3C)) == 0x00004550) or
            $config
        )
}
