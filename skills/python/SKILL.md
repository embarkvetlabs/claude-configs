---
name: python
description: Use when writing or reviewing Python code. Covers type hints, testing with pytest, error handling, project structure, and common pitfalls.
---

# Python Best Practices

## Type Hints

- Type hint every function signature. No exceptions for "simple" functions.
- Use `from __future__ import annotations` for modern syntax in older Python.
- Use `str | None` (3.10+) instead of `Optional[str]`.
- Use `TypedDict` for dict shapes, `dataclass` or Pydantic `BaseModel` for structured data.
- Run mypy or pyright in CI. Type hints that aren't checked are documentation that rots.

```python
from dataclasses import dataclass

@dataclass
class User:
    id: int
    name: str
    email: str
    is_active: bool = True

# Not this:
user = {"id": 1, "name": "Paul", "email": "paul@test.com"}
```

## Error Handling

- Catch specific exceptions. Never bare `except:` or `except Exception:` unless you re-raise.
- Use custom exception classes for domain errors:

```python
class UserNotFoundError(Exception):
    def __init__(self, user_id: int) -> None:
        self.user_id = user_id
        super().__init__(f"User {user_id} not found")
```

- Don't use exceptions for control flow. Check conditions first.
- Always include context in error messages — what was the input, what was expected, what happened.
- Use `raise ... from e` to chain exceptions and preserve the traceback.

## Testing (pytest)

- Use fixtures for setup, not class-based test inheritance.
- Name tests as `test_<function>_<scenario>_<expected_result>`:

```python
def test_create_user_with_duplicate_email_raises_error(db_session):
    create_user(db_session, name="Paul", email="paul@test.com")
    with pytest.raises(DuplicateEmailError):
        create_user(db_session, name="Other", email="paul@test.com")
```

- Use `pytest.mark.parametrize` for testing multiple inputs:

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("Hello World", "HELLO WORLD"),
])
def test_uppercase(input: str, expected: str) -> None:
    assert uppercase(input) == expected
```

- Use `tmp_path` fixture for file tests. Use `monkeypatch` for env vars.
- Use `freezegun` or `time_machine` for time-dependent tests.
- Mock external services, not internal functions. Use `responses` or `httpx_mock` for HTTP.
- Keep tests fast. If a test needs a database, use a transaction rollback pattern.

## Project Structure

```
project/
├── pyproject.toml          # Single source of truth for config
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── models.py
│       ├── services.py
│       └── utils.py
├── tests/
│   ├── conftest.py         # Shared fixtures
│   ├── test_models.py
│   └── test_services.py
└── scripts/                # One-off scripts, not importable
```

- Use `pyproject.toml` for everything: dependencies, tool config (ruff, mypy, pytest).
- Use `uv` or `pip-tools` for dependency management. Pin versions in lock files.
- Use `src/` layout to prevent accidental imports from the project root.

## Common Pitfalls

- **Mutable default arguments:** `def f(items=[])` shares the list across calls. Use `def f(items=None)` and `items = items or []`.
- **Late binding closures:** `[lambda: i for i in range(3)]` all return 2. Use `lambda i=i: i`.
- **Import cycles:** If A imports B and B imports A, restructure. Move shared types to a third module.
- **`is` vs `==`:** Use `is` only for `None`, `True`, `False`. Use `==` for value comparison.
- **String concatenation in loops:** Use `"".join(parts)` or f-strings, not `+=`.
- **Bare `*args, **kwargs` forwarding:** Loses type information. Type the specific parameters you accept.
- **`datetime.now()`:** Always use `datetime.now(tz=timezone.utc)`. Naive datetimes cause timezone bugs.
- **`os.path` vs `pathlib`:** Use `pathlib.Path` for all file path operations. It's cleaner and cross-platform.

## Async (asyncio)

- Don't mix sync and async carelessly. Sync calls in async code block the event loop.
- Use `asyncio.gather` for concurrent tasks, `asyncio.TaskGroup` (3.11+) for structured concurrency.
- Use `async for` with async iterators. Don't collect everything into memory.
- Use `httpx` (async-native) over `requests` in async code.
