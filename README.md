# bash-utils

Reusable, namespaced Bash utility functions for shell scripts and automation.

Designed to be included via **Git submodules** for safe, versioned reuse.

---

## ✨ Features

- Safe under `set -euo pipefail`
- Namespaced functions (`util::`)
- No side effects on source
- Clear error handling
- Designed for sourcing, not execution

---

## 📁 Repository Structure

```
bash-utils/
├── common/
│ └── utils.sh
└── README.md
```

---

## 🚀 Usage (via Git submodule)

### 1. Add as submodule

```bash
git submodule add git@github.com:YOUR_USERNAME/bash-utils.git common/bash-utils
git submodule update --init --recursive
```

### 2. Source in your script

```bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR

source "$ROOT_DIR/common/bash-utils/common/utils.sh"
```

---

## 🧩 Available Functions


### 1. log
```bash
util::log MESSAGE [COLOR]
```

Print formatted log output.

```bash
util::log "Starting script"
util::log "Success" "$UTIL_GREEN"
util::log "Error" "$UTIL_RED"
```

---

### 2. confim

```bash
util::confirm [PROMPT]
```

Ask user for confirmation.

```bash
if util::confirm "Continue? [y/N]: "; then
    util::log "Confirmed"
fi
```

---

### 3. switchToDir

```bash
util::switchToDir TARGET
```

Change directory safely.

* root → project root (ROOT_DIR must be set)
* any other value → passed directly to cd

```bash
util::switchToDir root
util::switchToDir config
```


## 📜 License

GNU GENERAL PUBLIC LICENSE 3.0

---

#### Developed by
> Alauddin Ansari
