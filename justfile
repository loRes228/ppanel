set unstable := true

env := "dev"
module := "ppanel"
env_directory := "env"
src_directory := "src"
cache_directory := ".cache"
env_file := join(env_directory, env + ".env")

[private]
default: help

[doc("Show this help menu")]
@help:
    just --list

[doc("Removes caches and temporary files")]
[group("Environment")]
clean:
    rm --force --recursive {{ cache_directory }}
    find -type d -name "__pycache__" -exec rm --force --recursive {} +

[doc("Run application locally")]
[group("Project")]
run:
    uv run --env-file {{ env_file }} --module {{ src_directory }}.{{ module }}

[doc("Running code quality checks")]
[group("Сode Quality")]
lint:
    uv run mypy {{ src_directory }}
    uv run ruff check {{ src_directory }}
    uv run ruff format --check {{ src_directory }}
    uv run --module slotscheck {{ src_directory }}
    uv run deptry {{ src_directory }}
    uv run dotenv-linter {{ env_directory }}/*
    uv run toml-sort --check $(just _rglob "*.toml")
    uv run yamlfix --check $(just _rglob "*.yaml")
    uv run shellcheck --enable all $(just _rglob "*.sh")
    uv run codespell
    just --check --fmt

[doc("Formatting and fixing code")]
[group("Сode Quality")]
format:
    uv run ruff check --fix --unsafe-fixes {{ src_directory }}
    uv run ruff format {{ src_directory }}
    uv run toml-sort --in-place $(just _rglob "*.toml")
    uv run yamlfix $(just _rglob "*.yaml")
    uv run codespell --write-changes
    just --fmt

[private]
@_rglob pattern:
    find -type f -name {{ pattern }} -not -path "*/.*/*" -print
