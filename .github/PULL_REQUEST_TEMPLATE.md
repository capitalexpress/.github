<!--
Title: Conventional Commits, `type(scope): summary`. It becomes the squash commit.
  e.g. feat(credit-lines): add dai balance api · fix(clients): stop pagination render loop
  Everyday types: feat, fix, refactor, docs, chore. Add `!` for a breaking change: feat(api)!: ...
-->

## Summary

<!-- What changes and why. Lead with the behavior and the reason; the diff shows the how. -->

Closes #

<!-- Closes the issue when this change reaches main (production), not on merge to dev/stg.
     Issue in another repo: "Closes <owner>/<repo>#N". Legacy repo whose default branch
     is still stage: write "Part of #N" and close the issue after the production release.
     Delete the line if there is no issue. -->

## Proof of completion

<!-- How you verified it works: screenshots or a video for UI, request/response for an API,
     test or log output for everything else. -->

## Notes for reviewers

<!-- Optional, delete if empty: stacked or companion PRs and merge order, what is out of scope,
     temporary workarounds, follow-ups, where to start reading. -->

## Checklist

<!-- Tick what you did. Leave unticked (or delete) what does not apply. -->

- [ ] Tests added or updated; CI is green
- [ ] Docs updated if behavior or setup changed (README, OpenAPI, ...)
- [ ] API changes reflected in the team's Bruno collection, PR linked above
- [ ] New config or secrets added to every environment (dev, stg, prd)
- [ ] New routes or role permissions configured
- [ ] Breaking change or manual deploy step described above (and `!` in the title)
- [ ] No secrets, credentials or personal data in code, logs or screenshots
