# Git Workflow

This repository is set up with two remotes:

- `origin`: your fork (`https://github.com/nagesh147/openalgo.git`)
- `upstream`: the original project (`https://github.com/marketcalls/openalgo.git`)

## Branch Model

- `main`: mirrors `upstream/main`
- `development`: your long-lived integration branch
- `feature/*`: short-lived working branches created from `development`

## Common Checks

Use these before syncing, branching, or pushing:

```bash
git remote -v
git branch -vv
git status
```

## Sync `main` From Upstream

Keep `main` aligned with the original repository:

```bash
git switch main
git fetch upstream
git merge --ff-only upstream/main
git push origin main
```

## Sync `development` From `main`

This repository includes a helper script:

- Script: `scripts/sync-development.sh`
- Alias: `git sync-development`

Safe default (`merge`):

```bash
git sync-development
```

Clean-history option (`rebase`):

```bash
git sync-development rebase
```

What the helper does:

1. Fetches `upstream` and `origin`
2. Fast-forwards local `main` from `upstream/main`
3. Pushes `main` to `origin`
4. Updates `development` from `main` using `merge` or `rebase`
5. Pushes `development` to `origin`

Notes:

- The working tree must be clean before running it.
- If started from a feature branch, the script returns you to that branch when it finishes.
- `merge` is the safest default.
- `rebase` pushes `development` with `--force-with-lease`.

## Create A Feature Branch

Start new work from `development`:

```bash
git switch development
git pull --ff-only origin development
git switch -c feature/my-change
git push -u origin feature/my-change
```

Current example branch:

```bash
feature/superTrend
```

## Keep A Feature Branch Current

Merge-based refresh:

```bash
git switch feature/my-change
git merge development
git push
```

Rebase-based refresh:

```bash
git switch feature/my-change
git rebase development
git push --force-with-lease
```

## Open A Pull Request

After pushing your feature branch:

```bash
gh pr create --base development --head feature/my-change
```

Use `main` as the PR base only if you intentionally want to skip the `development` branch.
