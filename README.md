# comic-stash

Add your comics in seconds and keep your whole collection in one place. Comic Stash tracks every issue you own, shows the gaps in your runs, and tells you exactly what you’re missing, so you always know which books to hunt down next.

## Development Workflow

### Branches

| Branch                         | Purpose                                            | Protected                   |
| ------------------------------ | -------------------------------------------------- | --------------------------- |
| `main`                         | Production. Only updated by merging `development`. | ✅ PR + passing CI required |
| `development`                  | Integration branch. Default branch for all work.   | ✅ PR + passing CI required |
| `feature/*`, `fix/*`, `docs/*` | Short-lived branches for a single change.          | ❌                          |

Direct pushes to `main` and `development` are blocked. All changes go through a pull request.

### Day-to-day: building a feature

1. **Start from an up-to-date `development`**

```bash
   git checkout development
   git pull
```

2. **Create a branch for the change**

```bash
   git checkout -b feature/short-description
```

Use `fix/...` for bug fixes.

3. **Write tests first, then the code**, committing small and often:

```bash
   git add .
   git commit -m "Add Comic model with validations"
```

4. **Run the full CI suite locally before pushing**

```bash
   bin/ci
```

5. **Push the branch**

```bash
   git push -u origin feature/short-description
```

6. **Open a pull request into `development`** on GitHub.
   CI runs automatically. Fix any failures by pushing more commits to the same branch.

7. **Squash and merge** once all checks are green. The feature branch is deleted automatically.

### Releasing to production

1. Open a pull request from `development` → `main`.
2. Wait for all CI checks to pass.
3. **Squash and merge.**
4. Optionally, tag the release:

```bash
   git checkout main
   git pull
   git tag v1.0.0
   git push origin v1.0.0
```

### CI checks

Every pull request and every push to `main` or `development` runs `.github/workflows/ci.yml`:

| Job           | What it does                                          |
| ------------- | ----------------------------------------------------- |
| `scan_ruby`   | Security scan of Ruby code and gems (Brakeman)        |
| `scan_js`     | Security audit of JavaScript dependencies (importmap) |
| `lint`        | Code style checks (RuboCop)                           |
| `test`        | Unit and integration tests (Minitest + PostgreSQL)    |
| `system-test` | Browser-level system tests                            |

All five must pass before a pull request can be merged.

### Dependency updates

Dependabot opens pull requests into `development` for outdated gems and GitHub Actions. Treat them like any other PR: merge them once CI is green, and check major version bumps more carefully.

### Secrets

- `config/master.key` is **never** committed. Keep a copy in a password manager.
- Deployment credentials live in GitHub **Settings → Secrets and variables → Actions**, never in the code.

### Quick changes example

Even README-only edits go through a pull request. Use a `docs/` branch:

```bash
git checkout development
git pull
git checkout -b docs/short-description

# edit README.md (or other docs)

git add README.md
git commit -m "Update README with development workflow"
git push -u origin docs/short-description
```

Then open a pull request into `development`, wait for the checks to pass, and **Squash and merge**.

> **Tip:** Always create the branch _before_ committing. If you accidentally commit on `development`, move the commit to a new branch and reset:
>
> ```bash
> git checkout -b docs/short-description
> git push -u origin docs/short-description
> git checkout development
> git reset --hard origin/development
> ```
