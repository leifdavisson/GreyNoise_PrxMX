## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2024-05-22 - [SSH Heredoc Command Injection]
**Vulnerability:** Found a command injection vulnerability in `lib/greynoise.sh` where user-provided variables (`api_key` and `workspace_id`) were directly interpolated into an SSH heredoc string (`<<EOF`). If an attacker inputs backticks or `$()` within these variables, the commands would be executed on the guest system.
**Learning:** Interpolating variables directly into heredocs that are passed to remote shells (like SSH) is dangerous. Even if quoted within the heredoc (e.g., `VAR="$val"`), malicious input like `$(malicious_cmd)` will still be evaluated when the guest shell parses the script.
**Prevention:** Base64 encode the variables on the host system, pass the encoded strings into the heredoc, and then base64 decode them on the guest system before use. This ensures the literal string value is preserved without triggering command substitution.
