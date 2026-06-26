/*
 * YARA Rule: Mimikatz Credential Dumping Tool Detection
 * Author: Maher Mansour Mahyoub Ghaleb
 * Description: Detects Mimikatz binaries and common variants based on
 *              PE imports, strings, and characteristic patterns.
 * MITRE ATT&CK: T1003.001 - OS Credential Dumping: LSASS Memory
 * T1003.002 - OS Credential Dumping: SAM Database
 * Severity: CRITICAL
 */

rule Mimikatz_Generic_Detection
{
    meta:
        description = "Detects Mimikatz and common variants"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        reference = "https://github.com/gentilkiwi/mimikatz"
        mitre_attack = "T1003.001, T1003.002"
        severity = "critical"
        confidence = "high"

    strings:
        // Mimikatz-specific strings (case-insensitive ASCII)
        $str1 = "mimikatz" ascii nocase wide
        $str2 = "gentilkiwi" ascii nocase wide
        $str3 = "sekurlsa::" ascii nocase wide
        $str4 = "lsadump::" ascii nocase wide
        $str5 = "kerberos::" ascii nocase wide
        $str6 = "crypto::" ascii nocase wide
        $str7 = "vault::" ascii nocase wide
        $str8 = "token::" ascii nocase wide
        $str9 = "privilege::" ascii nocase wide
        $str10 = "logonpasswords" ascii nocase wide
        $str11 = "wdigest" ascii nocase wide
        $str12 = "tspkg" ascii nocase wide
        $str13 = "livessp" ascii nocase wide
        $str14 = "dpapi" ascii nocase wide
        $str15 = "kiwi" ascii nocase wide

        // Characteristic PE section names
        $pe_section1 = ".kiwi" ascii

    condition:
        // PE file (MZ header) and 5 or more string matches
        uint16(0) == 0x5A4D and
        filesize < 10MB and
        (
            5 of ($str*) or
            any of ($pe_section*)
        )
}
