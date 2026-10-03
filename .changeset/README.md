# Changesets

Run `pnpm changeset` to record a change to the published package. Run `pnpm release` from a clean `main` to validate, version, smoke-test, push and publish without a version PR. The command waits for CI and publishing and verifies the resulting npm version; rerun it after fixing a failure to resume an unpublished version. Do not run versioning or publishing commands separately.
