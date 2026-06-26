/*
 * YARA Rule: Reverse Shell & Web Shell Detection
 * Author: Maher Mansour Mahyoub Ghaleb
 * Description: Detects common reverse shell patterns and webshells used
 *              for remote access persistence and command execution.
 * MITRE ATT&CK: T1059.004 - Unix Shell
 *              T1505.003 - Web Shell
 *              T1041 - Exfiltration Over C2 Channel
 * Severity: CRITICAL
 */

rule Reverse_Shell_Generic
{
    meta:
        description = "Detects generic reverse shell patterns across languages"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1059.004, T1505.003, T1041"
        severity = "critical"
        confidence = "high"

    strings:
        // Bash reverse shells
        $bash1 = "bash -i >& /dev/tcp/" ascii
        $bash2 = "/dev/tcp/" ascii
        $bash3 = "0<&196;exec 196<>/dev/tcp/" ascii
        $bash4 = "exec 5<>/dev/tcp/" ascii

        // Python reverse shells
        $py1 = "import socket,subprocess,os" ascii
        $py2 = "import pty; pty.spawn" ascii
        $py3 = "subprocess.call([\"/bin/sh" ascii
        $py4 = "socket.socket(socket.AF_INET,socket.SOCK_STREAM)" ascii
        $py5 = "os.dup2(s.fileno()" ascii

        // PHP reverse shells
        $php1 = "/bin/bash -c \\'$" ascii
        $php2 = "fsockopen(" ascii
        $php3 = "popen(" ascii
        $php4 = "proc_open" ascii
        $php5 = "system($_GET" ascii
        $php6 = "eval($_POST" ascii
        $php7 = "passthru(" ascii
        $php8 = "shell_exec(" ascii

        // Netcat
        $nc1 = "nc -e /bin/" ascii
        $nc2 = "nc.exe -e" ascii nocase wide
        $nc3 = "ncat -e" ascii

        // Perl reverse shell
        $perl1 = "use Socket;\\$i=" ascii
        $perl2 = "socket(SOCK,PF_INET" ascii

        // PowerShell reverse shell
        $ps1 = "$client = New-Object System.Net.Sockets.TCPClient" ascii nocase wide
        $ps2 = "$stream = $client.GetStream()" ascii nocase wide
        $ps3 = "[byte[]]$bytes = 0..65535|%{0}" ascii nocase wide
        $ps4 = "TcpClient(\"" ascii nocase wide

        // Java reverse shell
        $java1 = "Runtime.getRuntime().exec" ascii
        $java2 = "new Socket(" ascii
        $java3 = "ProcessBuilder" ascii

    condition:
        filesize < 1MB and
        (
            any of ($bash*) or
            any of ($py*) or
            any of ($php*) or
            any of ($nc*) or
            any of ($perl*) or
            any of ($ps*) or
            any of ($java*)
        )
}

/*
 * Rule: Common Web Shell Files
 * Detects known webshell file hashes and signatures
 */
rule WebShell_Generic
{
    meta:
        description = "Detects generic webshell patterns"
        author = "Maher Mansour Mahyoub Ghaleb"
        date = "2025-11-15"
        mitre_attack = "T1505.003"
        severity = "critical"

    strings:
        // PHP webshell functions
        $func1 = "eval(" ascii nocase
        $func2 = "assert(" ascii nocase
        $func3 = "system(" ascii nocase
        $func4 = "passthru(" ascii nocase
        $func5 = "shell_exec(" ascii nocase
        $func6 = "exec(" ascii nocase
        $func7 = "popen(" ascii nocase
        $func8 = "proc_open" ascii nocase
        $func9 = "pcntl_exec" ascii nocase

        // Input vector patterns
        $input1 = "$_GET" ascii
        $input2 = "$_POST" ascii
        $input3 = "$_REQUEST" ascii
        $input4 = "$_COOKIE" ascii
        $input5 = "$_SERVER['HTTP_" ascii

        // Base64 decode + execute
        $b64exec1 = "base64_decode" ascii
        $b64exec2 = "gzinflate" ascii
        $b64exec3 = "str_rot13" ascii

        // Obfuscation helpers
        $obf1 = "chr(" ascii
        $obf2 = "hex2bin" ascii
        $obf3 = "convert_uudecode" ascii

    condition:
        // PHP/ASP/JSP files
        (
            // PHP webshell: any exec function + any input vector
            (any of ($func*) and any of ($input*)) or
            // PHP with heavy obfuscation
            (2 of ($b64exec*) and any of ($func*)) or
            // Obfuscation + input + execution
            (2 of ($obf*) and any of ($input*) and any of ($func*))
        ) and
        filesize < 500KB
}
