import { describe, test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import fs from 'fs-extra';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const CLI_ENTRY = path.resolve(__dirname, '..', 'dist', 'index.js');

function runCli(args, cwd) {
  const result = spawnSync('node', [CLI_ENTRY, ...args], {
    cwd,
    encoding: 'utf-8',
    env: { ...process.env, NO_COLOR: '1', FORCE_COLOR: '0' },
  });
  return {
    stdout: result.stdout ?? '',
    stderr: result.stderr ?? '',
    status: result.status ?? 1,
  };
}

describe('ai-playbook CLI smoke tests', () => {
  let tmpDir;

  beforeEach(async () => {
    tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'ai-playbook-cli-test-'));
  });

  afterEach(async () => {
    if (tmpDir) await fs.remove(tmpDir);
  });

  test('status reports "Not installed" in an empty directory', () => {
    const { stdout, status } = runCli(['status'], tmpDir);
    assert.equal(status, 0);
    assert.match(stdout, /Not installed/);
  });

  test('install --type copy populates .cursor with rules, commands, docs', async () => {
    const { stdout, status } = runCli(['install', '--type', 'copy'], tmpDir);
    assert.equal(status, 0, `install failed: ${stdout}`);
    assert.match(stdout, /installed successfully/);

    const cursorDir = path.join(tmpDir, '.cursor');
    assert.ok(await fs.pathExists(path.join(cursorDir, 'rules')), '.cursor/rules missing');
    assert.ok(await fs.pathExists(path.join(cursorDir, 'commands')), '.cursor/commands missing');
    assert.ok(await fs.pathExists(path.join(cursorDir, 'docs')), '.cursor/docs missing');

    const rules = await fs.readdir(path.join(cursorDir, 'rules'));
    assert.ok(rules.length > 0, 'no rules were copied');
  });

  test('status reports "installed" after install --type copy', () => {
    runCli(['install', '--type', 'copy'], tmpDir);
    const { stdout, status } = runCli(['status'], tmpDir);
    assert.equal(status, 0);
    assert.match(stdout, /is installed/);
  });

  test('install does not copy mcp.json (sensitive data guard)', async () => {
    runCli(['install', '--type', 'copy'], tmpDir);
    const mcpJson = path.join(tmpDir, '.cursor', 'mcp.json');
    assert.equal(await fs.pathExists(mcpJson), false, 'mcp.json should not be copied');
  });

  test('install fails on existing .cursor without --force', async () => {
    await fs.ensureDir(path.join(tmpDir, '.cursor'));
    const { stdout, status } = runCli(['install', '--type', 'copy'], tmpDir);
    assert.equal(status, 1);
    assert.match(stdout, /already exists/);
  });

  test('install --force overwrites existing .cursor', async () => {
    await fs.ensureDir(path.join(tmpDir, '.cursor'));
    const { status } = runCli(['install', '--type', 'copy', '--force'], tmpDir);
    assert.equal(status, 0);
  });

  test('install --type submodule prints instructions referencing .agents source', () => {
    const { stdout, status } = runCli(['install', '--type', 'submodule'], tmpDir);
    assert.equal(status, 0);
    assert.match(stdout, /Submodule installation/);
    assert.match(stdout, /git submodule add/);
    assert.match(stdout, /\.ai-playbook\/\.agents\/rules/);
  });
});
