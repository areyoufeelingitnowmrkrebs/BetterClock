import QtQuick;
import QtWebEngine;
import QtQuick.Layouts 1.1;
import org.kde.plasma.components 3.0 as PlasmaComponents3;
import org.kde.kirigami 2.20 as Kirigami;
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.plasmoid 2.0;
import org.kde.notification;

Item {
    id: root;

    Layout.minimumWidth: Kirigami.Units.gridUnit * 30;
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25;
    Layout.preferredWidth: Kirigami.Units.gridUnit * 45;
    Layout.preferredHeight: Kirigami.Units.gridUnit * 40;

    WebEngineView {
        id: webview;
        anchors.fill: parent;

        zoomFactor: 1.0;
        backgroundColor: "transparent";

        Component.onCompleted: {
            url = plasmoid.configuration.calendarUrl;
        }

        Connections {
            target: plasmoid.configuration;
            function onCalendarUrlChanged() {
                if (webview.url !== plasmoid.configuration.calendarUrl) {
                    webview.url = plasmoid.configuration.calendarUrl;
                }
            }
        }

        settings {
            javascriptCanAccessClipboard: plasmoid.configuration.calendarCanAccessClipboard;
            forceDarkMode: plasmoid.configuration.calendarForceDarkMode;

            javascriptEnabled: true;
            pluginsEnabled: true;
        }

        Component {
            id: notificationComponent;
            Notification {
                componentName: "plasma_workspace";
                eventId: "notification";
                iconName: "preferences-system-time";
                autoDelete: true;
            }
        }

        profile: WebEngineProfile {
            id: persistentProfile;
            storageName: "Calendar";
            offTheRecord: false;
            isPushServiceEnabled: plasmoid.configuration.calendarAllowNotification;
            onPresentNotification: notification => {
                var nativeNotification = notificationComponent.createObject(parent);
                nativeNotification.title = notification.title;
                nativeNotification.text = notification.message;
                nativeNotification.sendEvent();
            }
        }

        onPermissionRequested: permission => {
            switch (permission.permissionType) {
                case WebEnginePermission.PermissionType.Notifications: {
                    if (plasmoid.configuration.calendarAllowNotification) {
                        permission.grant();
                    } else {
                        permission.deny();
                    }
                    break;
                }
                case WebEnginePermission.PermissionType.MediaAudioCapture:
                case WebEnginePermission.PermissionType.MediaVideoCapture:
                case WebEnginePermission.PermissionType.MediaAudioVideoCapture:
                case WebEnginePermission.PermissionType.DesktopVideoCapture:
                case WebEnginePermission.PermissionType.DesktopAudioVideoCapture:
                default: {
                    permission.deny();
                }
            }
        }

        onNavigationRequested: request => {
            if (request.userInitiated) {
                Qt.openUrlExternally(request.url);
            }
            request.accepted = false;
        }
    }
}
