---
name: pull-request
description: 'Create pull requests with Conventional Commits, structured descriptions, and proper git workflow. Handles staging, commit, push, and PR creation via GitHub CLI (gh). Generates title and description automatically from changes.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: workflow
  stack: dynamics365-powerplatform
---

# Pull Request — Conventional Commits & GitHub Workflow

Create pull requests following Conventional Commits conventions, with structured
descriptions and a complete git workflow. This skill handles everything from
staging files to opening the PR via GitHub CLI (`gh`).

---

## 1. Conventional Commits Format

Every commit message MUST use a valid Conventional Commits type:

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that is neither a feature nor a fix |
| `perf` | Performance improvement |
| `test` | Adding or correcting tests |
| `build` | Build system or external dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |

**Breaking changes**: add `!` after the type (e.g. `feat!:`) or include
`BREAKING CHANGE:` in the commit body.

---

## 2. Commit Message Structure

```
{type}({scope}): {short description}

{optional body — explain WHAT and WHY}

{optional footer — BREAKING CHANGE, issue references}

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Scope Examples

Use a scope that matches the area of the codebase being changed:

| Scope | When to use |
|-------|-------------|
| `plugin` | C# Dataverse plugins |
| `pcf` | PowerApps Component Framework controls |
| `flow` | Power Automate flows |
| `form` | Form scripts and web resources |
| `api` | Custom APIs or Web API integrations |
| `docs` | Documentation files |
| `test` | Test files and test utilities |

### Rules

- The **short description** starts with a lowercase verb, max ~72 characters.
- The **body** explains what changed and why, wrapped at 100 characters.
- ALWAYS include the **Copilot co-author trailer** as the last line.

---

## 3. PR Description Template

Generate the PR description using this template:

```markdown
## Summary
{Brief description of what this PR does}

## Changes
- {List of changes made}

## Type of Change
- [ ] New feature (non-breaking change adding functionality)
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Documentation update
- [ ] Refactoring (no functional change)
- [ ] Test coverage improvement

## Related Issues
- Closes #{issue_number}
- Related to #{issue_number}

## Testing
{How was this tested? What test cases were covered?}

## Checklist
- [ ] Code follows project naming conventions
- [ ] Unit tests added/updated
- [ ] Documentation updated
- [ ] No hardcoded values or secrets
- [ ] Solution export tested
```

Fill in the template by analyzing the staged diff. Check the appropriate type
checkbox and remove the others for clarity.

---

## 4. Git Workflow

Execute these steps in order:

```bash
# 1. Verify current branch (never commit directly to main)
git branch --show-current

# 2. Stage changes
git add -A   # or specific files for a focused commit

# 3. Review staged changes
git diff --cached --stat

# 4. Commit with Conventional Commits format
git commit -m "feat(plugin): add account validation plugin

Implements pre-operation validation for account creation.
Validates required fields and business rules.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# 5. Push to remote
git push origin HEAD

# 6. Create PR via GitHub CLI
gh pr create --title "feat(plugin): add account validation plugin" \
  --body "$(cat pr-description.md)" \
  --base main
```

### Important Notes

- **Never commit directly to `main`** — always work on a feature branch.
- If the current branch is `main`, create a new branch first:
  `git checkout -b {type}/{short-description}`
- If `gh` CLI is not available, output the full commands for the user to run
  manually and provide the PR description as copyable text.

---

## 5. Workflow for This Skill

When the user asks to create a pull request:

1. **Analyze the current git diff** — run `git diff --cached --stat` (and
   `git diff --stat` for unstaged changes) to understand what changed.
2. **Determine the commit type and scope** — choose the correct Conventional
   Commits type (`feat`, `fix`, `docs`, etc.) and scope (`plugin`, `form`,
   etc.) based on the files changed.
3. **Generate the commit message** — follow the structure in Section 2.
4. **Generate the PR description** — fill in the template from Section 3
   using the information from the diff.
5. **Execute the git workflow**:
   - Stage files (`git add`)
   - Commit with the generated message
   - Push to the remote
   - Create the PR via `gh pr create`
6. **Handle errors gracefully**:
   - If `gh` is not installed, provide the commands and PR body for manual use.
   - If there are no staged changes, inform the user.
   - If the branch is `main`, create a feature branch first.

---

## 6. Branch Naming Convention

Branches MUST follow this pattern:

```
{type}/{ticket-id}-{short-description}
```

Examples:

- `feat/PROJ-123-account-validation`
- `fix/PROJ-456-null-reference`
- `docs/PROJ-789-api-documentation`
- `refactor/PROJ-101-plugin-cleanup`

If there is no ticket or issue number, omit the ticket ID:

```
{type}/{short-description}
```

Examples:

- `feat/account-validation`
- `fix/null-reference-plugin`
- `chore/update-dependencies`
