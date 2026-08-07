# CROSSx SDK Sample App

A sample application demonstrating how to use the CROSSx iOS SDK.

## Requirements

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+
- [Tuist](https://tuist.io) installed

## Installing Tuist

```bash
brew install --cask tuist
```

Or via the official installer:

```bash
curl -Ls https://install.tuist.io | bash
```

## Project Setup

Generate the Xcode project using Tuist:

```bash
cd Examples/CROSSxSample
tuist install
tuist generate
```

This will:
1. Install SPM dependencies
2. Generate the Xcode project
3. Create `CROSSxSample.xcodeproj` and `CROSSxSample.xcworkspace`

## Open the Project

```bash
open CROSSxSample.xcworkspace
```

> Always open `.xcworkspace`, not `.xcodeproj`.

## Running the App

1. Select the `CROSSxSample` target in Xcode
2. Choose a simulator or physical device
3. Press `Cmd + R` or click the Run button

## Features

| Feature | API |
|---------|-----|
| SDK Initialization | `SDKConfig.fromInfoPlist(projectId:appName:)` |
| Session Restore | `sdk.initialize()` |
| OAuth Sign-In | `sdk.signIn()` |
| Sign Out | `sdk.signOut()` |
| Get User Info | `sdk.getUserInfo()` |
| Create Wallet | `sdk.createWallet()` |
| Select Wallet | `sdk.selectWallet()` |
| Query Balance | `sdk.getBalance()` |
| Sign Transaction | `sdk.signTransaction()` |
| Sign Message | `sdk.signMessage()` |
| Sign Typed Data V4 | `sdk.signTypedData()` |
| ERC20 Transfer | `sdk.sendTransactionAndWait()` |
| Native Coin Transfer | `sdk.sendTransactionAndWait()` |
| Verify Password | `sdk.verifyPassword()` |

## Configuration

### Project ID (Required)

Set your Project ID in `Configurations/Debug.xcconfig`:

```
CROSSX_PROJECT_ID = your-project-id
```

> The app will crash at startup if this is not set.

### Environment (Staging vs Production)

| Configuration | Environment | Notes |
|---|---|---|
| Debug | Staging | Explicit staging URLs set |
| Release | Production | URLs auto-default to production when unset |

`Configurations/Debug.xcconfig`:
```
CROSSX_OAUTH_SERVICE_URL = https://stg-cross-wallet-oauth.crosstoken.io
CROSSX_API_BASE_URL = https://stg-cross-auth.crosstoken.io
CROSSX_WALLET_API_BASE_URL = https://stg-embedded-wallet-gateway.crosstoken.io/api/v1
CROSSX_WALLET_V2_BASE_URL = https://stg-wallet-server.crosstoken.io/api/v2
CROSSX_CLIENT_ID = your-client-id
```

`Configurations/Release.xcconfig`:
```
CROSSX_PROJECT_ID = your-project-id
```

## Directory Structure

```
CROSSxSample/
├── Project.swift                  # Tuist project definition
├── Tuist.swift                    # Tuist configuration
├── Configurations/
│   ├── Debug.xcconfig             # Staging environment
│   └── Release.xcconfig           # Production environment
└── CROSSxSample/
    ├── Sources/
    │   ├── AppDelegate.swift      # URL callback handling
    │   └── MainViewController.swift  # SDK usage examples
    ├── Resources/
    │   └── LaunchScreen.storyboard
    └── Tests/
```

## Troubleshooting

**`tuist generate` fails:**
```bash
tuist clean
tuist install
tuist generate
```

> Run all Tuist commands from inside the `Examples/CROSSxSample` directory, not from the repo root.

**Build errors:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
cd Examples/CROSSxSample
tuist clean && tuist generate
```

## References

- [CROSSx SDK README](../../README.md)
- [Tuist Documentation](https://docs.tuist.io)

---

**Version**: 2.2.0-beta.4
**Last updated**: 2026-05-13
