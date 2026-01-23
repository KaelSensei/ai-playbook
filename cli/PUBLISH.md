# Publishing AI Playbook CLI

## Prerequisites

1. Have an npm account
2. Be logged in: `npm login`
3. Have publish access to the `ai-playbook-cli` package

## Publishing Steps

1. **Update version** in `cli/package.json`

2. **Build the package:**
   ```bash
   cd cli
   npm run build
   ```
   This will:
   - Copy `.cursor` files to `templates/.cursor`
   - Compile TypeScript to `dist/`

3. **Test locally:**
   ```bash
   npm pack
   # This creates ai-playbook-cli-1.0.0.tgz
   # Test it in another project:
   npm install /path/to/ai-playbook-cli-1.0.0.tgz
   ```

4. **Publish to npm:**
   ```bash
   npm publish
   ```

5. **Verify installation:**
   ```bash
   # In a test project
   npx ai-playbook-cli@latest install
   ```

## Version Management

- Use semantic versioning (major.minor.patch)
- Update version in `cli/package.json`
- Consider creating a git tag for the release

## Notes

- The `prepublishOnly` script automatically runs `npm run build`
- The `files` field in `package.json` controls what gets published
- Only `dist/` and `templates/` are included in the package
