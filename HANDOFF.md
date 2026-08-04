# Continue here

## Current state

The reliability hardening is committed on `feature/2026-dev-env` and ready for review. The local `master` branch tracks `origin/master`; do not merge by hand outside the pull request.

## Verified

- Docker production-like build succeeds.
- `carton exec prove -lv t` passes (12 tests).
- `carton exec perl -c Run.pm` passes.
- A full scrape produced 60 current HTTPS entries and `public/source-health.json`; failed, stale, and low-confidence sources are quarantined rather than deleted.

## Next action

After the pull request is merged, rotate the old Netlify build hook in Netlify and set the replacement as the repository secret `NETLIFY_BUILD_HOOK_URL`. Then trigger the **Trigger Netlify Build** workflow manually and confirm production serves the new health API and security headers.

## Open threads

- Review the sources marked failed/stale/low-confidence in `source-health.json`; repair or remove them only after manual review.
- Review `private/candidates.json` monthly before adding any new source to `private/newsletters.json`.

## Do not

- Do not restore the former literal Netlify hook URL to `.github/workflows/main.yml`.
- Do not auto-delete stale or failed sources; quarantine is intentionally reversible.
- Do not commit the existing untracked `.DS_Store` files.
