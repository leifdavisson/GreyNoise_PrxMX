## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2024-05-18 - [SSH Command Injection]
**Vulnerability:** Found an SSH command injection vulnerability in `lib/greynoise.sh` where `api_key` and `workspace_id` variables were directly interpolated into an SSH heredoc block. If an attacker inputs `$(id > /tmp/pwn)` into the `workspace_id` input, the command is evaluated on the remote host.
**Learning:** Variables evaluated directly in SSH heredoc or inline commands run as the user context of the connection, opening the door for unsanitized data to run arbitrary commands.
**Prevention:** To prevent command injection in SSH execution blocks, base64 encode variables on the host and decode them within the guest's execution context instead of interpolating them directly.
