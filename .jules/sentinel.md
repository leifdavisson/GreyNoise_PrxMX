## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2026-05-26 - [SSH Command Injection via Unsanitized Heredoc Interpolation]
**Vulnerability:** Found a command injection vulnerability in `lib/greynoise.sh` where user-supplied inputs (`$api_key` and `$workspace_id`) were interpolated directly into a bash heredoc passed to an SSH connection. An attacker could craft inputs containing backticks or `$()` to execute arbitrary code within the guest's context.
**Learning:** Directly interpolating user-supplied strings into shell environments—even across SSH connections or inside heredocs—allows an attacker to break out of string context and execute shell commands.
**Prevention:** To safely pass variables over SSH or into nested shells without triggering command substitution on the host or execution on the guest (before intended), base64 encode the values on the host. Then pass the base64 string and decode it on the guest.
