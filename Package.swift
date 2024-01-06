// swift-tools-version: 5.9

import Foundation
import PackageDescription

// MARK: - Parse build arguments

func hasEnvironmentVariable(_ name: String) -> Bool {
  return ProcessInfo.processInfo.environment[name] != nil
}

/// Use the `NonDarwinLogger` even if `os_log` can be imported.
///
/// This is useful when running tests using `swift test` because xctest will not display the output from `os_log` on the
/// command line.
let forceNonDarwinLogger = hasEnvironmentVariable("SOURCEKITLSP_FORCE_NON_DARWIN_LOGGER")

var lspLoggingSwiftSettings: [SwiftSetting] = []
if forceNonDarwinLogger {
  lspLoggingSwiftSettings += [.define("SOURCEKITLSP_FORCE_NON_DARWIN_LOGGER")]
}

/// Assume that all the package dependencies are checked out next to sourcekit-lsp and use that instead of fetching a
/// remote dependency.
let useLocalDependencies = hasEnvironmentVariable("SWIFTCI_USE_LOCAL_DEPS")

let package = Package(
  name: "language-server-protocol",
  platforms: [.macOS("12.0")],
  products: [
    .library(name: "LanguageServerProtocol", targets: ["LanguageServerProtocol"]),
    .library(name: "LanguageServerProtocolJSONRPC", targets: ["LanguageServerProtocolJSONRPC"]),
  ],
  dependencies: [
    // See 'Dependencies' below.
  ],
  targets: [
    .target(
      name: "LanguageServerProtocol",
      exclude: ["CMakeLists.txt"]
    ),
    .testTarget(
      name: "LanguageServerProtocolTests",
      dependencies: [
        "LanguageServerProtocol",
        "LSPTestSupport",
      ]
    ),
    .target(
      name: "LanguageServerProtocolJSONRPC",
      dependencies: [
        "LanguageServerProtocol",
        "LSPLogging",
      ],
      exclude: ["CMakeLists.txt"]
    ),
    .testTarget(
      name: "LanguageServerProtocolJSONRPCTests",
      dependencies: [
        "LanguageServerProtocolJSONRPC",
        "LSPTestSupport",
      ]
    ),
    .target(
      name: "LSPLogging",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto")
      ],
      exclude: ["CMakeLists.txt"],
      swiftSettings: lspLoggingSwiftSettings
    ),

    // MARK: LSPTestSupport

    .target(
      name: "LSPTestSupport",
      dependencies: [
        "LanguageServerProtocol",
        "LanguageServerProtocolJSONRPC",
      ]
    ),
  ]
)

if useLocalDependencies {
  package.dependencies += [
    .package(path: "../swift-crypto")
  ]
} else {
  // Building standalone.
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
  ]
}
