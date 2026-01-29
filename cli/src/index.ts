#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Get playbook root - try multiple locations
async function getPlaybookRoot(): Promise<string | null> {
  // Try 1: CLI package templates (when installed via npm)
  // Files are at: node_modules/ai-playbook-cli/templates/.cursor
  const cliRoot = path.resolve(__dirname, '..');
  const playbookCursor1 = path.join(cliRoot, 'templates', '.cursor');

  // Try 2: Parent of CLI (when in repo: cli/dist -> cli -> repo root)
  const repoRoot = path.resolve(__dirname, '../../..');
  const playbookCursor2 = path.join(repoRoot, '.cursor');

  // Try 3: Current working directory (when run from repo root)
  const cwdRoot = process.cwd();
  const playbookCursor3 = path.join(cwdRoot, '.cursor');

  // Check which location has the .cursor directory
  if (await fs.pathExists(playbookCursor1)) {
    return path.join(cliRoot, 'templates');
  }
  if (await fs.pathExists(playbookCursor2)) {
    return repoRoot;
  }
  if ((await fs.pathExists(playbookCursor3)) && cwdRoot.includes('ai-playbook')) {
    return cwdRoot;
  }

  return null;
}

const program = new Command();

program.name('ai-playbook').description('Install AI Playbook in your project').version('1.0.0');

program
  .command('install')
  .description('Install AI Playbook in the current project')
  .option('-t, --type <type>', 'Installation type: symlink, copy, or submodule', 'symlink')
  .option('-f, --force', 'Force installation even if .cursor directory exists', false)
  .action(async (options) => {
    const cwd = process.cwd();
    const cursorDir = path.join(cwd, '.cursor');
    const playbookRoot = await getPlaybookRoot();

    if (!playbookRoot) {
      console.log(chalk.red('❌ Error: Could not find AI Playbook files'));
      console.log(chalk.yellow('\n   Make sure the CLI package was built correctly.'));
      console.log(chalk.yellow('   If running from source, ensure .cursor directory exists.\n'));
      console.log(chalk.cyan('   Alternative: Clone the repository and run:'));
      console.log(chalk.gray('   cd ai-playbook/cli'));
      console.log(chalk.gray('   npm install'));
      console.log(chalk.gray('   npm run build'));
      console.log(chalk.gray('   npm run dev install\n'));
      process.exit(1);
    }

    const playbookCursorDir = path.join(playbookRoot, '.cursor');

    console.log(chalk.blue('🚀 AI Playbook Installer\n'));

    // Check if .cursor already exists
    if ((await fs.pathExists(cursorDir)) && !options.force) {
      console.log(chalk.yellow(`⚠️  .cursor directory already exists at ${cursorDir}`));
      console.log(chalk.yellow('   Use --force to overwrite or install manually\n'));
      process.exit(1);
    }

    // Verify playbook .cursor directory exists
    if (!(await fs.pathExists(playbookCursorDir))) {
      console.log(
        chalk.red(`❌ Error: AI Playbook .cursor directory not found at ${playbookCursorDir}`)
      );
      console.log(chalk.red('   Make sure you are running from the ai-playbook repository\n'));
      process.exit(1);
    }

    try {
      // Create .cursor directory if it doesn't exist
      await fs.ensureDir(cursorDir);

      if (options.type === 'symlink') {
        // Create symlinks for rules and commands
        const rulesDir = path.join(cursorDir, 'rules');
        const commandsDir = path.join(cursorDir, 'commands');
        const docsDir = path.join(cursorDir, 'docs');

        await fs.ensureDir(rulesDir);
        await fs.ensureDir(commandsDir);
        await fs.ensureDir(docsDir);

        const playbookRulesDir = path.join(playbookCursorDir, 'rules');
        const playbookCommandsDir = path.join(playbookCursorDir, 'commands');
        const playbookDocsDir = path.join(playbookCursorDir, 'docs');

        // Remove existing symlinks/directories if they exist
        if (await fs.pathExists(rulesDir)) {
          const stats = await fs.lstat(rulesDir);
          if (stats.isSymbolicLink() || stats.isDirectory()) {
            await fs.remove(rulesDir);
          }
        }
        if (await fs.pathExists(commandsDir)) {
          const stats = await fs.lstat(commandsDir);
          if (stats.isSymbolicLink() || stats.isDirectory()) {
            await fs.remove(commandsDir);
          }
        }
        if (await fs.pathExists(docsDir)) {
          const stats = await fs.lstat(docsDir);
          if (stats.isSymbolicLink() || stats.isDirectory()) {
            await fs.remove(docsDir);
          }
        }

        // Create symlinks
        await fs.symlink(playbookRulesDir, rulesDir, 'dir');
        await fs.symlink(playbookCommandsDir, commandsDir, 'dir');
        await fs.symlink(playbookDocsDir, docsDir, 'dir');

        console.log(chalk.green('✅ Created symlinks:'));
        console.log(chalk.gray(`   ${rulesDir} -> ${playbookRulesDir}`));
        console.log(chalk.gray(`   ${commandsDir} -> ${playbookCommandsDir}`));
        console.log(chalk.gray(`   ${docsDir} -> ${playbookDocsDir}\n`));
      } else if (options.type === 'copy') {
        // Copy files
        await fs.copy(playbookCursorDir, cursorDir, {
          overwrite: true,
          filter: (src) => {
            // Don't copy mcp.json if it exists (contains sensitive data)
            return !src.endsWith('mcp.json');
          },
        });

        console.log(chalk.green('✅ Copied AI Playbook files to .cursor directory\n'));
      } else if (options.type === 'submodule') {
        console.log(chalk.yellow('📦 Submodule installation:\n'));
        console.log(chalk.cyan('   Run these commands in your project:\n'));
        console.log(
          chalk.gray(
            '   git submodule add https://github.com/YOUR_USERNAME/ai-playbook.git .ai-playbook'
          )
        );
        console.log(chalk.gray('   ln -s .ai-playbook/.cursor/rules .cursor/rules'));
        console.log(chalk.gray('   ln -s .ai-playbook/.cursor/commands .cursor/commands'));
        console.log(chalk.gray('   ln -s .ai-playbook/.cursor/docs .cursor/docs\n'));
        return;
      }

      console.log(chalk.green('✨ AI Playbook installed successfully!\n'));
      console.log(chalk.cyan('   Your project now has:'));
      console.log(chalk.gray('   - Cursor rules (.cursor/rules/)'));
      console.log(chalk.gray('   - Cursor commands (.cursor/commands/)'));
      console.log(chalk.gray('   - Documentation structure (.cursor/docs/)\n'));
      console.log(chalk.cyan('   Optional: Add .cursor/mcp.json for MCP server configuration'));
      console.log(chalk.gray('   (mcp.json is in .gitignore - contains sensitive tokens)\n'));
      console.log(chalk.yellow('   Note: Make sure to commit .cursor/ to your repository\n'));
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(chalk.red(`❌ Error: ${msg}\n`));
      process.exit(1);
    }
  });

program
  .command('update')
  .description('Update AI Playbook in the current project')
  .action(async () => {
    const cwd = process.cwd();
    const cursorDir = path.join(cwd, '.cursor');

    console.log(chalk.blue('🔄 AI Playbook Updater\n'));

    if (!(await fs.pathExists(cursorDir))) {
      console.log(
        chalk.yellow('⚠️  .cursor directory not found. Run "ai-playbook install" first.\n')
      );
      process.exit(1);
    }

    // Check if it's a symlink installation
    const rulesDir = path.join(cursorDir, 'rules');
    const stats = await fs.lstat(rulesDir).catch(() => null);

    if (stats?.isSymbolicLink()) {
      console.log(chalk.cyan('📦 Symlink installation detected\n'));
      console.log(
        chalk.yellow('   To update, pull the latest changes from the playbook repository:\n')
      );
      console.log(chalk.gray('   cd .ai-playbook'));
      console.log(chalk.gray('   git pull origin main\n'));
    } else {
      console.log(chalk.cyan('📋 Copy installation detected\n'));
      console.log(chalk.yellow('   Re-run installation to update:\n'));
      console.log(chalk.gray('   ai-playbook install --type copy --force\n'));
    }
  });

program
  .command('status')
  .description('Check AI Playbook installation status')
  .action(async () => {
    const cwd = process.cwd();
    const cursorDir = path.join(cwd, '.cursor');
    const rulesDir = path.join(cursorDir, 'rules');
    const commandsDir = path.join(cursorDir, 'commands');

    console.log(chalk.blue('📊 AI Playbook Status\n'));

    if (!(await fs.pathExists(cursorDir))) {
      console.log(chalk.red('❌ Not installed\n'));
      console.log(chalk.yellow('   Run: ai-playbook install\n'));
      return;
    }

    const rulesExists = await fs.pathExists(rulesDir);
    const commandsExists = await fs.pathExists(commandsDir);

    if (rulesExists && commandsExists) {
      const rulesStats = await fs.lstat(rulesDir);
      const commandsStats = await fs.lstat(commandsDir);

      const rulesType = rulesStats.isSymbolicLink() ? 'symlink' : 'copy';
      const commandsType = commandsStats.isSymbolicLink() ? 'symlink' : 'copy';

      console.log(chalk.green('✅ AI Playbook is installed\n'));
      console.log(chalk.cyan(`   Rules: ${rulesType}`));
      console.log(chalk.cyan(`   Commands: ${commandsType}\n`));

      if (rulesStats.isSymbolicLink()) {
        const target = await fs.readlink(rulesDir);
        console.log(chalk.gray(`   Rules link: ${target}\n`));
      }

      // Check for mcp.json
      const mcpJson = path.join(cursorDir, 'mcp.json');
      const mcpExists = await fs.pathExists(mcpJson);
      if (mcpExists) {
        console.log(chalk.green('   MCP config: Found (project-specific)\n'));
      } else {
        console.log(
          chalk.gray('   MCP config: Not found (optional - add .cursor/mcp.json for MCP servers)\n')
        );
      }
    } else {
      console.log(chalk.yellow('⚠️  Partially installed\n'));
      if (!rulesExists) console.log(chalk.red('   Missing: .cursor/rules'));
      if (!commandsExists) console.log(chalk.red('   Missing: .cursor/commands'));
      console.log();
    }
  });

program.parse();
