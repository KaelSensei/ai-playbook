# AI Playbook CLI

CLI tool to easily install and manage AI Playbook in your projects.

## Installation

### Option 1: Run directly with npx (Recommended)

```bash
npx ai-playbook-cli@latest install
```

### Option 2: Install globally

```bash
npm install -g ai-playbook-cli
ai-playbook install
```

## Usage

### Install AI Playbook

```bash
# Interactive installation (default: symlink)
npx ai-playbook-cli@latest install

# Force installation (overwrites existing .cursor)
npx ai-playbook-cli@latest install --force

# Copy files instead of symlinking
npx ai-playbook-cli@latest install --type copy

# Use submodule (shows instructions)
npx ai-playbook-cli@latest install --type submodule
```

### Check Installation Status

```bash
npx ai-playbook-cli@latest status
```

### Update AI Playbook

```bash
npx ai-playbook-cli@latest update
```

## Installation Types

### Symlink (Default)

Creates symbolic links from your project's `.cursor/` directory to the playbook files. This allows you to update the playbook in one place and have changes reflected in all projects.

**Pros:**
- Easy updates across all projects
- No duplication
- Always uses latest version

**Cons:**
- Requires playbook repository to be accessible
- Symlinks may not work on all systems

### Copy

Copies all playbook files directly into your project's `.cursor/` directory.

**Pros:**
- Works everywhere
- Project is self-contained
- No external dependencies

**Cons:**
- Updates require re-running install
- Files are duplicated

### Submodule

Uses Git submodules to link the playbook repository.

**Pros:**
- Version controlled
- Can pin specific versions
- Standard Git workflow

**Cons:**
- Requires Git submodule knowledge
- More setup steps

## Development

```bash
cd cli
npm install
npm run build
npm run dev install
```

## Publishing

```bash
cd cli
npm run build
npm publish
```
