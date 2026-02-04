.PHONY: check fix

fix:
	uv run zizmor --fix .

check:
	uv run actionlint
	uv run zizmor .
