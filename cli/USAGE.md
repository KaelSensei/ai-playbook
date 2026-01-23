# AI Playbook CLI Usage

## Quick Start

```bash
# Install in your project
npx ai-playbook-cli@latest install
```

## Installation Types

### 1. Symlink (Default)

Creates symbolic links to the playbook files. Best for development when you want to update the playbook in one place.

```bash
npx ai-playbook-cli@latest install
# or explicitly:
npx ai-playbook-cli@latest install --type symlink
```

**When to use:**
- You have the playbook repository cloned locally
- You want to update all projects at once
- You're actively developing the playbook

### 2. Copy

Copies all files directly into your project. Best for production or when you want a self-contained project.

```bash
npx ai-playbook-cli@latest install --type copy
```

**When to use:**
- You want a self-contained project
- You don't have the playbook repo locally
- You want to customize the playbook per project

### 3. Submodule

Shows instructions for using Git submodules. Best for version control and pinning specific versions.

```bash
npx ai-playbook-cli@latest install --type submodule
```

**When to use:**
- You want to pin a specific version
- You prefer Git submodules
- You want version control integration

## Commands

### Install

```bash
# Basic installation
npx ai-playbook-cli@latest install

# Force overwrite existing .cursor
npx ai-playbook-cli@latest install --force

# Specify installation type
npx ai-playbook-cli@latest install --type copy
```

### Status

Check if AI Playbook is installed and how:

```bash
npx ai-playbook-cli@latest status
```

### Update

Get instructions for updating:

```bash
npx ai-playbook-cli@latest update
```

## Examples

### New Project Setup

```bash
# Create new project
mkdir my-project && cd my-project
git init

# Install AI Playbook
npx ai-playbook-cli@latest install

# Start using Cursor with the playbook
# Open project in Cursor - rules and commands are ready!
```

### Existing Project

```bash
cd existing-project

# Check if already installed
npx ai-playbook-cli@latest status

# Install if needed
npx ai-playbook-cli@latest install --type copy
```

### Development Workflow

```bash
# Clone playbook repo
git clone https://github.com/YOUR_USERNAME/ai-playbook.git
cd ai-playbook/cli

# Install dependencies
npm install

# Build CLI
npm run build

# Test installation in another project
cd ../test-project
node ../ai-playbook/cli/dist/index.js install
```

## Troubleshooting

### "Could not find AI Playbook files"

**Solution:** Make sure you're running from the correct location or the package was built correctly.

- If using from npm: The package should include templates
- If using from source: Run `npm run build` in the cli directory first

### "Symlink creation failed"

**Solution:** On Windows, you may need administrator privileges or use Developer Mode.

- Enable Developer Mode in Windows Settings
- Or use `--type copy` instead

### ".cursor directory already exists"

**Solution:** Use `--force` to overwrite, or manually merge the directories.

```bash
npx ai-playbook-cli@latest install --force
```

## Next Steps

After installation:

1. Open your project in Cursor
2. The AI assistant will automatically use the rules from `.cursor/rules/`
3. Use commands like `/feature`, `/fix`, `/refactor` in Cursor chat
4. Customize rules in `.cursor/rules/` for your project needs
