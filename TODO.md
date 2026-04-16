# TODO

Priority fixes to make the repository feel more mature, reliable, and easier to adopt.

- [ ] Fix the default CLI installation path so the `symlink` mode installs `rules`, `commands`, and
      `skills`, then align the status output and installation docs with the actual behavior.
- [ ] Make the CLI build and smoke tests reliable on Windows, then extend CI to run on both
      `ubuntu-latest` and `windows-latest`.
- [ ] Remove documentation drift by updating outdated references, resolving formatting failures, and
      making `README.md`, `INSTALLATION.md`, `COMMANDS.md`, and `CONCEPTS.md` tell the same story.
- [ ] Define a clear compatibility contract per tool and remove hardcoded `.cursor/...` assumptions
      from workflows that are meant to be tool-agnostic.
- [ ] Document and validate a single golden path for adoption, ideally centered on
      `/spec -> /plan -> /feature -> /validate -> /checklist`, and prove that flow end to end.
