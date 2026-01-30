# AI PR Review Workflow

A reusable GitHub Actions workflow that provides automated AI-powered code reviews for pull requests using OpenAI Codex.

## Features

- **Automatic PR Review**: Triggers on PR open, ready for review, or new commits
- **Manual Trigger**: Use `/review` command in PR comments to manually trigger a review
- **CI Integration**: Waits for CI checks to pass before running review (configurable)
- **Smart Review Logic**:
  - Skips reviews for draft PRs
  - Skips reviews when auto-merge is enabled
  - Restarts reviews that were cancelled
  - Retries reviews after CI failures
- **Comprehensive Analysis**:
  - Security vulnerability detection
  - Bug identification with priority levels (P0-P3)
  - Test coverage analysis
  - Code quality assessment
- **Rich Feedback**: Posts detailed review comments with:
  - Overall correctness verdict
  - Prioritized findings
  - Direct links to code locations
  - Confidence scores

## Usage

### Step 1: Set Up Secrets

Add your OpenAI API key to your repository secrets:

1. Go to your repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `OPENAI_API_KEY`
4. Value: Your OpenAI API key

### Step 2: Create Workflow File

Create `.github/workflows/ai-pr-review.yml` in your repository:

```yaml
name: AI PR Review

on:
  pull_request:
    types: [opened, ready_for_review, synchronize]
  issue_comment:
    types: [created]

concurrency:
  group: ai-review-${{ github.event.pull_request.number || github.event.issue.number }}${{ github.event_name == 'issue_comment' && !startsWith(github.event.comment.body, '/review') && '-noop' || '' }}
  cancel-in-progress: true

jobs:
  review:
    uses: oxidian/actions/ai-pr-review.yml@main
    with:
      # Required: Your OpenAI API endpoint
      responses-api-endpoint: "https://your-azure-openai.openai.azure.com/openai/v1/responses"

      # Required: The model to use for reviews
      # Use gpt-5.2-codex for best code review results
      model: "gpt-5.2-codex"

      # Optional: Effort level (low, medium, high, xhigh)
      effort: "xhigh"

      # Optional: Maximum minutes to wait for CI checks (default: 30)
      ci-timeout-minutes: 30
    secrets:
      openai-api-key: ${{ secrets.OPENAI_API_KEY }}
```

**Note:** Dependabot PRs are always excluded from AI review. Use the `/review` command to manually trigger a review if needed.

### Step 3: Configure for Your OpenAI Setup

Update the `responses-api-endpoint` and `model` to match your OpenAI or Azure OpenAI configuration:

**For Azure OpenAI:**
```yaml
responses-api-endpoint: "https://your-resource-name.openai.azure.com/openai/v1/responses"
model: "gpt-5.2-codex"  # or your deployed model name
```

**For OpenAI API:**
```yaml
responses-api-endpoint: "https://api.openai.com/v1/responses"
model: "gpt-5.2-codex"  # or your preferred model
```

## Configuration Options

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `responses-api-endpoint` | Yes | - | OpenAI API endpoint URL |
| `model` | Yes | - | OpenAI model to use (e.g., `gpt-5.2-codex`) |
| `effort` | No | `xhigh` | Review effort level: `low`, `medium`, `high`, or `xhigh` |
| `ci-timeout-minutes` | No | `30` | Max minutes to wait for CI checks to pass |

**Note:** Dependabot PRs are always excluded from automatic reviews. You can manually trigger a review on any PR (including dependabot PRs) using the `/review` comment command.

### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `openai-api-key` | Yes | Your OpenAI or Azure OpenAI API key |

## How It Works

### Automatic Triggers

1. **PR Opened/Ready**: Automatically reviews when a PR is opened or marked ready for review
2. **New Commits**: Reviews new commits on PRs that had in-progress or failed CI reviews
3. **Auto-merge Detection**: Skips review if auto-merge is enabled (assumes user doesn't want review)
4. **Dependabot PRs**: Always skipped automatically (dependabot updates are usually auto-merged)

### Manual Trigger

Comment `/review` on any PR to manually trigger a review. You can also add custom instructions:

```
/review Focus on security vulnerabilities and performance issues
```

### Review Process

1. **CI Check Wait**: Waits for CI checks to complete (skipped for manual `/review`)
2. **Diff Analysis**: Analyzes the PR diff using the merge-base to avoid unrelated changes
3. **AI Review**: Runs OpenAI Codex analysis with comprehensive guidelines
4. **Comment Posting**: Posts a sticky comment with findings

### Review States

The workflow tracks review state using HTML comments in PR comments:

- `in_progress`: Review is currently running
- `ci_failed`: CI checks failed, waiting for fixes
- `completed`: Review finished successfully
- `error`: Review encountered an error

## Priority Levels

Findings are categorized by priority:

- **P0**: Drop everything to fix (security vulnerabilities, data loss, critical bugs)
- **P1**: Urgent, fix in next cycle (functional bugs, performance issues)
- **P2**: Normal priority (minor bugs, edge cases, error handling)
- **P3**: Low priority (code quality, tests, documentation)

## Review Guidelines

The workflow includes comprehensive review guidelines that cover:

- Bug identification criteria
- Security vulnerability detection
- Test coverage expectations
- Code quality standards
- Comment formatting

These can be customized by modifying the prompt in `ai-pr-review.yml`.

## Advanced Customization

### Repository-Specific Guidelines

To add repository-specific review guidelines, you can:

1. Create an `AGENTS.md` file in your repository with custom guidelines
2. Modify the workflow prompt to reference this file
3. The AI will prioritize repository-specific guidelines over defaults

### Excluding Files or Directories

The workflow reviews all changed files in a PR. To exclude certain patterns, modify the workflow to filter the `changed_files` list before passing to the AI.

### Adjusting CI Wait Behavior

To change how the workflow waits for CI:

- Increase `ci-timeout-minutes` for slower CI pipelines
- Remove the CI wait step entirely to review immediately (not recommended)
- Add specific check names to exclude from CI wait logic

## Troubleshooting

### Review Not Triggering

1. Check that the workflow file is on your default branch
2. Verify the PR is not a draft
3. Verify the PR is not from dependabot (use `/review` to manually trigger for dependabot PRs)
4. Ensure auto-merge is not enabled (if you want reviews)
5. Check workflow permissions (needs `pull-requests: write`)

### CI Timeout

- Increase `ci-timeout-minutes` input
- Check that CI checks are completing within the timeout
- Verify check names aren't being filtered incorrectly

### Invalid API Response

- Verify your API key is correct and has proper permissions
- Check that the endpoint URL matches your OpenAI setup
- Ensure the model name is correct for your deployment

## Example Output

The workflow posts a comment like this:

```markdown
## AI Code Review

✅ **Patch is correct** (confidence: 0.95)

The changes properly implement user authentication with secure password hashing.

### Findings (2)

#### [P2] Missing error handling for database connection failure

📍 `backend/auth.py:45-48` | Confidence: 0.85

The `authenticate_user` function doesn't handle the case where the database
connection fails. If `db.connect()` raises an exception, the user will see
a 500 error instead of a proper authentication failure message.

#### [P3] Consider adding test for invalid credentials

📍 `backend/tests/test_auth.py:1-10` | Confidence: 0.70

The test suite covers the happy path but doesn't test authentication with
invalid credentials. Consider adding a test case for this scenario.

---
*Triggered by: PR opened/ready*
```

## License

This workflow is part of the Oxidian Claude Code Plugins repository.
