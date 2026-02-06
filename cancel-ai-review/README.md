# Cancel AI Review Action

A GitHub Action that cancels and deletes AI review workflow runs for a pull request. Useful when auto-merge is enabled and you want to skip the review process.

## Usage

See [cancel-ai-review-example.yml](../cancel-ai-review-example.yml) for a complete workflow example.

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

1. Looks up the PR number from the head commit SHA
2. Queries workflow runs matching the head SHA or PR number
3. Cancels any in-progress runs
4. Waits 30 seconds for cancellations to complete
5. Deletes the cancelled runs

## Why Use This?

When auto-merge is enabled on a PR, it typically means the author trusts the changes and wants them merged quickly once CI passes. Running an AI review in this case is unnecessary and wastes resources.

This action integrates with the `auto_merge_enabled` event to automatically clean up any pending AI review runs.
