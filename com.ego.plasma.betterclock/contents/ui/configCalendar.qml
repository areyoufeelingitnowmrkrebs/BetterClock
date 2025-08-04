import QtQuick;
import QtQuick.Layouts 1.3;
import QtQuick.Controls 2.12 as QQC2;
import org.kde.plasma.components 3.0 as PlasmaComponents3;
import org.kde.kirigami 2.20 as Kirigami;
import org.kde.kcmutils as KCM;

KCM.SimpleKCM {
    property alias cfg_calendarUrl: calendarUrl.text;
    property alias cfg_calendarCanAccessClipboard: canAccessClipboard.checked;
    property alias cfg_calendarForceDarkMode: forceDarkMode.checked;
    property alias cfg_calendarAllowNotification: allowNotification.checked;

    Kirigami.FormLayout {
        PlasmaComponents3.TextField {
            id: calendarUrl;
            Layout.fillWidth: true;
            Kirigami.FormData.label: i18nc("@label:textbox", "Calendar URL:");
            placeholderText: "[https://calendar.google.com/](https://calendar.google.com/)";
            onAccepted: {
                let url = text;
                if (url.indexOf(":/") < 0 && url.length > 0) {
                    url = "http://" + url;
                }
                text = url;
            }
        }

        Item {
            Kirigami.FormData.isSection: true;
        }

        QQC2.CheckBox {
            id: canAccessClipboard;
            Kirigami.FormData.label: i18nc("@title:group", "Web Settings:");
            text: i18nc("@option:check", "Allow JavaScript to access system clipboard");
        }

        QQC2.CheckBox {
            id: forceDarkMode;
            text: i18nc("@option:check", "Render web page using a dark theme");
        }

        QQC2.CheckBox {
            id: allowNotification;
            text: i18nc("@option:check", "Allow HTML5 notification");
        }
    }
}
