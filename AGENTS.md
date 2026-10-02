# musicxml-to-mnx
- Import-only, offline: this tool → committed `.mnx.json` in consumer repos. No runtime import or export until a product flow needs it.
- Conversion uses npm `musicxml-to-mnx` (pinned 0.1.2) behind one `convert()` that never throws. Output must pass Ajv against the pinned schema. Converter warnings are surfaced, not fatal.
- The render check (`layoutScore`, no errors, no `mnx-unsupported` outside the allowlist) lives in the app and playground tests over the committed `.mnx.json` scores, not in the tool.
- Depends only on `@polyhymnia/mnx` (schema, `assignIds` shape); never on the engine.
- Ajv is a runtime `dependency` here (the offline CLI validates at run time).
- Rejected, don't reintroduce without re-evaluation: Python `w3c-cg/mnxconverter` (stale), npm `mnxconverter` (replaced by `musicxml-to-mnx`), `@mnxjs/*` (source gone), `musicxml-interfaces` (AGPL), `@stringsync/musicxml` (stale).

# Publishing
- Published to public npm (`publishConfig.access: public`, `files` whitelist, own `LICENSE`).
- Record releasable changes with `pnpm changeset`. Agents never run `changeset publish`, `npm publish`, or push; the user publishes.
- Before a release, `pnpm pack` and smoke-install the tarball in a scratch project.

# Tests
- Add a test only to prevent a real regression: a contract or a bug that was actually fixed. Otherwise don't.
- New behavior → at most a few tests for its distinct branches. Never one test per constant, option, or trivial mapping; never restate the implementation.
- Fixed bug → one regression test that fails without the fix. Table-driven over copy-paste; no cross-products.
- Test only through public entry points; never export internals for tests. Never weaken an assertion to go green.
- Agents: run tests with `--reporter=dot`.
