# Branch Protection Setup Guide

This repository includes branch protection workflows, but you need to configure the actual branch protection rules in GitHub's web interface.

## 🛡️ Recommended Branch Protection Rules

Follow these steps to protect your main branch:

### Step 1: Navigate to Branch Protection Settings

1. Go to your repository on GitHub: `https://github.com/sohailmahmud/MindVault`
2. Click **Settings** tab
3. Click **Branches** in the left sidebar
4. Click **Add rule** or **Add branch protection rule**

### Step 2: Configure Protection Rules

#### Basic Settings:
- **Branch name pattern**: `main`
- ✅ **Restrict pushes that create files larger than 100 MB**

#### Protection Rules:
- ✅ **Require a pull request before merging**
  - ✅ **Require approvals**: 1 (or more for teams)
  - ✅ **Dismiss stale PR approvals when new commits are pushed**
  - ✅ **Require review from code owners** (if you have CODEOWNERS file)

- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - **Required status checks:**
    - `test-and-analyze` (from CI workflow)
    - `required-checks` (from branch protection workflow)

#### Advanced Settings:
- ✅ **Require conversation resolution before merging**
- ✅ **Include administrators** (applies rules to admins too)
- ✅ **Restrict pushes that create files larger than 100 MB**

#### Force Push & Deletion Protection:
- ✅ **Do not allow bypassing the above settings**
- ✅ **Restrict force pushes**
- ✅ **Allow deletions** (uncheck this to prevent deletion)

### Step 3: Save Rules

Click **Create** to save your branch protection rules.

## 📋 What This Setup Provides:

### ✅ **Prevents:**
- Direct pushes to main branch
- Force pushes to main branch
- Deletion of main branch (if configured)
- Merging without required reviews
- Merging with failing tests/checks

### ✅ **Requires:**
- All changes via Pull Requests
- Code review approval before merging
- All CI checks to pass (tests, formatting, analysis)
- Branches to be up-to-date before merging

### ✅ **Enforces:**
- Code quality through automated checks
- Team collaboration through reviews
- Stable main branch through testing

## 🚀 Workflow Integration

The repository includes these workflows that work with branch protection:

1. **CI Workflow** (`ci.yml`)
   - Runs tests, formatting, and analysis
   - Status check: `test-and-analyze`

2. **Branch Protection Workflow** (`branch-protection.yml`)
   - Additional protection checks
   - Status check: `required-checks`

3. **Release Workflow** (`release.yml`)
   - Handles versioned releases from main branch

## 🔧 Alternative: Automated Branch Protection

If you want to set up branch protection programmatically, you can use GitHub CLI:

```bash
# Install GitHub CLI first: https://cli.github.com/

# Set up branch protection rule
gh api repos/sohailmahmud/MindVault/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["test-and-analyze","required-checks"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## 📚 Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [Managing Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/managing-a-branch-protection-rule)
- [Required Status Checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-status-checks)