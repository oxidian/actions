setup:
	@bash scripts/banner.sh
	uv sync --frozen
	uv run pre-commit install

format:
	uv sync --frozen
	uv run yamlfix --exclude '.venv/**' .
	uv run zizmor --fix .

check:
	uv sync --frozen
	uv run yamlfix --check --exclude '.venv/**' .
	uv run zizmor .
	uv run actionlint
