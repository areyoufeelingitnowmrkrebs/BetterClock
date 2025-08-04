pragma ComponentBehavior: Bound;

import QtQuick;
import org.kde.plasma.configuration;

ConfigModel {
    id: configModel;

    ConfigCategory {
        name: i18n("Appearance");
        icon: "preferences-desktop-color";
        source: "configAppearance.qml";
    }
    ConfigCategory {
        name: i18n("Calendar");
        icon: "office-calendar";
        source: "configCalendar.qml";
    }
    ConfigCategory {
        name: i18n("Time Zones");
        icon: "preferences-system-time";
        source: "configTimeZones.qml";
    }
}
