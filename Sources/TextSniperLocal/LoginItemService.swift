import AppKit
import Foundation
import ServiceManagement

struct LoginItemService {
    var status: LoginItemStatus {
        switch SMAppService.mainApp.status {
        case .enabled:
            .enabled
        case .requiresApproval:
            .requiresApproval
        case .notFound:
            .unavailable
        case .notRegistered:
            .disabled
        @unknown default:
            .unavailable
        }
    }

    func setEnabled(_ isEnabled: Bool) throws {
        if isEnabled {
            guard status != .enabled else {
                return
            }

            try SMAppService.mainApp.register()
        } else {
            guard status != .disabled else {
                return
            }

            try SMAppService.mainApp.unregister()
        }
    }
}

enum LoginItemStatus: Equatable {
    case enabled
    case disabled
    case requiresApproval
    case unavailable

    var isEnabled: Bool {
        self == .enabled
    }

    var menuTitle: String {
        switch self {
        case .enabled, .disabled:
            "로그인 시 실행"
        case .requiresApproval:
            "로그인 시 실행 (승인 필요)"
        case .unavailable:
            "로그인 시 실행 (사용 불가)"
        }
    }

    var menuState: NSControl.StateValue {
        switch self {
        case .enabled:
            .on
        case .requiresApproval:
            .mixed
        case .disabled, .unavailable:
            .off
        }
    }
}
