# Changelog

## [Unreleased]

## [2.5.1] - 2026-11-06

이행점검(2026-10-15) 잔존 Medium 3건 조치, SkipConfirm PIN 폴백, 니모닉·개인키 조회 PIN 강제 옵션.

### Security
- 로그아웃 뒤 완료된 토큰 갱신이 세션을 다시 설치하던 문제 (M-NEW-006) — 갱신은 시작 시점의
  세션 세대에 묶이고, 응답 도착 시 세션이 바뀌었으면 메모리·Keychain에 설치하지 않고
  `CancellationError`로 끝난다(세션 만료 `sessionExpired`와 구분). 같은 Keychain service·
  accessGroup을 쓰는 SDK 인스턴스끼리 로그아웃 세대를 공유한다
- 생체 등록 변경 후 기존 PIN 캐시가 열리던 문제 (M-NEW-007) — 생체 보호 PIN을
  `biometryCurrentSet`으로 저장. 이전 버전의 `biometryAny` 캐시는 사용하지 않고 삭제하므로
  **업데이트 후 생체 사용자는 PIN을 한 번 다시 입력**해야 한다. 다시 입력한 PIN은 생체 보호로 저장한다
- 생체 잠금 등 일시 불가 시 PIN 캐시가 생체 보호 없이 재저장되던 문제 (M-NEW-008) —
  잠금과 미등록을 구분하고, 생체 보호를 원하는데 지금 쓸 수 없으면 보호 없이 저장하지 않는다
  (`PasswordStoreError.biometryUnavailable`, 기존 캐시는 유지). 생체 보호를 원하는 등록 기기에
  남은 보호 없는 캐시도 사용하지 않는다. 미등록 기기의 일반 저장, `useBiometric: false` 저장은 그대로

### Added
- `StoragePort.sessionScopeID` (기본 구현 `nil`) — 같은 저장 영역을 쓰는 인스턴스 식별
- `PasswordStoreError.biometryUnavailable`
- Private SDK `getMnemonic(requirePin:)`, `getPrivateKey(index:requirePin:)` — `requirePin: true`면
  Keychain(생체 인증) PIN을 쓰지 않고 항상 Enter PIN 모달을 표시하며, 입력한 PIN은 Keychain에 저장하지 않는다.
  기본값 `false`라 기존 호출 동작은 같다

### Changed
- `setBiometricEnabled(true)`가 생체 잠금 중이면 `ONEpocketError.biometricFailed`를 던진다
- Private SDK `*SkipConfirm`: PIN 캐시가 없거나(미저장·보호 정책으로 폐기·생체 실패/취소) 캐시된 PIN이
  서버에서 불일치로 거부되면 `userReject`/`passwordWrong`으로 끝내지 않고 Enter PIN 모달로 같은 작업을
  계속한다. 불일치한 캐시는 삭제하고 성공한 PIN을 다시 캐시한다. 확인 UI는 여전히 표시하지 않으며,
  prepare는 PIN 시도마다 새로 한다

### Fixed
- 캐시된 PIN이 `passwordLocked`로 거부되면 캐시를 지우지 않아, 잠금이 풀린 뒤에도 같은 틀린 PIN으로
  시도 횟수를 계속 소모하던 문제 — 항상 캐시를 지운다. 잔여 시도가 남았으면(미잠금) `passwordWrong`과
  같이 Enter PIN 모달로 넘어가고, 잠겼으면 `passwordLocked`를 그대로 던진다 (공개·Private SDK 공통)
- SkipConfirm 트랜잭션에서 PIN 재입력마다 가스·nonce RPC를 다시 조회하지 않는다 (prepare만 시도마다)

## [2.5.0] - 2026-09-15

ONEpocket 리브랜딩을 위한 신규 Swift API를 추가하고 기존 CROSSx API를 deprecated 호환 alias로 유지합니다.

### Added
- `ONEpocketSDK`, `ONEpocketSDKContext`, `ONEpocketOAuthAdapter`
- `ONEpocketPrivateSDK`
- `ONEpocketError`

### Deprecated
- `CROSSxSDK`, `CROSSxSDKContext`, `CROSSxOAuthAdapter`
- `CROSSxPrivateSDK`
- `CROSSxError`

기존 API 시그니처와 에러 case는 변경되지 않으며 신규 코드에서는 ONEpocket 타입을 사용합니다.
모듈명(`import CROSSxCoreSDK`)·URL scheme(`crossx-*`)·Keychain 저장 키와 서비스 이름은
사용자 기기와 OAuth 화이트리스트에 이미 등록돼 있어 의도적으로 유지합니다.

### Fixed
- 4xx/5xx 응답 바디를 `NetworkError`에 보존 — 게이트웨이는 헤더 누락·화이트리스트 문제를
  HTTP 200 + 음수 code로 반환하므로 단말에서 보이는 실제 4xx는 CloudFront geo restriction·WAF
  처럼 엣지에서 잘린 경우다. 기존에는 상태 코드만 남기고 바디를 버려 원인을 알 수 없었다.
  `responseBody`로 원문 노출(HTML은 태그 제거 후 200자 제한), 기본값 `nil`이라
  기존 호출부·패턴 매칭 영향 없음
- `BrandCompatibilityTests`가 버전 리터럴을 직접 비교해 릴리즈 bump마다 실패하던 문제

### Changed
- `update-version.sh` / `tag-release.sh`가 개명된 `ONEpocketSDK.swift`를 탐색하도록 수정
  (구 경로 폴백 유지, 후보가 없으면 조용히 넘어가지 않고 실패)

## [2.4.0] - 2026-08-18

PIN 종단 암호화(E2E) 적용 및 ONEwallet → ONEpocket 브랜드 정리.

PIN을 더 이상 평문으로 전송하지 않습니다.

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
- 브랜드명·아이콘 에셋 ONEwallet → ONEpocket (SDK 로컬라이즈 문구·샘플 앱·프리뷰 픽스처)
- OAuth 도메인을 ONEwallet 기준으로 변경, 샘플 Dev 환경 전환 (CRS-11257)
- Import from Social Backup 문구 변경 (CRS-12120)
- 로그인 약관·개인정보처리방침 URL을 앱 기준으로 변경 (CRS-12207)
- 마이그레이션 화면 아이콘을 ONE Wallet 지갑 아이콘으로 통일
- onepocket-sdk-ios 배포 레포로 릴리즈 미러링 (CI)

### Fixed
- `L10n.currentLocale` 누락으로 `swift build`가 실패하던 문제
- 다크모드에서 애플 로고가 검정으로 표시되던 문제

## [2.3.2] - 2026-07-15

CROSSx → ONEwallet 리브랜딩.

### Changed
- SDK 네이밍·표기를 ONEwallet 기준으로 변경 (CRS-10597)
- Chain명 변경 (CRS-11257)
- Approve 버튼명 변경 (CRS-10448)

### Fixed
- 빌드 실패 수정

## [2.2.0] - 2026-05-18

### Added
- Tx History 인터페이스 (CRS-9071) — 신규 API Spec 적용 및 tx 적재 API 변경
- OAuth 요청에 언어 query 추가 (CRS-9462)
- locale sync 및 docs sync rule (CRS-9460, CRS-9439)

### Changed
- `CROSSxCoreSDK`를 dynamic framework로 빌드
- `tag-release.sh`에 소비자 빌드 검증 단계 추가, 검증 후 `build/` xcframework 보존
- CROSSxSampleXCFramework Tuist 프로젝트 추가

### Fixed
- 리소스 번들 위치를 잘못 찾던 문제
- `defaultLocalization` 누락으로 번역이 적용되지 않던 문제
- 샘플 앱 이름이 SDK config에 전달되지 않던 문제
- wallet v2 endpoint를 staging과 정렬

## [2.0.4] - 2026-05-12

### Added
- 로케일을 SDK 외부에서 설정 가능하도록 변경

### Fixed
- 바이너리 릴리즈에 `CROSSxCoreSDK` 리소스가 누락되던 문제
- 바이너리 패키지 `defaultLocalization` 미지정
- 지갑 선택기 동기화 문구

### Changed
- 릴리즈 자동화 스크립트 정비 및 SDK 로케일 설정 문서화

## [2.0.3] - 2026-04-27

### Fixed
- 토큰 만료 → 만료 팝업 → 재로그인 시 다른 계정으로 로그인되던 문제 (CRS-9039)

## [2.0.2] - 2026-04-23

### Fixed
- 과도한 방어 로직(ACL self-heal)으로 인한 사이드 이펙트 제거 (CRS-8788)

## [2.0.1] - 2026-04-22

### Removed
- `setBiometricReuseDuration`

### Fixed
- 세션 만료 시 생체 인증이 3회 발생하던 문제 (CRS-8788)
- `signInWithJWT` PIN 캐시 클리어 변경을 되돌림 (1.4.2에서 도입)

## [2.0.0] - 2026-04-21

### Added
- internal SDK에서 Confirm 창을 skip하는 인터페이스 (CRS-8788)

## [1.4.2] - 2026-04-20

### Changed
- `JWTSignInUseCase`를 Firebase IdToken 기반 로그인으로 전환

### Fixed
- `signInWithJWT` 시 이전 세션 PIN 캐시 클리어

## [1.4.1] - 2026-04-16

### Added
- 지갑 portrait

## [1.4.0] - 2026-04-10

### Added
- `setAddressNames` 인터페이스

### Changed
- refresh API path를 `refresh` → `refresh/simple`로 변경

## [1.3.13] - 2026-04-17

1.4.x 와는 별개 계보의 유지보수 릴리즈입니다. (1.3.14는 버전 상수 bump만 포함)

### Changed
- `JWTSignInUseCase`를 Firebase IdToken 기반 로그인으로 전환

### Fixed
- `signInWithJWT` 시 이전 세션 PIN 캐시 클리어

## [1.3.12] - 2026-04-08

### Added
- 요청/응답 로깅

### Fixed
- API 에러 메시지가 누락되던 문제

## [1.3.11] - 2026-04-08

### Changed
- PIN 잠금 해제 시각에 초 단위 표시

## [1.3.10] - 2026-04-07

### Fixed
- 6자리 PIN 입력 실패 시 시도 횟수·잠금 정보가 표시되지 않던 문제
- `biometricFailed` 시 PIN 모달로 graceful fallback
- Withdraw 시 SessionExpired 오류

## [1.3.9] - 2026-04-07

### Fixed
- `savePassword` 기본 호출 시 기존 생체 설정이 덮어써지던 문제

## [1.3.8] - 2026-04-07

### Fixed
- dismiss 시 `UIHostingController`를 먼저 분리해 RN Yoga ↔ AutoLayout 무한 루프 방지

## [1.3.7] - 2026-04-07

### Changed
- 토큰·인증 실패를 `sessionExpired`로 통일하고 생체 설정 정리

### Fixed
- PIN 로딩 인디케이터 및 모달 레이아웃 높이 안정화
- `ModalController` dismiss 타이밍 및 PIN 시트 즉시 닫기

## [1.3.6] - 2026-04-06

### Added
- SignInAgain UseCase 및 API (CRS-8405)

## [1.3.5] - 2026-04-06

### Added
- 커스텀 숫자 키패드

### Changed
- PIN 잠금 표시 개선 및 모달 dismiss 타이밍 변경

### Fixed
- refresh token 만료 시 `sessionExpired` 반환 (CRS-8405)

## [1.3.4] - 2026-04-06

### Fixed
- iOS 18+ PIN 모달 dismiss 시 CPU 100% 점유 및 `userReject` 미전달

## [1.3.3] - 2026-04-06

### Fixed
- Google / Apple 로그인 반복 시 pending 되던 현상 (CRS-8392)

## [1.3.2] - 2026-04-03

### Changed
- `passwordCancelled` → `userReject`로 이름 변경

### Fixed
- PIN 잠금 시간 표시에 초 단위 추가 (HH:mm → HH:mm:ss) (CRS-8375)
- Apple 딥링크 콜백에서 Firebase ID Token을 올바르게 식별

## [1.3.1] - 2026-04-03

### Added
- 마이그레이션 시 다중 주소 생성을 위한 `maxIndex` 파라미터

### Removed
- `migrationSkipped` — 마이그레이션 skip은 `userRejected`를 사용

## [1.3.0] - 2026-04-01

### Added
- JWKS `kid` 불일치 시 키 로테이션 fallback

### Changed
- `CROSSxError` 모델을 Android SDK 에러 스펙과 정렬
- `SdkErrorMapper`로 백엔드 에러 매핑 일원화

## [1.2.9] - 2026-04-01

### Added
- `changePassword`, `exportMnemonic`, `exportPrivateKey` API
- 에러 코드 `-10032`, `PinLockInfo` / `VerifyPasswordResponse` 갱신

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

## [1.2.0] - 2026-03-24

### Added
- `signInWithJWT()` — JWT 직접 로그인 및 만료된 access token 자동 갱신
- `savePin` / `setBiometricEnabled`, `biometricFailed` 에러 처리
- nonce claim 및 `sha256` 지원 (Core ports·types, adapters)

### Changed
- PIN UI·서명 트랜잭션 팝업 재설계 및 PIN 검증 강화
- `verifyPin` → `verifyRecoveryPin`으로 이름 변경

### Fixed
- 모달 연속 표시 시 race condition
- `withPasswordRetry`에서 operation 에러가 PIN 모달로 잘못 fallback 되던 문제
- non-iOS 빌드 및 XCFramework 빌드 오류

## [1.1.1] - 2026-03-23

### Added
- `checkWallet()` 공개 API

## [1.1.0] - 2026-03-20

비밀번호 시스템 도입 및 `CROSSxPrivateSDK` 신설.

### Added
- `CROSSxPrivateSDK` — 니모닉/개인키 조회, 비밀번호 변경, 탈퇴
- 비밀번호 시스템 (`PasswordStorePort`, `KeychainPasswordStoreAdapter`, `PasswordPresenter`) 및 동의 화면
- `POST /mnemonic/verify-pin` API, mnemonic/migrate PIN 시도 횟수 제한(`-10027`)
- `createWallet`에 `migrateAutomatically` 옵션

### Changed
- 마이그레이션 플로우 개선 (verifyPin → 비밀번호 설정 → migrate)
- 탈퇴 API를 `CROSSxPrivateSDK` 전용으로 제한
- embedded-wallet-gateway API 변경 반영
- Figma 컬러 토큰 적용

### Fixed
- withdraw 비밀번호 모달을 API 호출 중에도 유지하고 오류를 인라인 표시

## [1.0.1] - 2026-03-13

### Added
- SDK 다국어(i18n) 지원 인프라
- `selectWallet()` API 및 지갑 선택 모달 (`currentAddress` 파라미터, selected 배지)

### Changed
- `CrossWebAuthKit`을 독립 하위 패키지로 분리 (iOS 13 지원)
- `getUserInfo` 응답 구조 개선 및 OAuth state CSRF 방어 강화
- 내부 로그·메시지 한국어 → 영어 전환
- `scripts/tag-release.sh` 도입 — 태그 push 전 `swift build` · `swift test` 자동 실행

## [1.0.0] - 2026-03-09

최초 공개 릴리즈. OAuth 인증과 Embedded Wallet 기능을 제공합니다.

### Added
- `ChainMeta` 통합 모델 및 TTL 기반 체인 캐시

### Changed
- Gateway RPC 프록시를 직접 RPC 호출로 전환
- 블록체인 숫자 처리를 `UInt64` → `Decimal`로 전환해 오버플로우 방지

### Fixed
- 로그인 시트의 Terms/Privacy 링크를 외부 브라우저로 열도록 변경

