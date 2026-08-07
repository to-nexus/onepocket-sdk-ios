import UIKit
import CROSSxCoreSDK

class MainViewController: UIViewController {
    
    // MARK: - Properties
    private var sdk: CROSSxSDK?
    private var isSignedIn = false
    private var selectedWallet: WalletAddressInfo?
    
    // MARK: - Test Constants
    private let testRecipient = "0x920A31f0E48739C3FbB790D992b0690f7F5C42ea"
    private let testERC20Contract = "0x9f85c7b5d7637e18f946cc8af9c131318c6833d9"
    private let testChainId = "eip155:612044" // Cross Testnet (CAIP-2)
    private let testEvmChainId = "0x956CC" // Cross Testnet hex (612044)
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CROSSx SDK Sample"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Checking session..."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var signInButton = makeButton(title: "Sign In with OAuth", color: .systemBlue)
    private lazy var signOutButton = makeButton(title: "Sign Out", color: .systemRed)
    private lazy var getUserInfoButton = makeButton(title: "Get User Info", color: .systemGray, height: 44, fontSize: 16)
    
    private let walletInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var createWalletButton = makeButton(title: "Create Wallet", color: .systemGreen)
    private lazy var selectWalletButton = makeButton(title: "Select Wallet", color: .systemCyan, height: 44, fontSize: 16)

    private let selectedWalletLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // Wallet Action Buttons
    private let walletActionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    private lazy var signTxButton = makeButton(title: "Sign Transaction", color: .systemIndigo, height: 44, fontSize: 16)
    private lazy var signMessageButton = makeButton(title: "Sign Message", color: .systemOrange, height: 44, fontSize: 16)
    private lazy var signTypedDataButton = makeButton(title: "Sign Typed Data V4", color: .systemBrown, height: 44, fontSize: 16)
    private lazy var sendERC20Button = makeButton(title: "Send ERC20 Transfer", color: .systemPurple, height: 44, fontSize: 16)
    private lazy var sendNativeButton = makeButton(title: "Send Native Coin", color: .systemTeal, height: 44, fontSize: 16)
    private lazy var verifyPasswordButton = makeButton(title: "Verify Password", color: .systemPink, height: 44, fontSize: 16)
    
    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.text = ""
        return textView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        initializeSDK()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "CROSSx SDK"
        
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.addSubview(contentStack)
        
        signInButton.isEnabled = false
        signInButton.alpha = 0.5
        signOutButton.isEnabled = false
        signOutButton.alpha = 0.5
        createWalletButton.isHidden = true
        
        walletActionsStack.addArrangedSubview(selectWalletButton)
        walletActionsStack.addArrangedSubview(selectedWalletLabel)
        walletActionsStack.addArrangedSubview(signTxButton)
        walletActionsStack.addArrangedSubview(signMessageButton)
        walletActionsStack.addArrangedSubview(signTypedDataButton)
        walletActionsStack.addArrangedSubview(sendERC20Button)
        walletActionsStack.addArrangedSubview(sendNativeButton)
        walletActionsStack.addArrangedSubview(verifyPasswordButton)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        getUserInfoButton.isHidden = true

        for item: UIView in [titleLabel, statusLabel, userInfoLabel, signInButton, signOutButton, getUserInfoButton, spacer, walletInfoLabel, createWalletButton, walletActionsStack, logTextView] {
            contentStack.addArrangedSubview(item)
        }
        
        logTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        getUserInfoButton.addTarget(self, action: #selector(getUserInfoTapped), for: .touchUpInside)
        createWalletButton.addTarget(self, action: #selector(createWallet), for: .touchUpInside)
        selectWalletButton.addTarget(self, action: #selector(selectWalletTapped), for: .touchUpInside)
        signTxButton.addTarget(self, action: #selector(signTransactionTapped), for: .touchUpInside)
        signMessageButton.addTarget(self, action: #selector(signMessageTapped), for: .touchUpInside)
        signTypedDataButton.addTarget(self, action: #selector(signTypedDataTapped), for: .touchUpInside)
        sendERC20Button.addTarget(self, action: #selector(sendERC20Tapped), for: .touchUpInside)
        sendNativeButton.addTarget(self, action: #selector(sendNativeTapped), for: .touchUpInside)
        verifyPasswordButton.addTarget(self, action: #selector(verifyPasswordTapped), for: .touchUpInside)
    }
    
    private func makeButton(title: String, color: UIColor, height: CGFloat = 50, fontSize: CGFloat = 18) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .semibold)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }
    
    // MARK: - SDK Initialization
    private func initializeSDK() {
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("SDK 초기화 중...")
        activityIndicator.startAnimating()
        
        do {
            let config = try SDKConfig.fromInfoPlist(projectId: "6ef9a259932d5e77cb1751e9dfcbe031", appName: "CROSSxSample")
            sdk = try CROSSxSDK(config: config)
            AppDelegate.sdk = sdk
            
            log("Project: \(config.projectId)")
            log("Scheme: \(config.callbackScheme)")
        } catch {
            activityIndicator.stopAnimating()
            log("❌ SDK 초기화 실패: \(error.localizedDescription)")
            updateUI(signedIn: false, user: nil, wallet: nil)
            return
        }
        
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("")
        log("저장된 토큰 확인 중...")
        
        Task {
            do {
                let result = try await sdk?.initialize()
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    if let result = result, result.success {
                        updateUI(signedIn: true, user: result.user, wallet: result.walletAddress)
                        log("✅ 저장된 세션 발견 - 자동 로그인 완료")
                        log("  사용자: \(result.user?.email ?? result.user?.id ?? "N/A")")
                        log("  지갑: \(result.walletAddress ?? "N/A")")
                        log("")
                        self.checkWallet()
                    } else {
                        updateUI(signedIn: false, user: nil, wallet: nil)
                        log("ℹ️ 저장된 세션 없음 - 로그인 필요")
                    }
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    updateUI(signedIn: false, user: nil, wallet: nil)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("⚠️ 세션 복원 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Auth Actions
    @objc private func signIn() {
        guard let sdk = sdk else { return }
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("🔐 OAuth 로그인 시작...")
        setLoading(true)
        
        Task {
            do {
                let result = try await sdk.signIn()
                await MainActor.run {
                    setLoading(false)
                    if result.success {
                        updateUI(signedIn: true, user: result.user, wallet: result.walletAddress)
                        log("✅ 로그인 성공!")
                        log("  사용자: \(result.user?.email ?? result.user?.id ?? "N/A")")
                        log("  지갑: \(result.walletAddress ?? "N/A")")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        checkWallet()
                    }
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    signInButton.isEnabled = true
                    signInButton.alpha = 1.0
                    if handleSessionExpiredIfNeeded(error) { return }
                    if let oauthErr = error as? OAuthError, case .userCancelled = oauthErr {
                        log("ℹ️ 사용자가 로그인을 취소했습니다")
                    } else {
                        log("❌ 로그인 실패: \(error.localizedDescription)")
                    }
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
            }
        }
    }
    
    @objc private func signOut() {
        guard let sdk = sdk else { return }
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("🚪 로그아웃 중...")
        
        Task {
            do {
                try await sdk.signOut()
                await MainActor.run {
                    updateUI(signedIn: false, user: nil, wallet: nil)
                    hideWalletActions()
                    log("✅ 로그아웃 완료")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
            } catch {
                await MainActor.run {
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 로그아웃 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc private func getUserInfoTapped() {
        guard let sdk = sdk else { return }

        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("👤 사용자 정보 조회 중...")

        Task {
            do {
                let info = try await sdk.getUserInfo()
                await MainActor.run {
                    log("✅ 사용자 정보 조회 완료")
                    log("  email: \(info.data.email ?? "N/A")")
                    log("  provider: \(info.data.provider ?? "N/A")")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                    let message = """
                    email: \(info.data.email ?? "N/A")
                    provider: \(info.data.provider ?? "N/A")
                    status: \(info.status)
                    """
                    showAlert(title: "User Info", message: message)
                }
            } catch {
                await MainActor.run {
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 사용자 정보 조회 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }

    // MARK: - Wallet Check
    private func checkWallet() {
        guard let sdk = sdk else { return }
        
        log("💼 지갑 조회 중...")
        
        Task {
            do {
                let response = try await sdk.getAddresses()
                await MainActor.run {
                    if response.addresses.isEmpty {
                        walletInfoLabel.text = "⚠️ 지갑이 없습니다"
                        walletInfoLabel.isHidden = false
                        createWalletButton.isHidden = false
                        walletActionsStack.isHidden = true
                        selectedWallet = nil
                        log("ℹ️ 지갑 없음 - 생성 필요")
                    } else {
                        let first = response.addresses.first!
                        selectedWallet = first
                        let short = abbreviateAddress(first.address)
                        walletInfoLabel.text = "💼 Wallets: \(response.addresses.count)개"
                        walletInfoLabel.isHidden = false
                        createWalletButton.isHidden = true
                        updateSelectedWalletLabel()
                        showWalletActions()
                        log("✅ 지갑 확인: \(response.addresses.count)개")
                        for (i, info) in response.addresses.enumerated() {
                            log("  [\(i)] \(info.address)")
                        }
                        log("  → 선택: [\(first.index)] \(short)")
                    }
                }
                
                if let addr = self.selectedWallet?.address {
                    await self.fetchBalance(address: addr)
                }
            } catch {
                await MainActor.run {
                    if !handleSessionExpiredIfNeeded(error) {
                        walletInfoLabel.text = "⚠️ 지갑 조회 실패"
                        walletInfoLabel.isHidden = false
                        createWalletButton.isHidden = false
                        walletActionsStack.isHidden = true
                        log("⚠️ 지갑 조회 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func fetchBalance(address: String) async {
        guard let sdk = sdk else { return }
        
        let networkName = ChainId.networkName(for: testChainId)
        let currency = ChainId.nativeCurrencyFor(testChainId).symbol
        
        do {
            let hexBalance = try await sdk.getBalance(address: address, chainId: testChainId)
            let balanceText = Self.weiHexToEther(hexBalance)
            let short = abbreviateAddress(address)
            
            await MainActor.run {
                selectedWalletLabel.text = "▶ Selected: \(short)\n💰 \(balanceText) \(currency) (\(networkName))"
                selectedWalletLabel.isHidden = false
                log("💰 잔액: \(balanceText) \(currency) (\(networkName))")
            }
        } catch {
            await MainActor.run {
                if !handleSessionExpiredIfNeeded(error) {
                    log("⚠️ 잔액 조회 실패 (\(networkName)): \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// hex Wei → 소수점 Ether 문자열 (Decimal 사용으로 UInt64 오버플로우 방지)
    private static func weiHexToEther(_ hex: String) -> String {
        let cleaned = (hex.hasPrefix("0x") || hex.hasPrefix("0X"))
            ? String(hex.dropFirst(2))
            : hex
        guard !cleaned.isEmpty else { return "0" }

        var wei = Decimal(0)
        for char in cleaned {
            guard let digit = char.hexDigitValue else { return "0" }
            wei = wei * 16 + Decimal(digit)
        }

        let divisor = Decimal(sign: .plus, exponent: 18, significand: 1)
        let ether = wei / divisor

        let handler = NSDecimalNumberHandler(
            roundingMode: .down,
            scale: 6,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let rounded = (ether as NSDecimalNumber).rounding(accordingToBehavior: handler)

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""

        return formatter.string(from: rounded) ?? "0"
    }
    
    @objc private func createWallet() {
        guard let sdk = sdk else { return }
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("💼 지갑 생성 중...")
        createWalletButton.isEnabled = false
        createWalletButton.alpha = 0.5
        activityIndicator.startAnimating()
        
        Task {
            do {
                let response = try await sdk.createWallet()
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    selectedWallet = WalletAddressInfo(address: response.address, index: 0)
                    createWalletButton.isHidden = true
                    
                    walletInfoLabel.text = "💼 Wallets: 1개"
                    walletInfoLabel.isHidden = false
                    updateSelectedWalletLabel()
                    showWalletActions()
                    
                    log("✅ 지갑 생성 완료!")
                    log("  주소: \(response.address)")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    if !handleSessionExpiredIfNeeded(error) {
                        createWalletButton.isEnabled = true
                        createWalletButton.alpha = 1.0
                        log("❌ 지갑 생성 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Select Wallet
    @objc private func selectWalletTapped() {
        guard let sdk = sdk else { return }

        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("🔀 지갑 선택 모달 표시...")
        setWalletActionsEnabled(false)

        Task {
            do {
                let wallet = try await sdk.selectWallet(currentAddress: self.selectedWallet?.address)
                await MainActor.run {
                    setWalletActionsEnabled(true)
                    if let wallet {
                        selectedWallet = wallet
                        updateSelectedWalletLabel()
                        log("✅ 지갑 선택됨: [\(wallet.index)] \(abbreviateAddress(wallet.address))")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    } else {
                        log("ℹ️ 지갑 선택 취소")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
                if let addr = wallet?.address {
                    await fetchBalance(address: addr)
                }
            } catch {
                await MainActor.run {
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 지갑 선택 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    // MARK: - Transaction Actions
    
    @objc private func signTransactionTapped() {
        guard let sdk = sdk, let from = selectedWallet?.address else { return }
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("✍️ 트랜잭션 서명 시작...")
        setWalletActionsEnabled(false)
        activityIndicator.startAnimating()
        
        Task {
            do {
                let tx = UnsignedTransaction(
                    chainId: testEvmChainId,
                    from: from,
                    to: testRecipient,
                    value: "0x0",
                    data: "0x",
                    gasLimit: "0x5208",
                    gasPrice: "0xee6b2800",
                    maxFeePerGas: "0x77359400",
                    maxPriorityFeePerGas: "0x3b9aca00"
                )
                
                log("  To: \(testRecipient)")
                log("  Value: 0x0")
                log("  서명 중...")
                
                let response = try await sdk.signTransaction(tx, chainId: testChainId)
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    log("✅ 서명 완료!")
                    log("  TxHash: \(response.txHash ?? "N/A")")
                    log("  SignedTx: \(response.signedTx != nil ? "(truncated)" : "N/A")")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    showAlert(
                        title: "Sign Transaction",
                        message: "서명 완료\nTxHash: \(response.txHash ?? "N/A")"
                    )
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 서명 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    @objc private func signMessageTapped() {
        guard let sdk = sdk, let from = selectedWallet?.address else { return }
        
        let message = "Hello, CROSSx! Please sign this message to verify your wallet ownership."
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("✍️ 메시지 서명 시작 (personal_sign)...")
        setWalletActionsEnabled(false)
        activityIndicator.startAnimating()
        
        Task {
            do {
                log("  Message: \(message)")
                log("  From: \(from)")
                log("  서명 중...")
                
                let response = try await sdk.signMessage(
                    message,
                    chainId: testChainId,
                    from: from,
                    
                )
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    log("✅ 메시지 서명 완료!")
                    log("  Signature: \(String((response.signature ?? "N/A").prefix(10)))...")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    showAlert(
                        title: "Sign Message",
                        message: "메시지 서명 완료\nSignature: \(String((response.signature ?? "N/A").prefix(10)))..."
                    )
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 메시지 서명 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    @objc private func signTypedDataTapped() {
        guard let sdk = sdk, let from = selectedWallet?.address else { return }
        
        let typedData: [String: Any] = [
            "domain": [
                "name": "CROSSx",
                "version": "1",
                "chainId": 612044,
                "verifyingContract": "0x0000000000000000000000000000000000000001"
            ],
            "types": [
                "EIP712Domain": [
                    ["name": "name", "type": "string"],
                    ["name": "version", "type": "string"],
                    ["name": "chainId", "type": "uint256"],
                    ["name": "verifyingContract", "type": "address"]
                ],
                "Transfer": [
                    ["name": "from", "type": "address"],
                    ["name": "to", "type": "address"],
                    ["name": "amount", "type": "uint256"],
                    ["name": "nonce", "type": "uint256"]
                ]
            ],
            "primaryType": "Transfer",
            "message": [
                "from": from,
                "to": "0x920A31f0E48739C3FbB790D992b0690f7F5C42ea",
                "amount": "1000000000000000000",
                "nonce": 0
            ]
        ]
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("✍️ Typed Data V4 서명 시작 (eth_signTypedData_v4)...")
        setWalletActionsEnabled(false)
        activityIndicator.startAnimating()
        
        Task {
            do {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: typedData),
                      let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw CROSSxError.signFailed("Typed Data JSON 직렬화 실패")
                }
                
                log("  PrimaryType: Transfer")
                log("  From: \(from)")
                log("  To: 0x920A...42ea")
                log("  Amount: 1 ETH (1000000000000000000 wei)")
                log("  서명 중...")
                
                let response = try await sdk.signTypedData(
                    jsonString,
                    chainId: testChainId,
                    from: from,
                    
                )
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    log("✅ Typed Data V4 서명 완료!")
                    log("  Signature: \(String((response.signature ?? "N/A").prefix(10)))...")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    showAlert(
                        title: "Sign Typed Data V4",
                        message: "Typed Data 서명 완료\nSignature: \(String((response.signature ?? "N/A").prefix(10)))..."
                    )
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ Typed Data V4 서명 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    @objc private func sendERC20Tapped() {
        guard let sdk = sdk, let from = selectedWallet?.address else { return }
        
        let erc20Data = "0xa9059cbb000000000000000000000000920a31f0e48739c3fbb790d992b0690f7f5c42ea000000000000000000000000000000000000000000000000002386f26fc10000"
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("📤 ERC20 전송 시작 (sendTransactionAndWait)...")
        setWalletActionsEnabled(false)
        activityIndicator.startAnimating()
        
        Task {
            do {
                let tx = UnsignedTransaction(
                    chainId: testEvmChainId,
                    from: from,
                    to: testERC20Contract,
                    value: "0x0",
                    data: erc20Data,
                    gasLimit: "0x881e",
                    gasPrice: "0xee6b2800",
                    maxFeePerGas: "0x77359400",
                    maxPriorityFeePerGas: "0x3b9aca00"
                )
                
                log("  Contract: \(testERC20Contract)")
                log("  To (transfer): \(testRecipient)")
                log("  Amount: 0.01 (0x2386f26fc10000)")
                log("  전송 + Receipt 대기 중...")
                
                let result = try await sdk.sendTransactionAndWait(tx, chainId: testChainId)
                let success = result.receipt.status == "0x1"
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if success {
                        log("✅ ERC20 전송 성공!")
                    } else {
                        log("❌ ERC20 전송 실패 (REVERTED)")
                    }
                    log("  TxHash: \(result.txHash)")
                    log("  Status: \(result.receipt.status)")
                    log("  Block: \(result.receipt.blockNumber)")
                    log("  GasUsed: \(result.receipt.gasUsed)")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
                
                await self.fetchBalance(address: from)
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ ERC20 전송 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    @objc private func sendNativeTapped() {
        guard let sdk = sdk, let from = selectedWallet?.address else { return }
        
        log("")
        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        log("💰 네이티브 코인 전송 시작 (sendTransactionAndWait)...")
        setWalletActionsEnabled(false)
        activityIndicator.startAnimating()
        
        Task {
            do {
                let tx = UnsignedTransaction(
                    chainId: testEvmChainId,
                    from: from,
                    to: testRecipient,
                    value: "0x2386f26fc10000",
                    data: "0x",
                    gasLimit: "0x5208",
                    gasPrice: "0xee6b2800",
                    maxFeePerGas: "0x77359400",
                    maxPriorityFeePerGas: "0x3b9aca00"
                )
                
                log("  To: \(testRecipient)")
                log("  Value: 0.01 ETH (0x2386f26fc10000)")
                log("  전송 + Receipt 대기 중...")
                
                let result = try await sdk.sendTransactionAndWait(tx, chainId: testChainId)
                let success = result.receipt.status == "0x1"
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if success {
                        log("✅ 네이티브 전송 성공!")
                    } else {
                        log("❌ 네이티브 전송 실패 (REVERTED)")
                    }
                    log("  TxHash: \(result.txHash)")
                    log("  Status: \(result.receipt.status)")
                    log("  Block: \(result.receipt.blockNumber)")
                    log("  GasUsed: \(result.receipt.gasUsed)")
                    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
                
                await self.fetchBalance(address: from)
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    setWalletActionsEnabled(true)
                    if !handleSessionExpiredIfNeeded(error) {
                        log("❌ 네이티브 전송 실패: \(error.localizedDescription)")
                        log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            }
        }
    }
    
    // MARK: - Verify Password
    
    @objc private func verifyPasswordTapped() {
        let alert = UIAlertController(title: "Verify Password", message: "비밀번호(PIN)를 입력하세요", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Verify", style: .default) { [weak self] _ in
            guard let self, let sdk = self.sdk,
                  let password = alert.textFields?.first?.text, !password.isEmpty else { return }
            
            self.log("")
            self.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            self.log("🔑 비밀번호 검증 시작...")
            self.setWalletActionsEnabled(false)
            self.activityIndicator.startAnimating()
            
            Task {
                do {
                    let verified = try await sdk.verifyPassword(password)
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.setWalletActionsEnabled(true)
                        if verified {
                            self.log("✅ 비밀번호 검증 성공 (verified: true)")
                        } else {
                            self.log("❌ 비밀번호 불일치 (verified: false)")
                        }
                        self.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        self.showAlert(
                            title: "Verify Password",
                            message: verified ? "✅ 비밀번호가 올바릅니다" : "❌ 비밀번호가 틀립니다"
                        )
                    }
                } catch let error as CROSSxError {
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.setWalletActionsEnabled(true)
                        if self.handleSessionExpiredIfNeeded(error) { return }
                        self.log("❌ 비밀번호 검증 실패")
                        self.log("  errorCode: \(error.errorCode)")
                        self.log("  message: \(error.localizedDescription)")
                        if case .passwordLocked(let info) = error {
                            self.log("  permanent: \(info.permanent)")
                            self.log("  remainingAttempts: \(info.remainingAttempts)")
                            self.log("  maxAttempts: \(info.maxAttempts)")
                            self.log("  lockExpiresAt: \(info.lockExpiresAt)")
                        }
                        self.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        self.showAlert(
                            title: "Verify Password Failed",
                            message: "[\(error.errorCode)] \(error.localizedDescription)"
                        )
                    }
                } catch {
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.setWalletActionsEnabled(true)
                        if !self.handleSessionExpiredIfNeeded(error) {
                            self.log("❌ 비밀번호 검증 실패: \(error.localizedDescription)")
                            self.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        }
                    }
                }
            }
        })
        present(alert, animated: true)
    }
    
    // MARK: - UI Helpers
    
    private func showWalletActions() {
        walletActionsStack.isHidden = false
        setWalletActionsEnabled(true)
    }
    
    private func hideWalletActions() {
        walletActionsStack.isHidden = true
        walletInfoLabel.isHidden = true
        selectedWalletLabel.isHidden = true
        createWalletButton.isHidden = true
        selectedWallet = nil
    }
    
    private func setWalletActionsEnabled(_ enabled: Bool) {
        let buttons = [selectWalletButton, signTxButton, signMessageButton, signTypedDataButton, sendERC20Button, sendNativeButton, verifyPasswordButton]
        for btn in buttons {
            btn.isEnabled = enabled
            btn.alpha = enabled ? 1.0 : 0.5
        }
    }
    
    private func updateUI(signedIn: Bool, user: UserInfo?, wallet: String?) {
        isSignedIn = signedIn
        
        if signedIn {
            statusLabel.text = "✅ Logged In"
            statusLabel.textColor = .systemGreen
            
            var info = ""
            if let email = user?.email {
                info += "👤 \(email)"
            } else if let userId = user?.id {
                info += "👤 \(userId)"
            }
            userInfoLabel.text = info
            userInfoLabel.isHidden = info.isEmpty
            
            signInButton.isEnabled = false
            signInButton.alpha = 0.5
            signInButton.setTitle("Already Signed In", for: .disabled)
            
            signOutButton.isEnabled = true
            signOutButton.alpha = 1.0

            getUserInfoButton.isHidden = false
        } else {
            statusLabel.text = "🔓 Not Logged In"
            statusLabel.textColor = .systemOrange
            userInfoLabel.isHidden = true
            selectedWalletLabel.isHidden = true
            
            signInButton.isEnabled = true
            signInButton.alpha = 1.0
            signInButton.setTitle("Sign In with OAuth", for: .normal)
            
            signOutButton.isEnabled = false
            signOutButton.alpha = 0.5

            getUserInfoButton.isHidden = true
        }
    }
    
    private func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            signInButton.isEnabled = false
            signInButton.alpha = 0.5
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func updateSelectedWalletLabel() {
        guard let wallet = selectedWallet else {
            selectedWalletLabel.isHidden = true
            return
        }
        selectedWalletLabel.text = "▶ Selected: [\(wallet.index)] \(abbreviateAddress(wallet.address))"
        selectedWalletLabel.isHidden = false
    }

    private func abbreviateAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return String(address.prefix(6)) + "..." + String(address.suffix(4))
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Session Error Handling

    private func handleSessionExpiredIfNeeded(_ error: Error) -> Bool {
        guard let crossxError = error as? CROSSxError else { return false }
        switch crossxError {
        case .sessionExpired, .notAuthenticated:
            updateUI(signedIn: false, user: nil, wallet: nil)
            hideWalletActions()
            log("🔒 세션 만료 — 재로그인 필요 (\(crossxError.errorCode))")
            showAlert(title: "Session Expired", message: "세션이 만료되었습니다. 다시 로그인해 주세요.")
            return true
        default:
            return false
        }
    }

    // MARK: - Logging
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text += logMessage
        
        if logTextView.text.count > 1 {
            let range = NSRange(location: logTextView.text.count - 1, length: 1)
            logTextView.scrollRangeToVisible(range)
        }
        
        print("[CROSSxSample] \(message)")
    }
}
