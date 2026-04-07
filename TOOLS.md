# Shell Tools Reference

Quick reference for all tools configured in this dotfiles repository. See [README.md](README.md) for installation instructions.

## Shell Environment

### mise - Runtime & Tool Manager

**What it does**: mise is a modern replacement for asdf that manages language runtimes and CLI tools. It automatically activates when you enter a directory and ensures the correct versions are available.

**Key features**:
- Manages Python, Node.js, and other language runtimes
- Also manages standalone CLI tools (delta, just, xh, bottom, dust)
- Per-project version pinning via `.mise.toml` or `mise.toml`
- Global config in `~/.config/mise/config.toml`
- Auto-activates in `.zshenv` (no manual activation needed)

**How it works**:
```bash
# Check current tool versions
mise current

# Install a specific tool version
mise install python@3.13

# Use a specific version in current directory
mise use python@3.13

# List all installed tools
mise list

# Install all tools from config
mise install

# Run a command with specific version
mise exec python@3.13 -- python script.py
```

**Global config** (`~/.config/mise/config.toml`):
```toml
[tools]
python = "3.14"
node = "24"
delta = "latest"
just = "latest"
xh = "latest"
bottom = "latest"
dust = "latest"
```

**Practical workflow**:
```bash
# New project setup - pin specific versions
cd ~/Code/newproject
mise use python@3.12 node@20
mise install  # Installs pinned versions

# Check what's active
python --version  # Uses project-specific version
node --version    # Uses project-specific version

# Back to home - uses global versions
cd ~
python --version  # Uses 3.14 from global config
```

| Tool | Purpose | Key Features |
|------|---------|--------------|
| **zinit** | Zsh plugin manager | Loads plugins on-demand. Installed to `$XDG_DATA_HOME/zinit/zinit.git` |
| **starship** | Cross-shell prompt | Minimal prompt with git status, Python indicator, duration. Config: `.config/starship.toml` |
| **atuin** | History sync & search | Syncs history across machines. Ctrl+R for fuzzy search. Config: `.config/atuin/config.toml` |
| **zoxide** | Smart directory jumper | `z <dir>` jumps to frecency-ranked directories. `zz` for interactive selection |
| **direnv** | Directory-based env | Auto-loads/unloads `.envrc` when entering directories |

### zoxide - Smart Directory Jumper

**What it does**: zoxide is a smarter `cd` command that learns your habits. It tracks which directories you visit frequently and recently (frecency), then lets you jump to them with partial names.

**Key features**:
- Frecency algorithm (frequency + recency)
- Partial name matching
- Interactive selection with fzf
- Works across all directories you've visited
- Auto-integrated with zsh

**How to use**:
```bash
# Jump to directory by partial name
z myproject           # Jumps to ~/Code/myproject
z down                # Jumps to ~/Downloads
z code                # Jumps to ~/Code

# Interactive selection (fzf)
zz                    # Shows all visited dirs, select one

# Jump to subdirectory
z myp src             # Jumps to ~/Code/myproject/src

# Add directory manually
zoxide add ~/Documents

# Remove directory
zoxide remove ~/old-project

# List all tracked directories
zoxide query -l
```

**Practical workflow**:
```bash
# Normal usage builds database
cd ~/Code/project1
cd ~/Code/project2
cd ~/Downloads
cd ~/.config

# Now you can jump quickly
z pro1                # → ~/Code/project1
z pro2                # → ~/Code/project2
z down                # → ~/Downloads
z conf                # → ~/.config

# Interactive when unsure
zz                    # Shows list, pick with fzf
```

### atuin - Synced History Search

**What it does**: atuin replaces your shell history with a synced, searchable database. It stores full context (command, directory, exit code, duration) and syncs across all your machines.

**Key features**:
- Syncs history across machines (encrypted)
- Stores full context: directory, exit code, duration
- Fuzzy search with Ctrl+R
- Full-text search mode
- Filter by directory, exit status, time range
- SQLite database backend

**Configuration** (`~/.config/atuin/config.toml`):
```toml
search_mode  = "fulltext"
enter_accept = true

[sync]
records = true
```

**How to use**:
```bash
# Ctrl+R opens history search
# Type to fuzzy search across all history
# Arrow keys to navigate
# Enter to execute

# Filter by directory
# In search UI: Ctrl+D filters to current directory

# Filter by exit status
# In search UI: Ctrl+E shows only successful commands

# Login to sync
atuin login

# Sync manually
atuin sync

# Search from command line
atuin search "docker"

# History stats
atuin history list
atuin stats
```

**Practical workflow**:
```bash
# Type partial command, press Ctrl+R
docker                # Press Ctrl+R → shows all docker commands

# Find commands from specific time
# Ctrl+R, then scroll to find old commands

# Find commands that worked
# Ctrl+R, Ctrl+E → shows only commands with exit code 0

# Re-run command from months ago
# Ctrl+R, search "git commit", select and enter

# Sync between machines
# Run `atuin login` on all machines with same account
# History automatically syncs
```

## Modern CLI Replacements

### eza - Modern ls Replacement

**What it does**: eza is a modern replacement for `ls` with colors, icons, git status, and tree views. This configuration wraps it with custom aliases for different use cases.

**Key features**:
- Git status indicators (modified, staged, untracked)
- File type icons
- Tree view with configurable depth
- Smart group display (user/group names)
- Directory-first sorting
- Relative timestamps by default

**Custom aliases and usage**:
```bash
# Basic listings
ll              # Long list + hidden files (.dotfiles)
le              # Long list without hidden files
la              # All files with icons (simple list)
lt 3            # Tree view, depth=3

# Advanced options
ll -p           # Show permissions (instead of hiding)
ll -op          # Octal permissions (e.g., 755)
ll -t           # ISO timestamp (instead of relative)
ll -s           # Show total size of directory
ll -A           # Include hidden (alternative)

# Practical examples
ll -s src/      # Show total size of src directory
lt 2 node_modules/  # Tree view of node_modules, depth=2
ll -p -t *.py   # List Python files with permissions and timestamps

# Git integration
ll              # Shows git status: * (modified), + (staged), ? (untracked)
ll src/         # Git status shown for each file in src/
```

**What you'll see**:
```
drwxr-xr-x  user group  4KB  2h ago   src/
.rw-r--r--  user group  2KB  5m ago  *  main.py
.rw-r--r--  user group  1KB  1h ago  +  utils.py
```

Icons:  directory,  Python,  Node, etc. Git: * modified, + staged, ? untracked.

### ripgrep (rg) - Fast Search Tool

**What it does**: ripgrep is a super-fast search tool that respects gitignore and automatically skips hidden files and binary files. It's 10-100x faster than grep.

**Key features**:
- Automatically respects `.gitignore`
- Searches recursively by default
- Skips hidden files, binary files
- Built-in file type filtering
- Regex support with Unicode

**Basic usage**:
```bash
# Search in all files (respects gitignore)
rg 'pattern'

# Search specific file type
rg 'import' -t py        # Python files only
rg 'function' -t js      # JavaScript files only
rg 'TODO' -t md          # Markdown files only

# Show file names only
rg -l 'pattern'          # List matching files

# Count matches
rg -c 'pattern'          # Count matches per file

# Context lines
rg -C 3 'pattern'        # Show 3 lines before/after match
```

**Custom aliases**:
```bash
# Search ALL files (ignores gitignore)
rga 'pattern'            # rg -uu - searches everything including hidden/binary

# List matching files (ignores gitignore)
rgl 'pattern'            # rg -uu -l - list all files containing pattern
```

**Practical examples**:
```bash
# Find all Python imports
rg 'from typing import' -t py

# Find TODO comments
rg 'TODO' -t py -t js

# Search in hidden files (normally skipped)
rga '.env'               # Find .env files

# Find function definitions
rg 'def [a-zA-Z_]+\(' -t py

# Search specific directory
rg 'error' src/

# List all files containing 'config'
rgl 'config'             # Useful for knowing which files to edit
```

### fd - Fast File Finder

**What it does**: fd is a fast and user-friendly alternative to `find`. It's faster, has sensible defaults, and uses regex patterns instead of glob patterns.

**Key features**:
- Regex patterns for searching
- Parallel directory traversal
- Colorized output
- Smart case sensitivity
- Automatically ignores `.gitignore` patterns
- Icon support (when configured)

**Basic usage**:
```bash
# Find by name (regex pattern)
fd 'pattern'             # Find files/dirs matching pattern

# Find files only
fd -t f 'pattern'

# Find directories only
fd -t d 'pattern'

# Find with extension
fd -e py                 # All Python files
fd -e js -e ts           # All JS and TS files

# Find in specific directory
fd 'pattern' src/

# Execute command on results
fd -e py -x rm           # Remove all Python files
fd -t f -x chmod 644     # Set permissions on all files
```

**Practical examples**:
```bash
# Find all config files
fd -e yaml -e yml -e json -e toml config

# Find Python test files
fd '_test\.py$'

# Find recently modified files
fd --changed-within 1d   # Files modified in last day
fd --changed-before 2h   # Files changed more than 2 hours ago

# Find empty directories
fd -t d --empty

# Find large files
fd -t f --size +100m

# Find and edit
fd 'TODO' -x vim         # Open all files containing TODO in vim

# Find and execute
fd -e jpg -x rm          # Remove all JPG files
```

### delta - Enhanced Git Diff Viewer

**What it does**: delta is a syntax-highlighting pager for git diffs. It shows diffs side-by-side with line numbers and syntax highlighting.

**Key features**:
- Side-by-side diff view
- Line numbers
- Syntax highlighting for code
- Git blame integration
- Hyperlink support
- File header decorations

**Configuration** (in `.gitconfig`):
```ini
[core]
pager = delta

[interactive]
diffFilter = delta --color-only

[delta]
navigate     = true      # Use n/p to navigate diffs
light        = false     # Dark mode
side-by-side = true
line-numbers = true
```

**How to use**:
```bash
# Automatic - used by git commands
git diff                  # Shows side-by-side diff
git show                  # Shows commit diff
git log -p                # Shows log with diffs

# Navigate diffs
# In delta pager: n (next file), p (previous file)

# Standalone usage
delta file1.txt file2.txt

# Compare directories
delta dir1/ dir2/
```

**What you'll see**:
```
──────────────────────────────────────────────────────────────
file.py
──────────────────────────────────────────────────────────────
  10 │ def hello():          │  10 │ def hello():
  11 │     print("world")    │  11 │     print("hello")
                         ↑─ ── ↑
                        deleted  added
```

### dust - Disk Usage Analyzer

**What it does**: dust is a more intuitive version of `du`. It shows disk usage with a visual tree-like display, making it easy to see which directories consume the most space.

**Key features**:
- Visual tree display
- Recursive by default
- Shows percentage of total
- Smart depth limiting
- File/directory filtering

**Basic usage**:
```bash
# Show disk usage of current directory
dust

# Specific directory
dust ~/Code

# Limit depth
dust -d 2                 # Only 2 levels deep

# Show number of files
dust -c                   # Count files instead of size

# Filter by pattern
dust -e '.git'            # Exclude .git directories

# Show files only
dust -f                   # Only files, not directories

# Reverse sort (largest at bottom)
dust -r
```

**Practical examples**:
```bash
# Find what's consuming space in home
dust -d 3 ~

# Check project size
dust ~/Code/myproject

# Find large files
dust -f -d 0 ~/Downloads

# Exclude node_modules and .git
dust -e node_modules -e .git ~/Code
```

**What you'll see**:
```
  5.0G ┌─┐ ~/Code/myproject
  2.5G ├── node_modules/
  1.2G ├── src/
  0.8G ├── dist/
  0.5G ├── .git/
```

### bottom - System Monitor

**What it does**: bottom is a customizable cross-platform system monitor, similar to htop/top but with better visuals and more features.

**Key features**:
- CPU, memory, disk, network graphs
- Process list with tree view
- Temperature sensors
- Battery status
- Customizable layout
- Keyboard shortcuts

**Basic usage**:
```bash
# Start system monitor
btm

# With specific layout
btm --layout default

# Temperature in Celsius
btm -c
```

**Interactive controls**:
```
Navigation:
  ↓/↑        Move down/up in process list
  →/←        Change widget focus
  Tab        Cycle through widgets
  Enter      Expand/collapse tree

Processes:
  dd         Kill process (SIGTERM)
  kk         Kill process (SIGKILL)
  c          Sort by CPU
  m          Sort by memory
  p          Sort by PID
  T          Toggle tree view

Search/Filter:
  /          Search processes
  f          Filter processes

Layout:
  1-5        Show specific widget
  +          Increase widget size
  -          Decrease widget size

Other:
  q          Quit
  h/?        Help
  r          Refresh rate toggle
```

| Tool | Replaces | Key Commands |
|------|----------|--------------|
| **bat** | `cat` | Syntax highlighting, git integration. Used implicitly by smart `cat` wrapper |
| **ripgrep (rg)** | `grep` | `rga` (search all files), `rgl` (list matching files). Faster than grep, respects gitignore |
| **fd** | `find` | `fd <pattern>` finds files. Faster, smarter defaults |
| **delta** | `git diff` | Side-by-side diffs, line numbers, navigation. Git pager in `.gitconfig` |
| **dust** | `du` | `dust <dir>` shows disk usage. Visual, intuitive output |
| **bottom** | `top` | `btm` monitors system. Cross-platform, customizable |

## Development Tools

### just - Command Runner

**What it does**: just is a command runner similar to `make` but simpler and more focused on running project-specific tasks. It uses a `justfile` to define recipes.

**Key features**:
- Simple syntax (no Makefile complexity)
- Recipes with parameters
- Recipe dependencies
- Private recipes (don't show in list)
- Variables and functions

**Example justfile**:
```just
# Project tasks

# Build the project
build:
    cargo build --release

# Run tests
test:
    cargo test

# Run with args
run *args:
    cargo run {{args}}

# Build and test (depends on build)
check: build test

# Clean build artifacts
clean:
    rm -rf target/

# Install dependencies
install:
    npm install

# Development server with port option
serve port="3000":
    npm run dev --port {{port}}

# Private helper (won't show in list)
[private]
backup:
    cp data.db data.db.bak
```

**How to use**:
```bash
# List available recipes
just --list

# Run a recipe
just build
just test
just run

# Run with arguments
just run --release
just serve 8080

# Run recipe with dependencies
just check  # Runs build, then test

# Show recipe source
just --show build

# Evaluate variable
just --evaluate

# Dry run (show commands without executing)
just --dry-run build
```

**Practical workflow**:
```bash
# Start new project
cd ~/Code/newproject

# Create justfile
cat > justfile <<'EOF'
build:
    npm run build

dev:
    npm run dev

test:
    npm test
EOF

# Run tasks
just dev        # Start dev server
just build      # Build for production
just test       # Run tests
```

### xh - HTTP Client

**What it does**: xh is a friendly HTTP client similar to HTTPie but written in Rust. It makes HTTP requests with intuitive syntax and beautiful output.

**Key features**:
- Intuitive syntax (GET/POST as arguments)
- JSON support with automatic serialization
- Colorized output
- Request history
- HTTPS by default
- Download mode

**Basic usage**:
```bash
# GET request
xh GET httpbin.org/get
xh httpbin.org/get        # GET is default

# POST with JSON (automatic serialization)
xh POST httpbin.org/post name="John" age:=30

# POST with form data
xh POST httpbin.org/post -f name="John"

# POST with file upload
xh POST httpbin.org/post file@data.json

# Custom headers
xh GET httpbin.org/get Authorization:"Bearer token"

# Query parameters
xh GET httpbin.org/get key==value another==param

# Download file
xh --download httpbin.org/json -o response.json

# Inspect request/response
xh --print=bB httpbin.org/get  # Print request body and headers
```

**Practical examples**:
```bash
# Test API endpoint
xh GET https://api.example.com/users

# POST JSON data
xh POST https://api.example.com/users \
  name="Alice" \
  email="alice@example.com" \
  active:=true

# REST API with authentication
xh GET https://api.github.com/user \
  Authorization:"Bearer $GITHUB_TOKEN"

# Health check
xh HEAD https://example.com

# Debug request/response
xh --verbose GET https://httpbin.org/get

# GraphQL query
xh POST https://api.example.com/graphql \
  query='{"query": "{ users { name } }"}'
```

| Tool | Purpose | Usage |
|------|---------|-------|
| **python 3.14** | Python runtime | Managed by mise. `py` or `python` alias → `python3`. `venv` activates `.venv` |
| **node 24** | Node runtime | Managed by mise. `pnpm` via corepack is default package manager |
| **jq** | JSON processor | `jq '.' <file>` parses/transforms JSON |
| **yq** | YAML processor | `yq '.' <file>` parses/transforms YAML |

## Shell Plugins (via zinit)

| Plugin | Feature | Behavior |
|--------|---------|----------|
| **zsh-autosuggestions** | Auto-complete | Grey suggestions as you type. Strategy: history + completion |
| **zsh-history-substring-search** | History navigation | Up/Down arrows search by substring |
| **fzf-tab** | Tab completion | Fuzzy completion with preview. Triggered by Tab |
| **fast-syntax-highlighting** | Syntax colors | Real-time highlighting as you type |
| **zsh-completions** | Extra completions | Additional completion definitions for many tools |

## Viewers & Documentation

### csvlens - Interactive CSV Viewer

**What it does**: csvlens is an interactive terminal viewer for CSV files. It's like a spreadsheet viewer in your terminal with sorting, filtering, and searching capabilities.

**Key features**:
- Interactive navigation (scroll, jump to rows/columns)
- Sort by any column
- Filter rows by content
- Search across all cells
- Column resizing
- Auto-detects CSV format

**How to use**:
```bash
# Open a CSV file
csvlens data.csv

# Via smart cat wrapper
cat data.csv  # Opens csvlens automatically
```

**Interactive controls**:
```
Navigation:
  ↓/↑        Move down/up one row
  →/←        Move right/left one column
  PgDown/PgUp  Move 10 rows
  Home/End   Jump to first/last row
  G          Jump to specific row number

Sorting:
  s          Sort by current column
  S          Sort by current column (descending)
  r          Reset sort order

Filtering:
  /          Enter filter mode
  Type text  Filter rows containing text
  Esc        Clear filter

Search:
  f          Find mode (search all cells)
  Type text  Search for text
  n          Next match
  N          Previous match

Columns:
  h          Toggle column headers
  w          Adjust column width

Other:
  ?          Help screen
  q          Quit
```

**Practical workflow**:
```bash
# View large CSV file
csvlens transactions.csv

# Sort by amount column (navigate to column, press 's')
# Filter for specific date (press '/', type '2024-01')
# Find all occurrences of 'error' (press 'f', type 'error')

# Quick check via cat
cat sales.csv  # Opens csvlens if it's CSV
```

### aichat - Local LLM Client

**What it does**: aichat is a CLI chat client for LLMs. It connects to local LLM servers (LM Studio, Ollama) or remote APIs (OpenAI, etc.) and lets you query AI models from the terminal.

**Key features**:
- Connects to multiple LLM backends
- Local LM Studio integration configured
- Chat REPL mode or one-shot queries
- Role-based prompts (e.g., `cmd` role for commands)
- Session management
- Custom model configurations

**Configuration** (`~/.config/aichat/config.yaml`):
```yaml
model: lms:zai-org/glm-4.7-flash
clients:
  - type: openai-compatible
    name: lms              # Local LM Studio
    api_base: http://localhost:1234/v1
    models:
      - zai-org/glm-4.7-flash
      - qwen/qwen3-coder-30b
      - ministral-3-14b-reasoning-2512
  - type: openai-compatible
    name: htpc             # Remote LM Studio on HTPC
    api_base: http://192.168.1.20:1234/v1
    models:
      - ministral-3-3b-instruct-2512
```

**How to use**:
```bash
# One-shot query (quick alias)
q 'explain what mise does'
q 'how to install python packages with uv'

# Start chat REPL
aichat

# Switch models
aichat --model lms:qwen/qwen3-coder-30b

# Use specific role
aichat -r cmd 'list files in directory'
aichat -r code 'write a python function to read csv'

# Non-interactive query
aichat -e 'convert this to lowercase: HELLO WORLD'
```

**Shell integration - Alt+E**:
```zsh
# Type something in terminal
user@host:~$ explain what docker compose does

# Press Alt+E
# Buffer is sent to aichat, result replaces buffer:
user@host:~$ Docker Compose is a tool for defining and running multi-container Docker applications...
```

**Practical workflows**:
```bash
# Quick command help
q 'how to use ripgrep to find python imports'
q 'git command to squash last 3 commits'

# Code generation
aichat -r code 'write a bash function to check if file exists'

# Learning new tools
aichat 'explain the difference between fd and find'

# In chat REPL
> .role cmd
> list all docker containers with their IPs
docker ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{ .NetworkSettings.IPAddress }}'

> .model htpc:ministral-3-3b-instruct-2512  # Switch to HTPC model
> what is mise?
```

| Tool | Purpose | Key Features |
|------|---------|--------------|
| **glow** | Markdown viewer | `md <file>` renders markdown with pagination. Config: `.config/glow/glow.yml` |
| **tealdeer (tldr)** | Simplified man pages | `tldr <command>` shows practical examples. Auto-updated cache |
| **navi** | Cheatsheet browser | Interactive cheatsheet browser. Widget integrated in shell |

## AI & Automation

| Tool | Purpose | Key Features |
|------|---------|--------------|
| **aichat** | Local LLM client | `q '<prompt>'` sends query. Alt+E transforms buffer content. Config: `.config/aichat/config.yaml` |
| **browser-use** | Browser automation | `browser-use <args>` runs headed browser automation with profile |
| **with_firecrawl** | Firecrawl wrapper | `with_firecrawl <cmd>` runs command with Firecrawl API env loaded |

## Git & GitHub

| Tool | Purpose | Key Features |
|------|---------|--------------|
| **gh** | GitHub CLI | `gh pr`, `gh repo`, `gh issue`. Git credential helper configured |
| **delta** | Git diff viewer | Side-by-side, line-numbers, navigation enabled in `.gitconfig` |

## Custom Keybindings

| Binding | Action | Context |
|---------|--------|---------|
| `Ctrl+R` | Atuin history search | Fuzzy search across synced history |
| `Up/Down` | History substring search | Search by what you already typed |
| `Alt+E` | AI buffer transform | Send current line to aichat, replace with result |
| `Alt+←` / `Alt+→` | Word navigation | Jump backward/forward by word |
| `Ctrl+←` / `Ctrl+→` | Word navigation | Alternative word jump bindings |
| `Ctrl+X Ctrl+E` | Edit command line | Open command in $EDITOR, execute on save |
| `Tab` | FZF completion | Fuzzy tab completion with previews |

## Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `py`, `python` | `python3` | Python shortcut |
| `venv` | `source .venv/bin/activate` | Activate virtual environment |
| `dc` | `docker compose` | Docker compose shortcut |
| `q` | `aichat -r cmd` | Quick AI query |
| `s` | `kitten ssh` | Kitty SSH wrapper (if kitten available) |
| `e` | `gnome-text-editor` | Editor shortcut (if available) |
| `md` | `glow -p` | Markdown viewer |
| `rga` | `rg -uu` | Ripgrep all files (ignore gitignore) |
| `rgl` | `rg -uu -l` | Ripgrep list matching files |

## Custom Functions

### Smart `cat` Wrapper
```zsh
cat file.md   # → glow -p (markdown)
cat file.csv  # → csvlens (CSV viewer)
cat file.txt  # → regular cat
```

### `with_firecrawl`
```zsh
with_firecrawl ./script.py  # Runs script with FIRECRAWL_API_KEY loaded
```

### `browser-use`
```zsh
browser-use --headed --profile "Default"  # Runs with DISPLAY/XAUTHORITY set
```

### `_ls_core` (eza wrapper)
```zsh
ll          # Long list + hidden files
le          # Long list (no hidden)
la          # All files, icons
lt 3        # Tree view, depth=3
ll -p       # Show permissions
ll -t       # ISO timestamp
ll -s       # Show total size
```

## Config File Locations

| Tool | Config Path | Managed By |
|------|-------------|------------|
| mise | `~/.config/mise/config.toml` | Symlinked from repo |
| starship | `~/.config/starship.toml` | Symlinked from repo |
| atuin | `~/.config/atuin/config.toml` | Symlinked from repo |
| glow | `~/.config/glow/glow.yml` | Symlinked from repo |
| aichat | `~/.config/aichat/config.yaml` | Symlinked from repo |
| ghostty | `~/.config/ghostty/config` | Symlinked from repo |
| git | `~/.gitconfig` | Symlinked from repo |
| firecrawl | `~/.config/firecrawl.env` | Symlinked from repo (template: `firecrawl.env.example`) |

## Runtime Versions (mise managed)

| Runtime | Version | Notes |
|---------|---------|-------|
| Python | 3.14 | Primary Python runtime |
| Node | 24 | Primary Node runtime |
| delta | latest | Git diff pager |
| just | latest | Command runner |
| xh | latest | HTTP client |
| bottom | latest | System monitor |
| dust | latest | Disk usage analyzer |

## Installation Notes

All tools installed by `scripts/install.sh`:

- DNF packages: fzf, bat, direnv, glow, tealdeer, navi, ghostty, ripgrep, fd, jq, yq, zsh, git, gh
- Standalone: mise, starship, atuin, zoxide, Rust (cargo)
- Cargo tools: eza, csvlens, aichat
- Node: corepack enabled (pnpm default)
- zinit: cloned to `$XDG_DATA_HOME/zinit/zinit.git`

Safe to re-run install script (idempotent). See `scripts/check.sh` for validation.