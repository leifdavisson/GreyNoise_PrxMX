# GreyNoise Proxmox Plugin

<div align="center">
  
  ```text
  ____                      _   _       _         
 / ___|_ __ ___ _   _      | \ | | ___ (_)___  ___ 
| |  _| '__/ _ \ | | |_____|  \| |/ _ \| / __|/ _ \
| |_| | | |  __/ |_| |_____| |\  | (_) | \__ \  __/
 \____|_|  \___|\__, |     |_| \_|\___/|_|___/\___|
                |___/                              
  ```
  
  **Automated GreyNoise Sensor Deployment for Proxmox VE**

  [![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
  [![Proxmox VE](https://img.shields.io/badge/Proxmox-VE%209.1-orange.svg)](https://www.proxmox.com)
  [![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)

</div>

---

## 🚀 Overview

The **GreyNoise Proxmox Plugin** is a modular, TUI-driven installer designed to deploy autonomous GreyNoise sensors within your Proxmox Virtual Environment. It follows the conventions of the popular [Proxmox VE Helper-Scripts](https://tteck.github.io/Proxmox/) to provide a seamless, state-of-the-art installation experience.

### Key Features

- 🖥️ **Interactive TUI**: User-friendly installation guided by `whiptail`.
- 📦 **Modular Architecture**: Clean separation of VM, Networking, and Cloud-Init logic.
- 🔍 **Dynamic Storage Discovery**: Automatically identifies and sorts Proxmox storage pools by free space.
- 🛡️ **Hardened Networking**: Deterministic IP allocation with ARP and Ping collision detection.
- ⚡ **Cloud-Init Powered**: Fully automated guest provisioning including SSH keys and guest agent setup.
- 🤖 **GreyNoise Bootstrap**: Automated registration with the GreyNoise API and Workspace.

---

## 🛠️ Installation

### Prerequisites

- A running Proxmox VE host (8.x recommended).
- Internet connectivity for downloading cloud images and the GreyNoise bootstrap.
- A [GreyNoise API Key](https://greynoise.io/) and Workspace ID.

### Quick Start

Run the following command on your Proxmox host as `root`:

```bash
git clone https://github.com/leifdavisson/GreyNoise_PrxMX.git
cd GreyNoise_PrxMX
chmod +x install.sh
./install.sh
```

---

## 📂 Project Structure

```text
GreyNoise_PrxMX/
├── install.sh           # Main entrypoint (Orchestrator)
├── lib/
│   ├── common.sh        # UI helpers, error handling, and terminal controls
│   ├── network.sh       # IP allocation and network validation
│   ├── storage.sh       # Proxmox storage discovery and sorting
│   ├── vm.sh            # VM creation and image management
│   ├── cloudinit.sh     # Custom Cloud-Init snippet generation
│   └── greynoise.sh     # GreyNoise sensor bootstrap logic
├── config/
│   └── defaults.conf    # Environment defaults (Rename from .example)
├── LICENSE              # GNU AGPL-3.0
└── README.md            # You are here
```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place! Any contributions you make are **greatly appreciated**. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## ⚖️ License

Distributed under the **GNU Affero General Public License v3.0**. See `LICENSE` for more information.

---

<p align="center">
  <i>Developed with ❤️ for the GreyNoise and Proxmox communities.</i>
</p>
