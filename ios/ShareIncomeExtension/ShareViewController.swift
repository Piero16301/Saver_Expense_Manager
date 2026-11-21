import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
  private static let movementType = "INCOME"
  private static let allowedExtensions: Set<String> = ["pdf", "png", "jpg", "jpeg"]
  private static let supportedTypes: [(identifier: String, defaultExt: String)] = [
    (UTType.pdf.identifier, "pdf"),
    (UTType.png.identifier, "png"),
    (UTType.jpeg.identifier, "jpg"),
  ]

  private var didHandleShare = false

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !didHandleShare else { return }
    didHandleShare = true
    handleSharedAttachment()
  }

  private func handleSharedAttachment() {
    guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
      finishExtension()
      return
    }

    for item in extensionItems {
      guard let attachments = item.attachments else { continue }
      for provider in attachments {
        for candidate in Self.supportedTypes {
          if provider.hasItemConformingToTypeIdentifier(candidate.identifier) {
            loadAttachment(
              provider: provider,
              typeIdentifier: candidate.identifier,
              defaultExt: candidate.defaultExt
            )
            return
          }
        }
      }
    }

    finishExtension()
  }

  private func loadAttachment(
    provider: NSItemProvider,
    typeIdentifier: String,
    defaultExt: String
  ) {
    provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
      guard let self = self, error == nil else {
        self?.finishExtension()
        return
      }

      let suggestedName = provider.suggestedName
      guard let saved = self.persistItem(
        item,
        suggestedName: suggestedName,
        defaultExt: defaultExt
      ) else {
        self.finishExtension()
        return
      }

      guard let deepLink = self.buildShareUrl(
        storedFileName: saved.storedFileName,
        displayName: saved.displayName
      ) else {
        self.finishExtension()
        return
      }

      self.openHostApp(with: deepLink)
    }
  }

  private func persistItem(
    _ item: NSSecureCoding?,
    suggestedName: String?,
    defaultExt: String
  ) -> (storedFileName: String, displayName: String)? {
    guard let appGroupId = Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String,
          let containerUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
          ) else {
      return nil
    }

    let sharedDir = containerUrl.appendingPathComponent("shared_files", isDirectory: true)
    try? FileManager.default.createDirectory(at: sharedDir, withIntermediateDirectories: true)

    var fileData: Data?
    var ext = defaultExt
    var rawName = suggestedName

    if let url = item as? URL {
      let urlExt = url.pathExtension.lowercased()
      if Self.allowedExtensions.contains(urlExt) {
        ext = urlExt
      }
      if rawName == nil || rawName!.isEmpty {
        rawName = url.lastPathComponent
      }
      let didAccess = url.startAccessingSecurityScopedResource()
      fileData = try? Data(contentsOf: url)
      if didAccess {
        url.stopAccessingSecurityScopedResource()
      }
    } else if let data = item as? Data {
      fileData = data
    } else if let image = item as? UIImage {
      if ext == "png" {
        fileData = image.pngData()
      } else {
        fileData = image.jpegData(compressionQuality: 0.95)
        ext = "jpg"
      }
    }

    guard let data = fileData, !data.isEmpty, Self.allowedExtensions.contains(ext) else {
      return nil
    }

    let storedFileName = "\(UUID().uuidString).\(ext)"
    let destinationUrl = sharedDir.appendingPathComponent(storedFileName)
    do {
      try data.write(to: destinationUrl, options: .atomic)
    } catch {
      return nil
    }

    let displayName: String
    if let candidateName = rawName, !candidateName.isEmpty {
      let candidateExt = (candidateName as NSString).pathExtension.lowercased()
      displayName = Self.allowedExtensions.contains(candidateExt)
        ? candidateName
        : "\(candidateName).\(ext)"
    } else {
      displayName = storedFileName
    }

    let metadata: [String: String] = [
      "path": destinationUrl.path,
      "name": displayName,
      "movementType": Self.movementType,
    ]
    if let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
      let metadataUrl = sharedDir.appendingPathComponent("pending_share.json")
      try? metadataData.write(to: metadataUrl, options: .atomic)
    }

    return (storedFileName, displayName)
  }

  private func buildShareUrl(storedFileName: String, displayName: String) -> URL? {
    guard let scheme = Bundle.main.object(forInfoDictionaryKey: "ShareUrlScheme") as? String,
          !scheme.isEmpty else {
      return nil
    }

    var components = URLComponents()
    components.scheme = scheme
    components.host = "share"
    components.queryItems = [
      URLQueryItem(name: "type", value: Self.movementType),
      URLQueryItem(name: "file", value: storedFileName),
      URLQueryItem(name: "name", value: displayName),
    ]
    return components.url
  }

  private func openHostApp(with url: URL) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      let selectorOpenURL = sel_registerName("openURL:options:completionHandler:")
      var responder: UIResponder? = self
      while let current = responder {
        if current.responds(to: selectorOpenURL) {
          typealias OpenURLFunc = @convention(c) (
            AnyObject,
            Selector,
            NSURL,
            NSDictionary,
            (@convention(block) (Bool) -> Void)?
          ) -> Void
          let imp = current.method(for: selectorOpenURL)
          let openURL = unsafeBitCast(imp, to: OpenURLFunc.self)
          openURL(current, selectorOpenURL, url as NSURL, NSDictionary(), { [weak self] _ in
            self?.finishExtension()
          })
          return
        }
        responder = current.next
      }
      self.finishExtension()
    }
  }

  private func finishExtension() {
    DispatchQueue.main.async { [weak self] in
      self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
  }
}
