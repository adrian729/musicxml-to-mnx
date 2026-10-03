# musicxml-to-mnx
- Import-only, offline: this tool → committed `.mnx.json` in consumer repos. No runtime import or export until a product flow needs it.
- Conversion uses npm `musicxml-to-mnx` (pinned 0.1.2) behind one `convert()` that never throws. Output must pass Ajv against the pinned schema. Converter warnings are surfaced, not fatal.
- The render check (`layoutScore`, no errors, no `mnx-unsupported` outside the allowlist) lives in the app and playground tests over the committed `.mnx.json` scores, not in the tool.
- Depends only on `@polyhymnia/mnx` (schema, `assignIds` shape); never on the engine.
- Ajv is a runtime `dependency` here (the offline CLI validates at run time).
- Rejected, don't reintroduce without re-evaluation: Python `w3c-cg/mnxconverter` (stale), npm `mnxconverter` (replaced by `musicxml-to-mnx`), `@mnxjs/*` (source gone), `musicxml-interfaces` (AGPL), `@stringsync/musicxml` (stale).

# Publishing
- Published to public npm (`publishConfig.access: public`, `files` whitelist, own `LICENSE`).
- Record releasable changes with `pnpm changeset`.
- Release only when the user asks: run `pnpm release` from a clean `main` and complete it without further confirmation. It checks the package, versions pending changesets, smoke-installs the packed library and CLI, pushes main, waits for CI, dispatches publishing for that exact commit, and verifies npm. Fix failures, commit, and rerun; the command resumes an unpublished version.
- Never run `changeset version`, `changeset publish` or `npm publish` directly, merge version-package PRs, force-push, or bypass branch protection. Publishing runs in `release.yml`; pushes are authorized as part of a requested release or consumer update.

# Tests
- Add a test only to prevent a real regression: a contract or a bug that was actually fixed. Otherwise don't.
- New behavior → at most a few tests for its distinct branches. Never one test per constant, option, or trivial mapping; never restate the implementation.
- Fixed bug → one regression test that fails without the fix. Table-driven over copy-paste; no cross-products.
- Test only through public entry points; never export internals for tests. Never weaken an assertion to go green.
- Agents: run tests with `--reporter=dot`.
