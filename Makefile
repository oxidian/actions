.PHONY: check fix

format:
	uv run yamlfix --exclude '.venv/**' .
	uv run zizmor --fix .

check:
	uv run yamlfix --check --exclude '.venv/**' .
	uv run zizmor .
	uv run actionlint
