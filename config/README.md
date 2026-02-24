# Config Directory

**⚠️ IMPORTANT: This directory is excluded from git (see .gitignore)**

## Purpose

This directory contains sensitive configuration files and API keys that should **NEVER** be committed to version control.

---

## Required Files (Local Only)

### `AuthKey_NXG563P998.p8`
- **Type:** Apple App Store Connect API Key
- **Used by:** CI/CD pipeline (codemagic.yaml)
- **Purpose:** App Store deployment and TestFlight distribution
- **Security:** Keep this file secure and never commit to git

---

## Setup Instructions

When setting up a new development environment or CI/CD pipeline:

1. Obtain the required keys from the project owner
2. Place them in this `config/` directory
3. Verify they are NOT tracked by git: `git status` should not show them
4. Configure CI/CD secrets in Codemagic dashboard (not in files)

---

## What Goes Here

**DO include (locally):**
- `*.p8` — Apple API keys
- `*.pem` — Certificate files
- `.env.*` — Environment-specific configs
- Any other API keys or secrets

**DO NOT include:**
- Public configuration (use `codemagic.yaml` or app code)
- Documentation (use root or `_reference/`)

---

## Security Notes

- This entire directory is in `.gitignore`
- CI/CD systems should use secure environment variables, not committed files
- If a secret is accidentally committed, immediately rotate the key and use `git-filter-repo` to remove it from history
- For BuildShip API keys, these are public endpoints and can be in code (see ARCHITECTURE.md)

---

**Last Updated:** February 24, 2026
