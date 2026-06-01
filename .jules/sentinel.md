## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2026-06-01 - [SSH Heredoc Command Injection]
**Vulnerability:** Found a command injection vulnerability in `lib/greynoise.sh` where `$api_key` and `$workspace_id` were directly interpolated into an SSH heredoc block. If these variables contained malicious shell commands, they would be executed on the guest system with elevated privileges via sudo.
**Learning:** Directly interpolating user-controlled variables into an SSH heredoc block allows the user to break out of string context and execute arbitrary commands in the remote session.
**Prevention:** To prevent command injection over SSH, base64 encode variables on the host side (`base64 -w0`), and safely decode them inside the guest's execution context (`base64 -d`) instead of interpolating them directly or passing them as visible command-line arguments.
