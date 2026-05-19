## 2024-05-17 - [Bash Arithmetic Command Injection]
**Vulnerability:** Found a Bash arithmetic command injection vulnerability in `lib/vm.sh` where `[[ "$vlan" -gt 0 ]]` is used without validating that `$vlan` is an integer. If an attacker inputs `a[$(id > /tmp/pwn)]`, the command substitution within the array index is evaluated during the arithmetic comparison.
**Learning:** Bash arithmetic expressions (used in `[[ ... -gt ... ]]`, `((...))`, `let`, etc.) evaluate strings as variable names or mathematical expressions. If the string contains an array index like `a[...]`, the contents of the brackets are evaluated, allowing command injection.
**Prevention:** Always validate that the variable strictly contains only digits (e.g., `[[ "$var" =~ ^[0-9]+$ ]]`) *before* using it in an arithmetic context, or use standard string comparison if appropriate.
## 2024-05-19 - Command Injection via SSH Heredoc Expansion
**Vulnerability:** Unquoted heredocs (`<<EOF`) evaluate variables locally before sending over SSH, allowing command injection on the remote host if the variables contain shell metacharacters (e.g., `"; id #"`).
**Learning:** When passing data via SSH or evaluating it in unquoted heredocs, direct string interpolation is dangerous because the resulting string is executed as a script on the remote host.
**Prevention:** Use `printf '%q'` to safely escape variables before substituting them into dynamically generated scripts, ensuring they are interpreted strictly as data rather than code.
