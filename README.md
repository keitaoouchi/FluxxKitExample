# FluxxKitExample

A Spotify client demonstrating [FluxxKit v2](https://github.com/keitaoouchi/FluxxKit/tree/feature/v2) with SwiftUI.

## Stack

- **Swift 6** / **iOS 17+** / **SwiftUI**
- **FluxxKit v2** — Store / Reducer / Effect / Observation framework
- **Swift Concurrency** — async/await, Sendable
- **SPM only** — no CocoaPods, no Carthage

## Features

1. OAuth authentication (Spotify Implicit Grant Flow)
2. Album search
3. Album detail with track list
4. Artist detail with related artists
5. 30-second track preview player

## Getting started

Requirements: Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
brew install xcodegen
xcodegen generate
open FluxxKitExample.xcodeproj
```

Build and run on iOS 17+ simulator.

## Testing

```bash
xcodebuild test -scheme FluxxKitExample -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

Each feature follows the FluxxKit v2 pattern:

```
State  → immutable value type (struct conforming to StateType)
Action → enum conforming to ActionType
Reducer → LocalReducer (pure function: State + Action → State + Effect)
View   → SwiftUI view with @State Store
```

Effects handle async side effects (API calls) via `Effect.run` with `do/catch`.
The `TrackPlayer` store is shared app-wide via `.environment()`.
