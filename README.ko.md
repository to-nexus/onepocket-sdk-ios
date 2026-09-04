# ONEpocket iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> English documentation: [README.md](README.md)

ONEpocket iOS SDK는 OAuth 기반 인증과 Embedded Wallet 기능을 제공하는 Swift SDK입니다.

## 특징

- **OAuth 기반 인증** — 간편한 소셜 로그인 (Google, Apple 등)
- **Embedded Wallet** — 사용자가 Private Key를 직접 관리하지 않는 지갑
- **EVM 호환** — CAIP-2 기반 체인 식별 (예: `eip155:612055`)
- **트랜잭션 컨펌 다이얼로그** — 서명/전송 전 사용자 승인 필수 (우회 불가)
- **안전한 저장소** — iOS Keychain을 사용한 데이터 저장
- **네이티브 OAuth** — `ASWebAuthenticationSession` 사용
- **세션 복원** — 앱 재시작 시 자동 로그인
- **생체 인증** — Face ID / Touch ID 기반 지갑 잠금 해제
- **테마 커스터마이징** — 라이트/다크 모드 및 색상 토큰 오버라이드
- **다국어(i18n) 지원** — 영어(기본), 한국어 — `.lproj` 추가만으로 새 언어 확장 가능
- **Clean Architecture** — 테스트 가능하고 유지보수하기 쉬운 구조
- **Swift Concurrency** — async/await 완전 지원
- **외부 의존성 없음** — 순수 Swift/Foundation 구현

## 요구사항

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## 지원 네트워크

### Cross 네트워크
- **ONEchain Mainnet** (eip155:612055) — 프로덕션 환경
- **ONEchain Testnet** (eip155:612044) — 개발/테스트 환경 (기본값)

### 기타 EVM 체인
- Ethereum Mainnet, Sepolia
- Polygon Mainnet, Amoy
- BNB Smart Chain Mainnet, Testnet

## 설치

### Swift Package Manager

#### Xcode에서 설치

1. Xcode에서 프로젝트 열기
2. **File → Add Packages…** 선택
3. 배포 레포 URL 입력:
   ```
   https://github.com/to-nexus/onepocket-sdk-ios
   ```
4. 버전 규칙 선택 후 패키지 추가

#### Package.swift에 추가

```swift
dependencies: [
    .package(url: "https://github.com/to-nexus/onepocket-sdk-ios", from: "2.0.0")
]
```

## 빠른 시작

### 1. SDK 초기화

```swift
import CROSSxCoreSDK

let sdk = try CROSSxSDK(config: SDKConfig(
    projectId: "your-project-id",
    appName: "Your App Name"
))

// 세션 복원 (저장된 토큰이 있으면 자동 로그인)
try await sdk.initialize()
```

#### Info.plist / xcconfig 기반 초기화

```swift
let sdk = try CROSSxSDK(config: try SDKConfig.fromInfoPlist(
    projectId: "your-project-id",
    appName: "Your App Name"
))
```

### 2. Custom URL Scheme 설정

SDK는 `projectId` 기반으로 URL Scheme을 자동 생성합니다: `crossx-{projectId}`

`Info.plist`에 해당 scheme을 등록하세요:

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

`AppDelegate` 또는 `SceneDelegate`에서 콜백 URL을 처리하세요:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return sdk.handleURL(url)
}
```

### 3. 로그인

```swift
let result = try await sdk.signIn()
if result.success {
    print("로그인 성공!")
    print("지갑 주소: \(result.walletAddress ?? "")")
}
```

로그인과 지갑 생성을 한 번에 처리하려면:

```swift
let result = try await sdk.signInWithCreate()
```

### 4. 지갑 생성 및 확인

```swift
// 지갑 생성 전 상태 확인
let status = try await sdk.checkWallet()

// 지갑 생성 (기존 백업이 있으면 자동 마이그레이션)
let wallet = try await sdk.createWallet()
print("주소: \(wallet.address)")
```

### 5. 사용자 정보 조회

```swift
let userInfo = try await sdk.getUserInfo()
print("이메일: \(userInfo.email ?? "")")
print("주소 목록: \(userInfo.addresses)")
```

### 6. CAIP-2 체인 식별

SDK는 체인을 내부적으로 관리하지 않습니다. 서명/전송 호출 시 CAIP-2 체인 ID를 직접 전달하세요.

```swift
let chainId = ChainId.crossMainnet    // "eip155:612055"
let chainId = ChainId.crossTestnet    // "eip155:612044"
let chainId = ChainId.ethereumMainnet // "eip155:1"
```

### 7. 트랜잭션 컨펌 다이얼로그

`signTransaction()`, `sendTransaction()`, `sendTransactionAndWait()` 호출 시 SDK가 자동으로 사용자 승인 다이얼로그를 표시합니다. DApp 개발자가 우회할 수 있는 공개 API는 없습니다.

```swift
do {
    let result = try await sdk.sendTransactionAndWait(tx, chainId: ChainId.crossTestnet)
    print("txHash: \(result.txHash)")
} catch let error as CROSSxError {
    if case .userRejected = error {
        print("사용자가 취소했습니다")
    }
}
```

### 8. 로그아웃

```swift
try await sdk.signOut()
```

## 추가 API

### 생체 인증

```swift
let available = sdk.canUseBiometric()
let enabled = sdk.isBiometricEnabled()
try await sdk.setBiometricEnabled(true)
```

### 토큰 갱신

```swift
let newAccessToken = try await sdk.refreshToken()
```

### 테마 커스터마이징

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

// 런타임에 테마 변경 (다음 모달부터 적용)
sdk.applyTheme(.dark)
```

## OAuth 플로우

```
iOS SDK → ASWebAuthenticationSession 열기
  URL: {oauthServiceUrl}/google?redirectScheme={callbackScheme}

OAuth 서버 → Deep Link로 콜백
  {callbackScheme}://{oauthHost}/?status=success&data={base64}

SDK → base64 디코딩 → 토큰 추출 → JWT 검증 → 완료
```

> Web에서는 `window.open()` + `postMessage` 방식을 사용합니다.

## 다국어(i18n) 지원

SDK는 `Bundle.module` 기반의 Apple 표준 `.strings` 리소스를 사용합니다.

| 언어 | 코드 | 상태 |
|------|------|------|
| English | `en` | 기본 언어 |
| 한국어 | `ko` | 지원 |

앱/시스템 언어와 관계없이 SDK UI 언어를 고정하려면 `SDKConfig`에 `locale`을 지정하세요.

```swift
let sdk = try CROSSxSDK(config: SDKConfig(
    projectId: "your-project-id",
    appName: "Your App Name",
    locale: .ko // 또는 .en
))
```

`locale`을 생략하거나 `nil`로 두면 Apple 표준 localization fallback 규칙을 따릅니다.

## 예제 앱

```bash
cd Examples/CROSSxSample
tuist install
tuist generate
open CROSSxSample.xcworkspace
```

자세한 내용은 [Examples/CROSSxSample/README.md](Examples/CROSSxSample/README.md)를 참고하세요.

## 릴리즈

- 변경 이력: [CHANGELOG.md](CHANGELOG.md)
- 전체 릴리즈: [GitHub Releases](https://github.com/to-nexus/onepocket-sdk-ios/releases)

베타 버전은 GitHub prerelease 로 배포되며 latest release 로 지정되지 않습니다. Swift Package Manager 와 CocoaPods 모두 정확한 버전을 지정해 설치하세요.

## 라이선스

MIT License. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

---

**버전**: 2.4.0
**최종 수정일**: 2026-09-04
