## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2024-05-24 - SSH Command Injection Risk in Deployment Scripts
**Vulnerability:** Command injection vulnerability in SSH execution blocks. By directly interpolating variables (e.g., `api_key`, `workspace_id`) inside an SSH EOF block, malicious inputs containing quotes or command substitution syntax could execute arbitrary commands on the guest system.
**Learning:** Shell interpolation inside dynamically generated SSH commands can lead to unintended command execution. Directly passing unvalidated strings to shell interpreters like `ssh` creates an injection surface.
**Prevention:** Base64 encode all external variables on the host side before passing them into the SSH block. Inside the guest's execution context, securely decode them (`base64 -d`) into local variables before use. This neutralizes any special shell characters in the original input.
