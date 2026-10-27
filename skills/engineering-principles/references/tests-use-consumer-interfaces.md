# Tests use consumer interfaces — prove the path that runs

## Definition

The discipline that a test drives the same entry point, protocol and data shape a real caller uses,
rather than an internal seam invented for the test's convenience.

## The Principle in One Move

For each feature, ask what a consumer actually invokes — the CLI verb, the HTTP route, the exported
function with its real serialization — and write the test against that. Reserve direct calls into
internals for the cases where the internals *are* the product: a pure algorithm, a parser, a
data structure. Everything else goes through the door the user goes through.

The failure this prevents is specific. A test that reaches past the boundary proves that the logic
works when the boundary is skipped, which is precisely the case production never runs.

## The Sharp Test

> **Does this test call the same entry point and pass the same data a real consumer passes?**

If the test constructs the object, sets a private field, or calls a helper that the request path
does not call, it is proving a different program.

## What This Isn't

- **Not a ban on unit tests.** Pure functions should be tested directly and quickly. The rule binds
  where a boundary exists: serialization, validation, middleware, permissions, routing.
- **Not a ban on mocks.** Mocking an external third party is correct and often necessary. Mocking
  *your own* boundary — stubbing out the HTTP layer you are supposed to be testing — is the error.
- **Not "only end-to-end tests".** One integration test through the real boundary plus fast unit
  tests behind it is the normal shape. What is forbidden is an integration-shaped claim resting on
  a unit-shaped test.
- **Not a demand for production services.** A test server, an in-process client and a fixture
  database all count, provided the request travels the real path.

## Failure Mode

**Backdoor verification drift.** Every test passes because every test calls the internal method
directly. In production the request fails at a layer the tests never touched: the field name in the
JSON does not match the struct tag, the middleware rejects the content type, the permission check
was never exercised. The suite is green, the feature does not work, and the gap is invisible
precisely because the tests look thorough.

Its second shape is **fixture drift**: the test builds its input by hand from a schema the
production client no longer sends, so the test asserts behavior for a caller that no longer exists.

## Generic Example

```python
# Violation: reaches past the boundary the user goes through.
def test_activate():
    user = User(name="ada")
    user._set_active_internal(True)      # skips the token check, the audit log, the response
    assert user.is_active

# Compliance: same entry point, same serialization as a real client.
def test_activate(client):
    token = client.post("/api/v1/users", json={"name": "ada"}).json()["token"]
    assert client.post(f"/api/v1/users/verify?token={token}").status_code == 200
    assert client.get("/api/v1/users/ada").json()["is_active"] is True
```

The compliance version catches what the violation cannot: a renamed field, a missing audit write, or
a verification route that no longer accepts the token it issues.

The same test for a CLI: invoke the binary with arguments and assert on exit code and output, rather
than importing its `main` and calling the function it dispatches to — the argument parsing is part
of what ships.
