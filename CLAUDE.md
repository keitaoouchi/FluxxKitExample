# CLAUDE.md

## Overview

A real-world example app for FluxxKit 2.0.0. Works as a Spotify client with OAuth authentication, album search, album detail, artist detail, and track preview playback.

## Stack

| Item | Value |
|------|-------|
| Swift | 6.0 (strict concurrency) |
| iOS | 17+ |
| UI | SwiftUI |
| Architecture | FluxxKit 2.0.0 (`Store` / `Reducer` / `Effect`) |
| Reactive | Swift Concurrency + Observation framework |
| Dependency Mgmt | SPM (project generated via XcodeGen) |
| HTTP | URLSession (async/await) |
| JSON | Codable |
| Image | AsyncImage |
| Keychain | Security framework directly |
| Testing | Swift Testing (`@Suite`, `@Test`, `#expect`), swift-snapshot-testing |

## Build & Run

```bash
# Generate project (first time & after project.yml changes)
xcodegen generate

# Build
xcodebuild build -scheme FluxxKitExample -destination 'platform=iOS Simulator,name=iPhone 16'

# Test
xcodebuild test -scheme FluxxKitExample -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Conventions

### Feature structure

- Each feature lives under `Features/<FeatureName>/` with State, Action, Reducer, and View together
- `*State.swift` co-locates `State` (struct, StateType) + `Action` (enum, ActionType) + `Reducer`
- Reducer is defined as a top-level `let` constant (`let searchReducer = Reducer<SearchState, SearchAction> { state, action in ... }`)
- View owns its Store via `@State private var store = Store(initialState: ..., reducer: ...)`

### Effects

- Side effects (API calls etc.) are expressed with `Effect.run { dispatch in ... }`
- The `Effect.run` closure is non-throwing, so wrap async work in `do/catch` inside
- Use `Effect.many([.run { ... }, .run { ... }])` for parallel async operations (see ArtistDetail)

### Store sharing

- Feature-local Stores are owned by their View via `@State`
- App-wide Stores (e.g. TrackPlayer) are held at the App root via `@State` and distributed with `.environment()`

### Navigation

- `NavigationStack` with value-based `.navigationDestination(for:)`

### Testing

- Uses Swift Testing (`@Suite`, `@Test`, `#expect`)
- Reducer tests are pure function tests: `let (newState, effect) = reducer.reduce(state, action)`
- Model decoding tests load JSON from `fixtures/` via `TestHelpers.swift`
- Snapshot tests use [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) with `.image(on: .iPhone13)`
- Snapshot tests inject a no-op Reducer (returns state unchanged) to prevent `.onAppear` side effects
- Helpers and mock fixtures live in `SnapshotTestHelpers.swift`
- Reference images are stored under `__Snapshots__/` inside each snapshot test directory

## Spotify OAuth

- Client ID: `57e837fb225048c286c07d06bd236631`
- Redirect URI: `fluxxkitexample://callback`
- Callback URL Scheme: `fluxxkitexample`
- Flow: Authorization Code Flow with PKCE (S256)
- `ASWebAuthenticationSession` with `prefersEphemeralWebBrowserSession: true`
