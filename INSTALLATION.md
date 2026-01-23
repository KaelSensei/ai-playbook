# Installation & Deployment Guide

This guide covers how to install, build, test, and deploy the AI Playbook CLI tool.

## For End Users

### Quick Install

```bash
# Install AI Playbook in your project
npx ai-playbook-cli@latest install
```

That's it! The CLI will set up `.cursor/rules/`, `.cursor/commands/`, and `.cursor/docs/` in your project.

### Installation Options

```bash
# Symlink installation (default - updates automatically)
npx ai-playbook-cli@latest install

# Copy files directly (self-contained)
npx ai-playbook-cli@latest install --type copy

# Get submodule instructions
npx ai-playbook-cli@latest install --type submodule
```

### Verify Installation

```bash
# Check installation status
npx ai-playbook-cli@latest status
```

---

## For Developers (Building & Publishing)

### Prerequisites

- Node.js 16+ or Bun
- npm account with publish access
- Git repository set up

### Local Development Setup

1. **Clone and install dependencies:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ai-playbook.git
   cd ai-playbook/cli
   npm install
   ```

2. **Build the CLI:**
   ```bash
   npm run build
   ```
   This will:
   - Copy `.cursor` files to `templates/.cursor`
   - Compile TypeScript to `dist/`

3. **Test locally:**
   ```bash
   # Test the CLI in development mode
   npm run dev install
   
   # Or test in another project
   cd /path/to/test-project
   node /path/to/ai-playbook/cli/dist/index.js install
   ```

### Testing Before Publishing

1. **Create a test package:**
   ```bash
   cd cli
   npm run build
   npm pack
   ```
   This creates `ai-playbook-cli-1.0.0.tgz`

2. **Test the package:**
   ```bash
   # In a test project
   cd /path/to/test-project
   npm install /path/to/ai-playbook/cli/ai-playbook-cli-1.0.0.tgz
   npx ai-playbook install
   ```

3. **Verify everything works:**
   - Check that `.cursor/rules/` exists
   - Check that `.cursor/commands/` exists
   - Verify symlinks or copies were created correctly

### Publishing to npm

1. **Update version in `cli/package.json`:**
   ```json
   {
     "version": "1.0.1"
   }
   ```

2. **Update repository URLs** (if not already done):
   ```json
   {
     "repository": {
       "type": "git",
       "url": "https://github.com/YOUR_USERNAME/ai-playbook.git",
       "directory": "cli"
     }
   }
   ```

3. **Login to npm:**
   ```bash
   npm login
   ```

4. **Build and publish:**
   ```bash
   cd cli
   npm run build
   npm publish
   ```
   The `prepublishOnly` script will automatically run the build.

5. **Verify publication:**
   ```bash
   # Test from npm
   cd /path/to/test-project
   npx ai-playbook-cli@latest install
   ```

### Version Management

- Use [Semantic Versioning](https://semver.org/):
  - **Major** (1.0.0 → 2.0.0): Breaking changes
  - **Minor** (1.0.0 → 1.1.0): New features, backward compatible
  - **Patch** (1.0.0 → 1.0.1): Bug fixes, backward compatible

- Create git tags for releases:
  ```bash
  git tag -a v1.0.0 -m "Release version 1.0.0"
  git push origin v1.0.0
  ```

---

## Installation Methods Explained

### 1. Symlink (Default)

**What it does:**
- Creates symbolic links from your project's `.cursor/` to the playbook files
- Updates automatically when playbook is updated

**Pros:**
- Easy updates across all projects
- No file duplication
- Always uses latest version

**Cons:**
- Requires playbook repository to be accessible
- Symlinks may not work on all systems (Windows may need Developer Mode)

**Best for:**
- Development environments
- When you have the playbook repo locally
- When you want centralized updates

### 2. Copy

**What it does:**
- Copies all playbook files directly into your project

**Pros:**
- Works everywhere
- Project is self-contained
- No external dependencies

**Cons:**
- Updates require re-running install
- Files are duplicated in each project

**Best for:**
- Production projects
- When you want project-specific customizations
- CI/CD environments

### 3. Submodule

**What it does:**
- Shows instructions for using Git submodules

**Pros:**
- Version controlled
- Can pin specific versions
- Standard Git workflow

**Cons:**
- Requires Git submodule knowledge
- More setup steps

**Best for:**
- Teams using Git submodules
- When you need to pin specific versions
- Enterprise environments

---

## Troubleshooting

### "Could not find AI Playbook files"

**Solution:**
- If using from npm: The package should include templates. Rebuild and republish if needed.
- If using from source: Run `npm run build` in the cli directory first.

### "Symlink creation failed" (Windows)

**Solution:**
- Enable Developer Mode in Windows Settings
- Or use `--type copy` instead

### ".cursor directory already exists"

**Solution:**
- Use `--force` to overwrite: `npx ai-playbook-cli@latest install --force`
- Or manually merge directories

### Build fails

**Solution:**
- Ensure you're in the `cli` directory
- Run `npm install` first
- Check Node.js version (16+ required)

---

## Next Steps After Installation

### 1. Verify Installation

```bash
# Check status
npx ai-playbook-cli@latest status

# Verify files exist
ls .cursor/rules/
ls .cursor/commands/
```

### 2. Open in Cursor

Open your project in Cursor. The AI assistant will automatically:
- Load rules from `.cursor/rules/*.mdc`
- Use commands from `.cursor/commands/*.md`

### 3. Test a Command

Try using a command in Cursor chat:
```
/start
```
This should load the project context and start working.

### 4. Customize for Your Project

You can customize the playbook for your project:
- Add project-specific rules in `.cursor/rules/`
- Create custom commands in `.cursor/commands/`
- Update existing rules to match your tech stack

### 5. Commit to Repository

```bash
# Add .cursor to your repository
git add .cursor
git commit -m "chore: add AI Playbook"
git push
```

**Note:** If using symlinks, you may need to commit the symlink targets or use a different approach.

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Install AI Playbook

on: [push, pull_request]

jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npx ai-playbook-cli@latest install --type copy
      - run: # Your build/test commands
```

### GitLab CI Example

```yaml
install-playbook:
  image: node:18
  script:
    - npx ai-playbook-cli@latest install --type copy
    - # Your build/test commands
```

---

## Maintenance

### Updating the Playbook

**For symlink installations:**
```bash
# Update the playbook repository
cd .ai-playbook
git pull origin main

# All projects using symlinks will automatically use the new version
```

**For copy installations:**
```bash
# Re-run installation
npx ai-playbook-cli@latest install --type copy --force
```

### Checking for Updates

```bash
# Check current version
npx ai-playbook-cli@latest --version

# Check latest version on npm
npm view ai-playbook-cli version
```

---

## Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/ai-playbook/issues)
- **Documentation:** See [README.md](README.md) and [cli/README.md](cli/README.md)
- **CLI Help:** `npx ai-playbook-cli@latest --help`
