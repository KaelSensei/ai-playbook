import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const repoRoot = path.resolve(__dirname, '../..');
const cliRoot = path.resolve(__dirname, '..');
const sourceCursor = path.join(repoRoot, '.cursor');
const destCursor = path.join(cliRoot, 'templates', '.cursor');

async function copyCursorFiles() {
  try {
    // Create templates directory
    await fs.ensureDir(path.join(cliRoot, 'templates'));
    
    // Copy .cursor directory
    await fs.copy(sourceCursor, destCursor, {
      overwrite: true,
      filter: (src) => {
        // Don't copy mcp.json (contains sensitive data)
        return !src.endsWith('mcp.json');
      }
    });
    
    console.log('✅ Copied .cursor files to templates/');
  } catch (error) {
    console.error('❌ Error copying .cursor files:', error);
    process.exit(1);
  }
}

copyCursorFiles();
