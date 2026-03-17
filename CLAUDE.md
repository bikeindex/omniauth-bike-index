omniauth-bike-index is a Ruby Gem — an OmniAuth OAuth2 strategy for Bike Index.

## Code style

Ruby is formatted with the standard gem. Run `bin/lint` to automatically format the code, or `bin/lint --no-fix` to check without fixing.

### Code guidelines:

- Code in a functional way. Avoid mutation (side effects) when you can.
  - use the functionable gem to make functional modules
- Don't mutate arguments
- Don't monkeypatch
- make methods private if possible (use `conceal :method_name` in functionable modules)
- Omit named arguments' values from hashes (ie prefer `{x:, y:}` instead of `{x: x, y: y}`)
- Prefer less code, by character count (excluding whitespace and comments). Use `bin/char_count {FILE OR FOLDER}` to get the non-whitespace character count
- prefer un-abbreviated variable names

## Testing

This project uses Rspec for tests. Run `bin/rspec`. All business logic should be tested.

- Tests should either: help make the code correct now or prevent bugs in the future. Don't add tests that don't do one of those things.
- Avoid mocking objects
- Use `context` and `let` to isolate what varies between examples.
  - Each `it` block should live in a `context` that names the condition, with `let` overrides for only what differs in that case. Avoid repeating setup across sibling `it` blocks.
