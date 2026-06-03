## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2024-05-17 - [SSH Command Injection via Unescaped Variables]
**Vulnerability:** Found a command injection vulnerability in `lib/greynoise.sh` where user inputs `$api_key` and `$workspace_id` were directly interpolated into an unquoted here-doc (`<<EOF`) passed to SSH.
**Learning:** Variables interpolated into strings that are then executed in another shell context (like SSH) can break out of their quotes and execute arbitrary commands on the remote machine if they contain shell metacharacters like `";` or `$()`.
**Prevention:** To prevent command injection in SSH execution blocks, base64 encode variables on the host and decode them within the guest's execution context instead of interpolating them directly. Also, always quote variables inside the execution block.
