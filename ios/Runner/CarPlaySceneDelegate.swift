import CarPlay
import Foundation

@available(iOS 14.0, *)
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
    let favorites = listTemplate(title: localized("Favoriler", "Favorites"), systemImage: "heart.fill", preferenceKey: "flutter.favorites.v1", emptyText: localized("Henüz favori yok", "No favorites yet"))
    let recent = listTemplate(title: localized("Son Dinlenenler", "Recent"), systemImage: "clock.fill", preferenceKey: "flutter.recent.v1", emptyText: localized("Henüz yayın dinlenmedi", "Nothing played yet"))
    interfaceController.setRootTemplate(CPTabBarTemplate(templates: [favorites, recent]), animated: false, completion: nil)
  }

  private func listTemplate(title: String, systemImage: String, preferenceKey: String, emptyText: String) -> CPListTemplate {
    let stations = readStations(preferenceKey)
    let items: [CPListItem]
    if stations.isEmpty {
      let empty = CPListItem(text: emptyText, detailText: nil)
      items = [empty]
    } else {
      items = stations.prefix(60).map { station in
        let item = CPListItem(text: station.name, detailText: station.detail)
        item.handler = { _, completion in
          (UIApplication.shared.delegate as? AppDelegate)?.sendPlaybackCommand("playMediaId", argument: station.uuid)
          completion()
        }
        return item
      }
    }
    let template = CPListTemplate(title: title, sections: [CPListSection(items: items)])
    template.tabTitle = title
    template.tabImage = UIImage(systemName: systemImage)
    return template
  }

  private func readStations(_ key: String) -> [CarStation] {
    guard let raw = UserDefaults.standard.string(forKey: key), let data = raw.data(using: .utf8), let objects = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
    return objects.compactMap { object in
      guard let uuid = object["stationuuid"] as? String, !uuid.isEmpty, let name = object["name"] as? String, !name.isEmpty else { return nil }
      let state = object["state"] as? String ?? ""
      let tags = object["tags"] as? String ?? ""
      return CarStation(uuid: uuid, name: name, detail: state.isEmpty ? tags : state)
    }
  }

  private func localized(_ turkish: String, _ english: String) -> String {
    Locale.current.languageCode == "tr" ? turkish : english
  }
}

@available(iOS 14.0, *)
private struct CarStation { let uuid: String; let name: String; let detail: String }
