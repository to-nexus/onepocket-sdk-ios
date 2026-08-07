# CROSSx iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> 한국어 문서: [README.ko.md](README.ko.md)

CROSSx iOS SDK is a Swift SDK that provides OAuth-based authentication and Embedded Wallet functionality.

## Features

- **OAuth Authentication** — Social login (Google, Apple, etc.)
- **Embedded Wallet** — Users never handle private keys directly
- **EVM Compatible** — CAIP-2 based chain identification (e.g. `eip155:612055`)
- **Transaction Confirmation Dialog** — Mandatory user approval before signing/sending (non-bypassable)
- **Secure Storage** — iOS Keychain-backed data storage
- **Native OAuth** — Uses `ASWebAuthenticationSession`
- **Session Restore** — Automatic sign-in on app relaunch
- **Biometric Authentication** — Face ID / Touch ID support for wallet unlock
- **Theme Customization** — Light/Dark mode with custom color token overrides
- **Localization (i18n)** — English (default) and Korean; extend with any `.lproj`
- **Clean Architecture** — Testable and maintainable code structure
- **Swift Concurrency** — Full async/await support
- **Zero Dependencies** — Pure Swift/Foundation implementation

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Supported Networks

### Cross Network
- **ONEchain Mainnet** (eip155:612055) — Production
- **ONEchain Testnet** (eip155:612044) — Development (default)

### Other EVM Chains
- Ethereum Mainnet, Sepolia
- Polygon Mainnet, Amoy
- BNB Smart Chain Mainnet, Testnet

## Installation

### Swift Package Manager

#### Via Xcode

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Enter the distribution repository URL:
   ```
   https://github.com/to-nexus/onepocket-sdk-ios
   ```
4. Select a version rule and add the package

#### Via Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/to-nexus/onepocket-sdk-ios", from: "2.0.0")
]
```

## Quick Start

### 1. Initialize the SDK

```swift
import CROSSxCoreSDK

let sdk = try CROSSxSDK(config: SDKConfig(
    projectId: "your-project-id",
    appName: "Your App Name"
))

// Restore session (auto sign-in if a saved token exists)
try await sdk.initialize()
```

#### Info.plist / xcconfig-Based Initialization

```swift
let sdk = try CROSSxSDK(config: try SDKConfig.fromInfoPlist(
    projectId: "your-project-id",
    appName: "Your App Name"
))
```

### 2. Register a Custom URL Scheme

The SDK automatically generates a URL scheme from the `projectId`: `crossx-{projectId}`

Register it in your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>crossx-your-project-id</string>
        </array>
    </dict>
</array>
```

Handle the callback URL in your `AppDelegate` or `SceneDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return sdk.handleURL(url)
}
```

### 3. Sign In

```swift
let result = try await sdk.signIn()
if result.success {
    print("Signed in!")
    print("Wallet address: \(result.walletAddress ?? "")")
}
```

To sign in and create a wallet in one step:

```swift
let result = try await sdk.signInWithCreate()
```

### 4. Create and Check Wallet

```swift
// Check wallet status before creating
let status = try await sdk.checkWallet()

// Create wallet (automatically migrates existing backup if found)
let wallet = try await sdk.createWallet()
print("Address: \(wallet.address)")
```

### 5. Get User Info

```swift
let userInfo = try await sdk.getUserInfo()
print("Email: \(userInfo.email ?? "")")
print("Addresses: \(userInfo.addresses)")
```

### 6. CAIP-2 Chain Identification

The SDK does not manage chains internally. Pass the CAIP-2 chain ID when calling sign/send methods.

```swift
let chainId = ChainId.crossMainnet    // "eip155:612055"
let chainId = ChainId.crossTestnet    // "eip155:612044"
let chainId = ChainId.ethereumMainnet // "eip155:1"
```

### 7. Transaction Confirmation Dialog

`signTransaction()`, `sendTransaction()`, and `sendTransactionAndWait()` automatically display a user approval dialog. There is no public API to bypass this.

```swift
do {
    let result = try await sdk.sendTransactionAndWait(tx, chainId: ChainId.crossTestnet)
    print("txHash: \(result.txHash)")
} catch let error as CROSSxError {
    if case .userRejected = error {
        print("User cancelled the transaction")
    }
}
```

### 8. Sign Out

```swift
try await sdk.signOut()
```

## Additional APIs

### Biometric Authentication

```swift
let available = sdk.canUseBiometric()
let enabled = sdk.isBiometricEnabled()
try await sdk.setBiometricEnabled(true)
```

### Token Refresh

```swift
let newAccessToken = try await sdk.refreshToken()
```

### Theme Customization

```swift
let sdk = try CROSSxSDK(config: SDKConfig(
    projectId: "your-project-id",
    appName: "Your App Name",
    theme: .system,
    themeTokens: SDKThemeTokens(
        light: SDKColorOverrides(primary: "#FF6B35", bg: "#F5F0EB"),
        dark:  SDKColorOverrides(primary: "#FF6B35", bg: "#1A0A00")
    )
))

// Change theme at runtime (takes effect on the next modal)
sdk.applyTheme(.dark)
```

## OAuth Flow

```
iOS SDK → Open ASWebAuthenticationSession
  URL: {oauthServiceUrl}/google?redirectScheme={callbackScheme}

OAuth Server → Callback via Deep Link
  {callbackScheme}://{oauthHost}/?status=success&data={base64}

SDK → base64 decode → extract token → JWT verification → done
```

> On web, `window.open()` + `postMessage` is used instead.

## Localization (i18n)

The SDK uses Apple-standard `.strings` resources via `Bundle.module`.

| Language | Code | Status  |
|----------|------|---------|
| English  | `en` | Default |
| Korean   | `ko` | Supported |

To force the SDK UI language regardless of the app/system language, pass `locale` to `SDKConfig`:

```swift
let sdk = try CROSSxSDK(config: SDKConfig(
    projectId: "your-project-id",
    appName: "Your App Name",
    locale: .ko // or .en
))
```

If `locale` is omitted or `nil`, the SDK follows Apple's standard localization fallback rules.

To add a new language, place a `.lproj` folder in `Sources/CROSSxCoreSDK/Resources/` — no code changes required:

```
Sources/CROSSxCoreSDK/Resources/
  ├── en.lproj/Localizable.strings
  ├── ko.lproj/Localizable.strings
  └── ja.lproj/Localizable.strings   ← add new language here
```

## Architecture

CROSSx SDK uses **Clean Architecture + Hexagonal Architecture (Ports & Adapters)**.

```
Sources/CROSSxCoreSDK/
 ├─ Core/          # Pure business logic
 │   ├─ UseCases/  # Use Cases
 │   ├─ Ports/     # Protocols (Ports)
 │   └─ Types/     # Domain types
 │
 ├─ Adapters/      # Platform implementations
 │   ├─ Crypto/
 │   ├─ Storage/
 │   ├─ OAuth/
 │   └─ ...
 │
 └─ SDK/           # Public API
     └─ CROSSxSDK.swift
```

## Example App

```bash
cd Examples/CROSSxSample
tuist install
tuist generate
open CROSSxSample.xcworkspace
```

See [Examples/CROSSxSample/README.md](Examples/CROSSxSample/README.md) for details.

## Documentation

- [Architecture Guide](doc/01-architecture.md)
- [Authentication](doc/02-authentication.md)
- [Token Management](doc/03-token-management.md)
- [Chain & Network](doc/04-chain-network.md)
- [Wallet & Transaction](doc/05-wallet-transaction.md)
- [Gas & Fee](doc/06-gas-fee.md)
- [API Reference](doc/07-api-reference.md)
- [Cross-Platform](doc/08-cross-platform.md)
- [Environment Config](doc/09-environment-config.md)
- [CrossWebAuthKit Relationship](doc/10-crosswebauth-relationship.md)
- [Password & Private SDK](doc/11-password-private-sdk.md)
- [Localization (i18n)](doc/12-localization-i18n.md)

## Release

### Repository Structure

| Repository | Role |
|---|---|
| `crossy-sdk-ios-develop` | Source development, tests, CI/CD (this repo) |
| `crossx-sdk-ios` | xcframework binary distribution (SPM / CocoaPods) |
| `onepocket-sdk-ios` | Same binaries, mirrored for the ONEpocket brand |

### Release Process

#### 1. Update CHANGELOG.md

Move the `[Unreleased]` section content to a versioned release entry.

#### 2. Update version constant and commit

```bash
# Sources/CROSSxCoreSDK/SDK/CROSSxSDK.swift
public static let version = "x.y.z"
```

```bash
git add -A && git commit -m "chore: version x.y.z"
```

#### 3. Create and push a release tag

```bash
./scripts/tag-release.sh patch    # x.y.0 → x.y.1
./scripts/tag-release.sh minor    # x.0.z → x.1.0
./scripts/tag-release.sh x.y.z   # explicit version
./scripts/tag-release.sh beta     # auto-increment beta (e.g. 2.0.3-beta.2)
./scripts/tag-release.sh 2.0.4 beta  # auto-increment beta for a specific base version
./scripts/tag-release.sh 2.0.3-beta.1  # explicit beta
```

After the tag is pushed, GitHub Actions automatically:
1. Runs all tests (`CROSSxCoreSDK` + `CrossWebAuthKit`)
2. Builds xcframeworks (`CROSSxSDK.xcframework`, `CrossWebAuthKit.xcframework`)
3. Copies xcframeworks to every distribution repo (`crossx-sdk-ios`, `onepocket-sdk-ios`) and updates version
4. Creates GitHub Releases in the source repo and in every distribution repo

Beta tags are created as GitHub prereleases and are not marked as the latest release. When installing a beta, specify the exact version in both Swift Package Manager and CocoaPods.

> See [DEPLOYMENT.md](DEPLOYMENT.md) for full details.

### Scripts

| Script | Description |
|---|---|
| `./scripts/tag-release.sh [patch\|minor\|major\|beta\|x.y.z\|x.y.z beta]` | Create and push a release/beta tag |
| `./scripts/update-version.sh <version> <deploy_repo>` | Batch version update + xcframework copy (CI use) |

## License

MIT License. See [LICENSE](LICENSE) for details.

---

**Version**: 2.0.3
**Last updated**: 2026-05-12
