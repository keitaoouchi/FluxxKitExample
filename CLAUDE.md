# CLAUDE.md

## Overview

FluxxKit v2 の Real World Example アプリ。Spotify クライアントとして、OAuth 認証・アルバム検索・アルバム詳細・アーティスト詳細・トラック再生の機能を持つ。

## Stack

| 項目 | 値 |
|------|----|
| Swift | 6.0 (strict concurrency) |
| iOS | 17+ |
| UI | SwiftUI |
| Architecture | FluxxKit 2.x (`Store` / `LocalReducer` / `Effect`) |
| Reactive | Swift Concurrency + Observation framework |
| Dependency Mgmt | SPM (XcodeGen でプロジェクト生成) |
| HTTP | URLSession (async/await) |
| JSON | Codable |
| Image | AsyncImage |
| Keychain | Security framework 直接利用 |
| Testing | Swift Testing (`@Suite`, `@Test`, `#expect`) |

## FluxxKit v2 API

ソース: `github.com/keitaoouchi/FluxxKit` branch `feature/v2`

### Core Types

- **`StateType`** — `protocol StateType: Sendable {}`
- **`ActionType`** — `protocol ActionType: Sendable {}`
- **`Effect<Action>`** — `.none` / `.run(non-throwing async closure)` / `.many([Effect])`
- **`Reducer<State, Action, GlobalAction>`** — struct。`reduce: (State, Action, Relay<GlobalAction>) -> (State, Effect<Action>)`
- **`LocalReducer<State, Action>`** — `Reducer<State, Action, Never>` の typealias。init は `(State, Action) -> (State, Effect<Action>)`
- **`Store<State, Action>`** — `@Observable @MainActor final class`。`state` は `public private(set)`
- **`Relay<Action>`** — 子Store → 親Store ブリッジ。本プロジェクトでは `Relay<Never>.unused` のみ使用

### Important Notes

- `Effect.run` のクロージャは **non-throwing**。API 呼び出し等は `do/catch` で囲む必要がある
- `Reducer.reduce` は 3 引数 `(State, Action, Relay<GlobalAction>)`。テストでは `.unused` を渡す
- Store は `@MainActor`。`@Sendable` クロージャから `dispatch` する場合は `await` が必要

## Project Structure

```
project.yml                          # XcodeGen 設定
FluxxKitExample/
  App.swift                          # @main entry point
  ContentView.swift                  # 認証分岐 + TrackPlayer overlay
  Models/
    ExternalUrls.swift               # Codable shared type
    SpotifyImage.swift               # 画像モデル (SwiftUI Image との衝突回避)
    Artist.swift                     # Identifiable, Hashable, Codable
    Album.swift                      # Identifiable, Hashable, Codable
    Track.swift                      # formattedDuration computed property あり
    APIError.swift                   # .requestError / .parseError / .unauthorized
  API/
    KeychainHelper.swift             # Security framework ラッパー (enum, static methods)
    Authentication.swift             # @Observable @MainActor, Keychain 永続化
    SpotifyAPI.swift                 # URLSession async/await, 5 endpoints
  Features/
    Auth/OAuthView.swift             # ASWebAuthenticationSession + Implicit Grant
    Search/
      SearchState.swift              # State + Action + Reducer
      SearchView.swift               # NavigationStack + .searchable
      AlbumCardView.swift            # Album 行表示
    AlbumDetail/
      AlbumDetailState.swift         # State + Action + Reducer
      AlbumDetailView.swift          # Cover + artist link + track list
      TrackRow.swift                 # Play indicator 付きトラック行
    ArtistDetail/
      ArtistDetailState.swift        # Effect.many で 3 並列 API 呼び出し
      ArtistDetailView.swift         # Artist header + sections
      AlbumGridView.swift            # 横スクロール album grid
      RelatedArtistGridView.swift    # 横スクロール artist grid
    TrackPlayer/
      TrackPlayerState.swift         # play/pause/toggle/stop + visibility
      TrackPlayerView.swift          # Bottom bar (56pt, .ultraThinMaterial)
      AudioPlayer.swift              # AVPlayer ラッパー (NotificationCenter async)
  Shared/
    Theme.swift                      # Color.spotifyGreen, Color.spotifyBlack
    LoadingStateView.swift           # 汎用 loading/empty/failed
FluxxKitExampleTests/
  TestHelpers.swift                  # fixture JSON ローダー
  Models/
    AlbumDecodingTests.swift
    ArtistDecodingTests.swift
    TrackDecodingTests.swift
  Reducers/
    SearchReducerTests.swift
    AlbumDetailReducerTests.swift
    ArtistDetailReducerTests.swift
    TrackPlayerReducerTests.swift
fixtures/                            # Spotify API レスポンスの JSON fixtures
```

## Build & Run

```bash
# プロジェクト生成 (初回 & project.yml 変更時)
xcodegen generate

# ビルド
xcodebuild build -scheme FluxxKitExample -destination 'platform=iOS Simulator,name=iPhone 16'

# テスト
xcodebuild test -scheme FluxxKitExample -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Conventions

- 各 Feature は State / Action / Reducer / View を同ディレクトリにまとめる
- Reducer はトップレベル `let` 定数 (`let searchReducer = LocalReducer<...> { ... }`)
- Effect.run 内は `do/catch` で非同期処理をラップ
- TrackPlayer Store は App ルートで `@State` → `.environment()` で全画面共有
- Navigation は `NavigationStack` + value-based `.navigationDestination(for:)`
- テストは Swift Testing (`@Suite`, `@Test`, `#expect`)
- Reducer テストは純粋関数テスト: `reducer.reduce(state, action, .unused)`

## Spotify OAuth

- Client ID: `57e837fb225048c286c07d06bd236631`
- Redirect URI: `https://github.com/keitaoouchi/FluxxKitExample`
- Flow: Implicit Grant (URL fragment から access_token 取得)
- `ASWebAuthenticationSession` + `prefersEphemeralWebBrowserSession: true`
