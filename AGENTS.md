# AGENTS.md

This file provides guidance to AI coding assistants when working in this repository.

## Project Overview

This repository contains reusable GitHub Actions for automated AI-powered code reviews:

- **ai-review/**: Composite action that performs AI code analysis on pull requests using OpenAI Codex
- **cancel-ai-review/**: Composite action that cancels AI review workflows when auto-merge is enabled
- **.github/workflows/ai-review.yml**: Reusable workflow wrapping the composite action with CI waiting, `/review` command support, and smart gating logic

The repo applies its own actions to itself via `self-review.yml` and `cancel-self-review.yml`.

## Commands

```bash
make setup   # Install dependencies with uv, set up pre-commit hooks
make format  # Auto-format YAML files and apply zizmor security fixes
make check   # Run yamlfix, zizmor, and actionlint validation
```

## Architecture

### AI Review Flow

1. Workflow receives PR event (open, ready, synchronize, or `/review` comment)
2. Waits for CI checks to pass (configurable timeout)
3. Generates diff using merge-base to exclude unrelated changes
4. Renders prompt from `ai-review/templates/review-prompt.md` with PR context
5. Calls OpenAI Codex API with structured JSON output requirements
6. Parses response and posts formatted markdown comment with findings

### Review State Tracking

Review state is tracked via HTML comments in PR comments: `in_progress`, `ci_failed`, `completed`, `error`

### Key Files

- `ai-review/action.yml` - Composite action definition (inputs, outputs, shell steps)
- `ai-review/templates/review-prompt.md` - AI review prompt with guidelines and JSON schema
- `.github/workflows/ai-review.yml` - Reusable workflow with full automation logic

## Testing Changes

Run `make check`
