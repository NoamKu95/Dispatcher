import Foundation

struct SettingModel {
    var sectionTitle: String
    var options: [SingleSetting]
}

struct SingleSetting {
    var title: String
    var description: String?
    var status: switchStatus
}

enum switchStatus {
    case disabled
    case on
    case off
}
