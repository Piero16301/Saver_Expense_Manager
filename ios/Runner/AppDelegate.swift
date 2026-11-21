import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    ShareIntentPlugin.register(with: engineBridge.applicationRegistrar)
  }
}

final class ShareIntentPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.pmorales.saver.expense.manager/share"
  private static let allowedExtensions: Set<String> = ["pdf", "png", "jpg", "jpeg"]
  private static let shared = ShareIntentPlugin()

  private var channel: FlutterMethodChannel?
  private var pendingSharedFile: [String: String]?
  private var hasRequestedInitial = false

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    shared.channel = channel
    registrar.addMethodCallDelegate(shared, channel: channel)
    registrar.addApplicationDelegate(shared)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getInitialSharedFile" {
      hasRequestedInitial = true
      if let pending = pendingSharedFile {
        pendingSharedFile = nil
        clearPendingMetadata()
        result(pending)
        return
      }
      result(consumePendingMetadataFromAppGroup())
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    guard let expectedScheme = shareUrlScheme,
          url.scheme?.lowercased() == expectedScheme.lowercased(),
          url.host?.lowercased() == "share" else {
      return false
    }

    guard let payload = parseShareUrl(url) ?? consumePendingMetadataFromAppGroup() else {
      return false
    }

    clearPendingMetadata()

    if hasRequestedInitial, let channel = channel {
      channel.invokeMethod("onSharedFile", arguments: payload)
    } else {
      pendingSharedFile = payload
    }
    return true
  }

  private var appGroupId: String? {
    Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String
  }

  private var shareUrlScheme: String? {
    Bundle.main.object(forInfoDictionaryKey: "ShareUrlScheme") as? String
  }

  private var sharedFilesDirectory: URL? {
    guard let appGroupId = appGroupId,
          let containerUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
          ) else {
      return nil
    }
    return containerUrl.appendingPathComponent("shared_files", isDirectory: true)
  }

  private func parseShareUrl(_ url: URL) -> [String: String]? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems,
          let sharedDir = sharedFilesDirectory else {
      return nil
    }

    let type = queryItems.first(where: { $0.name == "type" })?.value?.uppercased()
    guard type == "EXPENSE" || type == "INCOME" else { return nil }

    guard let fileParam = queryItems.first(where: { $0.name == "file" })?.value,
          !fileParam.isEmpty else {
      return nil
    }

    let safeFileName = (fileParam as NSString).lastPathComponent
    let fileUrl = sharedDir.appendingPathComponent(safeFileName)
    let ext = fileUrl.pathExtension.lowercased()
    guard Self.allowedExtensions.contains(ext),
          FileManager.default.fileExists(atPath: fileUrl.path) else {
      return nil
    }

    let displayName = queryItems.first(where: { $0.name == "name" })?.value ?? safeFileName
    return [
      "path": fileUrl.path,
      "name": displayName,
      "movementType": type!,
    ]
  }

  private func consumePendingMetadataFromAppGroup() -> [String: String]? {
    guard let sharedDir = sharedFilesDirectory else { return nil }
    let metadataUrl = sharedDir.appendingPathComponent("pending_share.json")
    guard FileManager.default.fileExists(atPath: metadataUrl.path),
          let data = try? Data(contentsOf: metadataUrl),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
      return nil
    }
    try? FileManager.default.removeItem(at: metadataUrl)

    guard let path = json["path"],
          let name = json["name"],
          let movementType = json["movementType"],
          (movementType == "EXPENSE" || movementType == "INCOME"),
          FileManager.default.fileExists(atPath: path) else {
      return nil
    }

    let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
    guard Self.allowedExtensions.contains(ext) else { return nil }

    return [
      "path": path,
      "name": name,
      "movementType": movementType,
    ]
  }

  private func clearPendingMetadata() {
    guard let sharedDir = sharedFilesDirectory else { return }
    let metadataUrl = sharedDir.appendingPathComponent("pending_share.json")
    if FileManager.default.fileExists(atPath: metadataUrl.path) {
      try? FileManager.default.removeItem(at: metadataUrl)
    }
  }
}
