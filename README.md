# @polyhymnia/musicxml-to-mnx

Offline MusicXML → MNX converter (library and CLI) wrapping npm `musicxml-to-mnx` behind one `convert()` that never throws, with Ajv validation against the `@polyhymnia/mnx` schema and positional ids.

```sh
pnpm install
pnpm build
pnpm typecheck
pnpm test
```

Releases are versioned with changesets and published to npm as `@polyhymnia/musicxml-to-mnx`. Record package changes with `pnpm changeset`, then run `pnpm release` from a clean `main`. The command runs checks, versions the package, smoke-tests the packed library and CLI, pushes the commit, waits for CI, dispatches publishing, and verifies npm availability. No version PR or manual approval is needed. Rerun the command after fixing a failure to resume an unpublished version.

MIT licensed.
