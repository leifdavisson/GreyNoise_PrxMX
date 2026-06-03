## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2026-06-03 - [SSH Command Injection in Guest Execution]
**Vulnerability:** Found an SSH command injection vulnerability in `lib/greynoise.sh` where unsanitized variables (`$api_key` and `$workspace_id`) are interpolated directly into an SSH here-document without escaping or safe evaluation.
**Learning:** When passing variables to an SSH session using a here-document (`<<EOF`), if variables are expanded before being sent to the remote host (e.g. they are not protected by quoting `<<'EOF'`), any shell metacharacters or command substitutions (e.g., `$(command)`) within those variables will be executed on the guest context.
**Prevention:** To safely pass variables across SSH execution blocks without interpolating raw input, encode variables in base64 on the host system and decode them directly into variables on the guest system.
