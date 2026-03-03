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

There are two ways to use this action:

1. **Reusable Workflow** — recommended for Oxidian org repos. Includes CI waiting, should-review gate, `/review` command parsing.
2. **Composite Action** — for external users or custom workflows. You control checkout, CI gating, and trigger logic.

---

### Option A: Reusable Workflow

1. Add your OpenAI API key to your repository secrets (`OPENAI_API_KEY`)
2. Copy [`ai-review-reusable-example.yml`](../ai-review-reusable-example.yml) to `.github/workflows/ai-review.yml`
3. Update the inputs and secrets for your OpenAI setup

> **Do not** add a `concurrency` group in your caller workflow — the reusable workflow already manages concurrency. Adding one causes deadlocks.

#### Workflow Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `responses-api-endpoint` | Yes | - | OpenAI API endpoint URL |
| `model` | No | `gpt-5.3-codex` | OpenAI model to use |
| `effort` | No | `xhigh` | Review effort level: `low`, `medium`, `high`, or `xhigh` |
| `ci-timeout-minutes` | No | `30` | Max minutes to wait for CI checks to pass |

#### Workflow Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `openai-api-key` | Yes | Your OpenAI or Azure OpenAI API key |

**Note:** Dependabot PRs are always excluded from automatic reviews. You can manually trigger a review on any PR (including dependabot PRs) using the `/review` comment command.

---

### Option B: Composite Action

Use `oxidian/actions/ai-review@main` directly for full control over when and how the review runs.

Copy [`ai-review-composite-example.yml`](../ai-review-composite-example.yml) to `.github/workflows/ai-review.yml` and update the inputs and secrets.

Prerequisites:

- Caller must run `actions/checkout@v6` with `fetch-depth: 0` before calling the action
- Workflow needs `pull-requests: write` and `contents: read` permissions
- You must manage your own `concurrency` group (the example includes one)

#### Action Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `openai-api-key` | Yes | - | OpenAI API key (passed as input since composite actions can't access secrets) |
| `responses-api-endpoint` | Yes | - | OpenAI API endpoint URL |
| `model` | Yes | - | Model name |
| `effort` | No | `xhigh` | Effort level |
| `pr-number` | Yes | - | PR number to review |
| `custom-instructions` | No | `''` | Additional reviewer instructions |

#### Action Outputs

| Output | Description |
|--------|-------------|
| `review-json` | Raw JSON output from Codex |
| `review` | Formatted review comment body (markdown) |
| `correctness` | Verdict string (e.g. `"patch is correct"`) |
| `confidence` | Confidence score |
| `findings-count` | Number of findings |

---

## How It Works

### Automatic Triggers

1. **PR Opened/Ready**: Automatically reviews when a PR is opened or marked ready for review
2. **New Commits**: Reviews new commits on PRs that had in-progress, failed CI, or errored reviews
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

## Configuration

### For Azure OpenAI

```yaml
responses-api-endpoint: "https://your-resource-name.openai.azure.com/openai/v1/responses"
model: "gpt-5.3-codex"  # or your deployed model name
```

### For OpenAI API

```yaml
responses-api-endpoint: "https://api.openai.com/v1/responses"
model: "gpt-5.3-codex"  # or your preferred model
```

## Priority Levels

Findings are categorized by priority:

- **P0**: Drop everything to fix (security vulnerabilities, data loss, critical bugs)
- **P1**: Urgent, fix in next cycle (functional bugs, performance issues)
- **P2**: Normal priority (minor bugs, edge cases, error handling)
- **P3**: Low priority (code quality, tests, documentation)

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
