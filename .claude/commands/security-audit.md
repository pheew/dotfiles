---
allowed-tools: Bash(yarn npm audit -R*), Bash(gh api repos/*/dependabot/alerts*), Bash(npm view *), Bash(yarn why *), Bash(gh repo view *), Bash(yarn up *), Bash(yarn install*), Bash(yarn constraints*), Bash(rg *)
---

# Security Dependency Audit

@package.json

**Goal:** Ensure no open vulnerabilities with severity HIGH or CRITICAL remain.

**Focus:** $ARGUMENTS

If a package name is provided above, focus the audit on that specific package only. Otherwise, perform a full audit.

## Audit Process

1. **Run `yarn npm audit -R`** to identify vulnerable dependencies
2. **Check GitHub Security Advisories** using the current repo:
   ```bash
   gh api repos/{owner}/{repo}/dependabot/alerts --paginate --jq '.[] | select(.state == "open" and (.security_advisory.severity == "high" or .security_advisory.severity == "critical")) | {number, package: .dependency.package.name, severity: .security_advisory.severity, ghsa_id: .security_advisory.ghsa_id, summary: .security_advisory.summary}'
   ```
   Determine `{owner}/{repo}` from `gh repo view --json nameWithOwner -q .nameWithOwner`.
3. **Filter** to only HIGH and CRITICAL severity issues (and to specific package if provided)
4. **Create a todo list** tracking each vulnerability that needs resolution

## For each HIGH/CRITICAL vulnerability

Present:
- Package name and current version
- Severity level
- CVE ID (if available)
- Description of the vulnerability
- Direct dependency or transitive (requires resolution)
- Source: yarn audit / GitHub advisory
- **Runtime vs dev-only**: Check if the package is only used in devDependencies (jest, eslint, playwright, etc.) - dev-only vulnerabilities have lower risk
- **Fix type**: Patch bump (safe) vs minor/major bump (review with user)

Use `yarn why <package>` to trace the dependency chain and understand what pulls in the vulnerable package.

Ask the user to choose:
- **Fix**: Update/add resolution to remediate
- **Dismiss**: False positive or not applicable (explain why in commit)
- **Investigate**: Need more context before deciding

## Fixing vulnerabilities

- For direct dependencies: use `yarn up -E <package>@<version>` to update across all workspaces with an exact version (e.g., `yarn up -E next@15.5.9`)
- For transitive dependencies: add/update entry in root package.json `resolutions`
- After all fixes: run `yarn install` to regenerate yarn.lock
- Re-run audit to verify fixes

## Check for unused dependencies

Before adding a resolution, check if the vulnerable dependency is actually used:

1. Use `yarn why <package>` to find what depends on it
2. Search for actual imports: `grep -r "<package-name>" --include="*.ts" --include="*.tsx" <path>`
3. If only listed in package.json but never imported → the dependency may be unused

**If a dependency is unused:**
- Remove it from package.json instead of adding a resolution
- This eliminates the vulnerability entirely and reduces bundle size
- Run `yarn install` and verify the build still works

## Review outdated peerDependencies

When updating a major framework (e.g., Next.js), check if peerDependency ranges need updating.

**To verify if a package actually uses a peerDep:**

1. Remove the peerDep from package.json
2. Run `yarn ./path/to/package lint-js`
3. If lint passes → the peerDep was unused, keep it removed
4. If lint fails with import errors → re-add with updated range (e.g., `"next": "^15"`)

Ask the user to choose for each outdated peerDep:
- **Update**: Package uses it, update the range
- **Remove**: Package doesn't use it, remove entirely
- **Skip**: Leave as-is

## Review outdated resolutions

After fixing vulnerabilities, check if any existing resolutions are no longer needed.

**For each resolution in root `package.json`:**

1. Run `yarn why <package>` to see which packages depend on it
2. Determine if still needed:
   - **No packages depend on it** → remove resolution
   - **All dependents request resolved version or newer** → remove resolution
   - **Dependents still request older vulnerable versions** → keep resolution

**To test if a resolution can be removed:**

1. Remove the resolution from package.json
2. Run `yarn install`
3. Run `yarn why <package>` to check installed version
4. If secure version is still installed → keep it removed
5. If vulnerable version is installed → restore the resolution

Ask the user to choose for each resolution:
- **Remove**: Resolution is obsolete
- **Keep**: Still needed for security
- **Investigate**: Need more context

## Before committing

Run these commands and ensure they exit cleanly:

```bash
yarn install
```

```bash
yarn constraints
```

```bash
yarn npm audit -R
```

Only commit and push changes if all commands succeed and no HIGH/CRITICAL vulnerabilities remain.

## Completion criteria

The audit is complete when `yarn npm audit -R` and GitHub advisories show **zero HIGH or CRITICAL** vulnerabilities.
