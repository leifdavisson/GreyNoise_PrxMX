## 2024-05-19 - [Fix Command Injection in SSH Execution]
**Vulnerability:** Command injection vulnerability in `lib/greynoise.sh` via unquoted heredoc executed over SSH.
**Learning:** Directly interpolating local variables into a heredoc block sent over SSH is unsafe, as shell meta-characters within the variables can be executed on the remote system. Additionally, passing sensitive variables as arguments to `ssh` is also unsafe, as it exposes secrets in the process list and logs.
**Prevention:** To safely pass variables across SSH boundaries, use `base64` encoding on the host side to serialize the data, pass the safe alphanumeric strings to the remote heredoc, and then decode them on the remote side using `base64 -d`.
