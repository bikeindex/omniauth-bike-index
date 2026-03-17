omniauth-bike-index is a Ruby Gem — an OmniAuth OAuth2 strategy for Bike Index.

## Code style

Ruby is formatted with the standard gem. Run `bin/lint` to automatically format the code.

### Code guidelines:

- Don't mutate arguments
- Don't monkeypatch
- Omit named arguments' values from hashes (ie prefer `{x:, y:}` instead of `{x: x, y: y}`)
- Prefer less code. prefer un-abbreviated variable names

## Testing

This project uses Rspec for tests (`bundle exec rspec`).

- Tests should either: help make the code correct now or prevent bugs in the future. Don't add tests that don't do one of those things.
- Use `context` and `let` to isolate what varies between examples.
  - Each `it` block should live in a `context` that names the condition, with `let` overrides for only what differs in that case. Avoid repeating setup across sibling `it` blocks.
