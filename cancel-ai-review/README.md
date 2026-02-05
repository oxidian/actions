# Cancel AI Review Action

A GitHub Action that cancels and deletes AI review workflow runs for a pull request. Useful when auto-merge is enabled and you want to skip the review process.

## Usage

Create `.github/workflows/cancel-ai-review-on-auto-merge.yml` in your repository:

```yaml
name: Cancel AI Review on Auto-Merge

on:
  pull_request:
    types: [auto_merge_enabled]

permissions:
  actions: write

jobs:
  cancel:
    runs-on: ubuntu-latest
    steps:
      - name: Cancel AI review runs
        uses: oxidian/actions/cancel-ai-review@main
        with:
          head-sha: ${{ github.event.pull_request.head.sha }}
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `head-sha` | Yes | - | PR head SHA to cancel reviews for |
| `workflow-name` | No | `ai-review.yml` | Name of the AI review workflow file |

## Outputs

| Output | Description |
|--------|-------------|
| `cancelled-count` | Number of workflow runs cancelled |

## How It Works

1. Queries the GitHub API for workflow runs matching the head SHA
2. Cancels any in-progress runs
3. Waits 30 seconds for cancellations to complete
4. Deletes the cancelled runs

## Why Use This?

When auto-merge is enabled on a PR, it typically means the author trusts the changes and wants them merged quickly once CI passes. Running an AI review in this case is unnecessary and wastes resources.

This action integrates with the `auto_merge_enabled` event to automatically clean up any pending AI review runs.
