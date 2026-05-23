## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.

## 2024-10-24 - Prevent Command Injection in SSH Execution Blocks
**Vulnerability:** Command injection vulnerability in SSH execution block (`lib/greynoise.sh`) where sensitive user inputs (`api_key` and `workspace_id`) were interpolated directly into the `EOF` heredoc.
**Learning:** Directly interpolating host variables into a script sent over SSH without proper quoting/encoding allows an attacker to inject arbitrary shell commands if the variables are crafted maliciously.
**Prevention:** To prevent command injection in SSH execution blocks, always base64 encode variables on the host side, and then base64 decode them inside the guest's execution context.
