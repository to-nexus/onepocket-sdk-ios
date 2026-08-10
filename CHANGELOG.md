# Changelog

## [Unreleased]

PIN 종단 암호화(E2E) 적용 — PIN을 더 이상 평문으로 전송하지 않습니다.

### Added
- `PinEncryptorPort` / `PinEncryptionAdapter` — `GET /api/v1/pin-key` 공개키 조회(5분 캐시) 및
  `"<keyVersion>.<base64url(ciphertext)>"` 봉투 생성
- `RSAOAEPEncryptor` — RSA-OAEP-SHA256(MGF1-SHA256, 빈 label) 암호화 및 SPKI → PKCS#1 공개키 변환
- `CROSSxError.invalidEncryptedPin`(-10045), `.pinPolicyViolation`(-10046), `.pinEncryptionFailed`

### Changed
- `password` / `newPassword` / `recoveryPin`을 포함하는 모든 Gateway 요청이 암호화된 PIN을 전송
  (HMAC은 암호문이 포함된 최종 body 기준으로 계산)
- `-10045` 수신 시 공개키 캐시 무효화 후 1회 자동 재시도 (키 로테이션 대응)
- PIN 모달이 `-10046`을 인라인 정책 안내로 표시 (모달 유지)
- 공개 SDK API 시그니처는 변경 없음 — 호출자는 평문 PIN을 그대로 전달

### Fixed
- `L10n.currentLocale` 누락으로 `swift build`가 실패하던 문제

## [1.2.8] - 2026-03-30

보안 평가 리포트 기반 취약점 수정 및 JWKS 기반 JWT 서명 검증 구현.

### Security Fixes (P0–P3)
- **IOS-001**: `encrypt`/`decrypt`에 AES-GCM 실제 구현 추가
- **IOS-002**: JWT 구조 검증 강화 (sub/iss claim 유효성 검사) 및 JWKS 기반 서명 검증 구현 (graceful degradation)
- **IOS-005**: HMAC 키를 Keychain(StoragePort) 저장으로 전환
- **IOS-007**: 로그에서 email·state·provider PII 리다크션
- **IOS-010/011**: TokenStore 만료 처리 개선 및 세션 복원 시 JWT exp claim 파싱
- **IOS-012**: chainId path traversal 방어를 위한 형식 검증 추가
- **IOS-013/REVIEW-005**: NetworkError에서 서버 응답 본문 제거
- **IOS-015**: SignOut 시 Share-C 삭제 키 수정
- **IOS-016**: getMnemonic/getPrivateKey에 HMAC 서명 추가
- **IOS-017**: base64Decode의 위험한 UTF-8 fallback 제거
- **IOS-018**: Keychain accessibility를 `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`로 강화
- **IOS-019**: PIN 재시도 시 2초 클라이언트 측 지연 추가
- **IOS-020**: `Log.isEnabled`를 NSLock 기반 thread-safe 접근으로 변경
- **IOS-021**: HMACKeyHolder `@unchecked Sendable` thread-safety 문서화
- **IOS-022**: BSC RPC URL에서 API 키(hex 접미사) 제거

### Added
- `JWK`, `JWKSet` 타입 (RFC 7517) — JWKS 기반 JWT 서명 검증 지원
- RS256 (`SecKeyVerifySignature`) / ES256 (`CryptoKit P256`) 서명 검증
- JWKS lazy fetch 및 메모리 캐싱

## [1.2.7] - 2026-03-30

`CROSSxPrivateSDK.changePassword`를 UI 포함/미포함 두 가지 타입으로 분리.

### Added
- `CROSSxPrivateSDK.changePassword(password:newPassword:)` — UI 없이 호출자가 비밀번호를 직접 전달하는 비밀번호 변경 API

### Changed
- 기존 `changePassword()` (파라미터 없음)는 그대로 PIN 팝업 UI를 표시하는 방식으로 유지

## [1.2.6] - 2026-03-27

`getUserInfo()`에 OAuth 제공자 고유 식별자(providerSub) 노출.

### Added
- `SDKUserInfoData.providerSub` — Google/Apple OAuth subject identifier 필드 추가
- `SDKUserInfo.providerSub` — 편의 접근자 추가

## [1.2.5] - 2026-03-27

민감 API에 HMAC 서명 미들웨어 추가, Share-C 기반 지갑 복구 API 신규, Create/Migrate 응답 변경.

### Added
- `POST /mnemonic/recover` — Share-C 기반 지갑 복구 API (`CROSSxPrivateSDK.recoverWallet(shareC:)`)
- HMAC-SHA256 서명 미들웨어 — `withdraw`, `recover`, `share-c`, `change-password` API에 `X-HMAC-Signature` 헤더 자동 포함
- `CROSSxPrivateSDK.init(sdk:hmacKey:)` — HMAC 키를 Private SDK 초기화 시 설정
- `HMACKeyHolder` — thread-safe HMAC 키 공유 홀더
- `CROSSxError.hmacSignatureMissing`, `.hmacSignatureInvalid`, `.hmacKeyNotConfigured` 에러 코드

### Changed
- `CreateWalletResponse`에서 `shareC` 필드 제거 (별도 `POST /mnemonic/share-c` 호출 필요)
- `MigrateWalletResponse`에서 `shareC` 필드 제거
- `SDKConfig`에서 `hmacKey` 제거 — Private SDK 전용으로 이동

### Breaking Changes
- `CROSSxPrivateSDK.init(sdk:)` → `CROSSxPrivateSDK.init(sdk:hmacKey:)` (hmacKey 파라미터 필수)
- `CreateWalletResponse.shareC`, `MigrateWalletResponse.shareC` 제거

## [1.2.4] - 2026-03-27

Android SDK API 통일을 위한 리네이밍 및 신규 API 추가.

### Added
- `signInWithCreate(provider:)` — 로그인 + 지갑 생성 원스텝 API
- `refreshToken()` — Access Token 수동 갱신 API
- `walletRpc(request:chainId:)` — 범용 JSON-RPC 호출 API
- `waitForTxAndGetReceipt(txHash:chainId:timeoutMs:pollIntervalMs:)` — Android 호환 Receipt 폴링
- `sendTransactionWithWaitForReceipt(...)` — Android 호환 전송 + Receipt 폴링
- `createWallet(migrateAutomatically:)` — 자동 마이그레이션 제어 파라미터 추가
- `SDKUserInfo.loginType` — 로그인 타입 필드
- `SDKUserInfo.addresses` — 지갑 주소 목록 필드
- `SDKUserInfo` 편의 접근자: `id`, `email`, `provider`, `accessToken`, `idToken`, `sub`
- `canUseBiometric()` — 기기 생체 인증 가용 여부 확인
- `isBiometricEnabled()` — 생체 인증 활성화 여부 확인
- `setBiometricEnabled(_:)` — 생체 인증 활성화/비활성화

### Changed
- `LoginProvider` → `SDKSignInProvider` 리네이밍
- `CROSSxTheme` → `SDKThemeMode` 리네이밍
- `CROSSxThemeConfig` → `SDKThemeTokens` 리네이밍
- `CROSSxThemeTokens` → `SDKColorOverrides` 리네이밍
- `PasswordStorePort`에 `isBiometricAvailable()`, `isBiometricEnabled()` 프로토콜 메서드 추가 (기본 구현 제공)

## [1.2.3] - 2026-03-26

- fix: track Derived/ files for CI build

## [1.2.2] - 2026-03-25

- fix: auto-generate TuistBundle+CROSSxCoreSDK.swift in CI

## [1.2.1] - 2026-03-24

- feat: add sessionExpired error for token/refresh expiry
