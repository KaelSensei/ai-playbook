import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const repoRoot = path.resolve(__dirname, '../..');
const cliRoot = path.resolve(__dirname, '..');
const sourceAgents = path.join(repoRoot, '.agents');
const destAgents = path.join(cliRoot, 'templates', '.agents');

async function copyAgentsFiles() {
  try {
    // Create templates directory
    await fs.ensureDir(path.join(cliRoot, 'templates'));

    // Copy .agents directory
    await fs.copy(sourceAgents, destAgents, {
      overwrite: true,
      filter: (src) => {
        // Don't copy mcp.json (contains sensitive data)
        return !src.endsWith('mcp.json');
      },
    });

    console.log('✅ Copied .agents files to templates/');
  } catch (error) {
    console.error('❌ Error copying .agents files:', error);
    process.exit(1);
  }
}

copyAgentsFiles();
