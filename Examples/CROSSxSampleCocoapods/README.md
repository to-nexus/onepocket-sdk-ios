# CROSSx SDK CocoaPods Sample App

A sample application demonstrating how to integrate the CROSSx iOS SDK using CocoaPods.

## Requirements

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+
- [CocoaPods](https://cocoapods.org/) installed

## Installing CocoaPods

```bash
sudo gem install cocoapods
```

Or install via Homebrew:

```bash
brew install cocoapods
```

## Project Setup

### 1. Create the Xcode Project

Use the setup script which leverages the `xcodeproj` Ruby gem (auto-installed as a CocoaPods dependency):

```bash
cd Examples/CROSSxSampleCocoapods
ruby setup.rb
```

### 2. Install Pods

```bash
pod install
```

### 3. Open the Workspace

```bash
open CROSSxSampleCocoapods.xcworkspace
```

> **Note**: Always open the **`.xcworkspace`** file, not `.xcodeproj`.

## Running the App

1. Select the `CROSSxSampleCocoapods` target in Xcode
2. Choose a simulator or a physical device
3. Press `Cmd + R` or click the Run button

## Features

The sample app demonstrates the following features:

| Feature | API |
|---------|-----|
| SDK Initialization | `SDKConfig.fromInfoPlist(projectId:appName:)` |
| Session Restore | `sdk.initialize()` |
| OAuth Sign-In | `sdk.signIn()` |
| Sign Out | `sdk.signOut()` |
| Create Wallet | `sdk.createWallet()` |
| Query Wallet | `sdk.getAddresses()`, `sdk.getBalance()` |
| Sign Transaction | `sdk.signTransaction()` |
| Sign Message | `sdk.signMessage()`, `sdk.signTypedData()` |
| ERC20 Transfer | `sdk.sendTransactionAndWait()` |
| Native Transfer | `sdk.sendTransactionAndWait()` |

## Podfile

```ruby
platform :ios, '15.0'

target 'CROSSxSampleCocoapods' do
  use_frameworks!

  pod 'CrossWebAuthKit', :path => '../../'
  pod 'CROSSxSDK', :path => '../../'
end
```

For production projects, specify a version instead of `:path`:

```ruby
pod 'CROSSxSDK', '~> 2.0'
```

## Configuration

### Project ID

Set your Project ID in `Configurations/Debug.xcconfig`:

```
CROSSX_PROJECT_ID = your-project-id
```

### Environment (Staging vs Production)

| Configuration | Environment | Description |
|---------------|-------------|-------------|
| Debug | Staging | For development/testing; URLs set explicitly |
| Release | Production | Uses production URLs by default when unset |

## Directory Structure

```
CROSSxSampleCocoapods/
├── Podfile                       # CocoaPods dependency definitions
├── setup.rb                      # Xcode project generation script
├── README.md
├── Configurations/
│   ├── Debug.xcconfig            # Staging environment config
│   └── Release.xcconfig          # Production environment config
├── Sources/
│   ├── AppDelegate.swift         # App entry point, URL handling
│   └── MainViewController.swift  # SDK usage example UI
└── Resources/
    ├── Info.plist                # URL Scheme, SDK configuration
    └── LaunchScreen.storyboard
```

## Custom URL Scheme

The following URL scheme is configured in Info.plist for OAuth callbacks:

- `crossx-{PROJECT_ID}://`

## Troubleshooting

### Pod Install Fails

```bash
pod repo update
pod install
```

### Build Errors

1. Make sure you opened the `.xcworkspace` file
2. Clean Derived Data and rebuild:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Reinstall pods:
   ```bash
   pod deintegrate
   ruby setup.rb
   pod install
   ```

## References

- [CROSSx SDK README](../../README.md)

---

**Version**: 2.0.3
**Last updated**: 2026-05-12
