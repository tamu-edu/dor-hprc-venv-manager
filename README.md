# dor-hprc-venv-manager

ModuLair - a Python virtual environment (venv) management tool suite
---
Paper: https://dl.acm.org/doi/10.1145/3731599.3767435 
## Table of Contents
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Creating Environments](#creating-environments)
  - [Default Behavior](#default-behavior)
  - [Specify Python Version (-p flag)](#-p--specify-python-version)
  - [Custom Toolchain (-t flag)](#-t--custom-toolchain)
- [Managing Environments](#managing-environments)
  - [Listing Environments](#listing-environments)
  - [Activating an Environment](#activating-an-environment)
  - [Deactivating an Environment](#deactivating-an-environment)
  - [Deleting an Environment](#deleting-an-environment)
- [Sharing Environments](#sharing-environments)
  - [Group Sharing (-g flag)](#group-sharing)
- [Key Features](#key-features)

---

## Installation

---

The **dor-hprc-venv-manager** tools can be installed in two ways: **Makefile or `setup.sh`**

Both methods will:

* Process template scripts in `src/`
* Substitute your configured paths
* Install the processed scripts into the `bin/` directory
* Create a writable log file in `logs/`

---

### 1. Prerequisites

* **bash** shell
* Write access to your chosen metadata and group metadata directories

---

### 2. Clone the Repository

```bash
cd <directory of your choice>
git clone git@github.com:tamu-edu/dor-hprc-venv-manager.git ModuLair
cd ModuLair
```

---

### 3. Choose Metadata Locations

The tools need two metadata directories:

* **User metadata directory (`METDIR` or `MODULAIR_METADATA_DIR`)**
  Stores virtual environment metadata for your personal environments.

* **Group metadata directory (`GROUPMETDIR` or `MODULAIR_GROUP_METADATA_DIR`)**
  Stores virtual environment metadata for shared group environments.

**Examples:**

| HPC Environment Type  | User Metadata Path    | Group Metadata Path |
| --------------------- | --------------------- | ------------------- |
| Scratch-based system  | `/scratch/user/$USER` | `/scratch/group`    |

---

### 4. Installation Methods

#### **Option A — Using Makefile**

```bash
# Build and install directly to bin/
make install \
    METDIR="/path/to/user/metadata" \
    GROUPMETDIR="/path/to/group/metadata"
```

Additional useful targets:

```bash
make all         - Build the project (default)
make build       - Process templates and prepare scripts
make install     - Build and install scripts to bin directory
make dev         - Development build (build but don't install)
make clean       - Remove generated files
make clean-all   - Remove generated files and logs
make help        - Show this help message
```

---

#### **Option B — Using setup.sh**

```bash
MODULAIR_METADATA_DIR="/path/to/user/metadata" \
MODULAIR_GROUP_METADATA_DIR="/path/to/group/metadata" \
./setup.sh
```

---

### 5. Add to Your PATH

After installation, add the `bin/` directory to your PATH:

```bash
export PATH="/path/to/dor-hprc-venv-manager/bin:$PATH"
```
---

## Quick Start

```bash
modulair create newEnv -d "Cool new environment"
modulair list
source modulair activate newEnv
source modulair deactivate
modulair delete newEnv
```

**What happens:**

* Creates an environment named `newEnv` with a description
* Lists environments to verify creation
* Activates the environment (must use `source`)
* Deactivates the environment and purges modules (must use `source`)
* Deletes it when no longer needed

---

## Creating Environments

### Default Behavior

ModuLair detects the current Python interpreter and compiler toolchain using EasyBuild by reading EBROOT-prefixed variables (e.g., EBROOTPYTHON, EBROOTGCCCORE).

```bash
modulair create my_env
```

It will:

* Detect loaded Python and compiler modules
* Record toolchain info in metadata
* Create a compatible environment

---

### -p — Specify Python Version

```bash
modulair create -p 3.11.5 my_env
```

* Skips EBROOT detection
* Uses toolchains to find matching GCCcore and dependencies
* Loads required modules
* Saves metadata for reproducibility

---

### -t — Custom Toolchain

```bash
modulair create -t "intelpython/2023b custom_module" my_env
```

* Records listed modules in metadata
* Auto-loads them during activation
* Useful for non-EasyBuild or custom HPC stacks

---

## Managing Environments

### Listing Environments

```bash
modulair list
```

Displays:

* Name
* Description
* Python and GCCcore versions/toolchains
* Owner

**Metadata Source:**
`metadata.json` stored in:

* User registry (default: `$SCRATCH`)
* Group registry (via `-g`)

**Flags:**

* `-a` — List user and group environments
* `-u` — List user environments
* `-g` — List group environments
* `-n` — Names only

---

### Activating an Environment

```bash
source modulair activate my_env
```

* Loads modules from metadata
* Sources `bin/activate`

---

### Deactivating an Environment

```bash
source modulair deactivate
```

* Runs the venv's built-in `deactivate`
* Purges loaded modules with `ml purge`

---

### Deleting an Environment

```bash
modulair delete my_env
```

* Prompts for confirmation (use `-y` to skip)
* Removes the environment
* Updates registry
* Deletes related files

---

## Sharing Environments

### Group Sharing

```bash
modulair create -g my_group my_env
```

* Stores venv in group registry
* Accessible to all group members
* Works with `-p` or `-t`

---

## Key Features

* Automatic detection of Python & toolchains via EBROOT
* Customizable Python version or toolchain selection
* Shared environments for seamless collaboration
* Metadata-driven management for reproducibility and GUI integration
* Seamless activation with correct module loading
