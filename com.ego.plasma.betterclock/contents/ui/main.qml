pragma ComponentBehavior: Bound;

import QtQuick;
import QtQuick.Layouts;
import org.kde.plasma.plasmoid;
import org.kde.plasma.core as PlasmaCore;
import org.kde.plasma.plasma5support as P5Support;
import org.kde.plasma.private.digitalclock;
import org.kde.kirigami as Kirigami;
import org.kde.config as KConfig;
import org.kde.kcmutils as KCMUtils;

PlasmoidItem {
    id: root;

    width: Kirigami.Units.gridUnit * 10;
    height: Kirigami.Units.gridUnit * 4;

    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground;

    readonly property string dateFormatString: setDateFormatString();

    readonly property date currentDateTimeInSelectedTimeZone: {
        const data = dataSource.data[Plasmoid.configuration.lastSelectedTimezone];
        if (data === undefined) {
            return new Date();
        }
        const now = data["DateTime"];
        const nowUtcMilliseconds = now.getTime() + (now.getTimezoneOffset() * 60000);
        const selectedTimeZoneOffsetMilliseconds = data["Offset"] * 1000;
        return new Date(nowUtcMilliseconds + selectedTimeZoneOffsetMilliseconds);
    }

    function initTimeZones() {
        const timeZones = [];
        if (Plasmoid.configuration.selectedTimeZones.indexOf("Local") === -1) {
            timeZones.push("Local");
        }
        root.allTimeZones = timeZones.concat(Plasmoid.configuration.selectedTimeZones);
    }

    function timeForZone(timeZone, showSeconds) {
        if (!compactRepresentationItem) {
            return "";
        }

        const data = dataSource.data[timeZone];
        if (data === undefined) {
            return "";
        }

        const now = data["DateTime"];
        const msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
        const dateTime = new Date(msUTC + (data["Offset"] * 1000));

        let formattedTime;
        if (showSeconds) {
            formattedTime = Qt.formatTime(dateTime, compactRepresentationItem.item.timeFormatWithSeconds);
        } else {
            formattedTime = Qt.formatTime(dateTime, compactRepresentationItem.item.timeFormat);
        }

        if (dateTime.getDay() !== dataSource.data["Local"]["DateTime"].getDay()) {
            formattedTime += " (" + compactRepresentationItem.item.dateFormatter(dateTime) + ")";
        }

        return formattedTime;
    }

    function displayStringForTimeZone(timeZone) {
        const data = dataSource.data[timeZone];
        if (data === undefined) {
            return timeZone;
        }

        if (Plasmoid.configuration.displayTimezoneAsCode) {
            return data["Timezone Abbreviation"];
        } else {
            return TimeZonesI18n.i18nCity(data["Timezone"]);
        }
    }

    function selectedTimeZonesDeduplicatingExplicitLocalTimeZone() {
        const displayStringForLocalTimeZone = displayStringForTimeZone("Local");
        const isLiterallyLocalOrResolvesToSomethingOtherThanLocal = timeZone =>
        timeZone === "Local" || displayStringForTimeZone(timeZone) !== displayStringForLocalTimeZone;

        return Plasmoid.configuration.selectedTimeZones
        .filter(isLiterallyLocalOrResolvesToSomethingOtherThanLocal)
        .sort((a, b) => dataSource.data[a]["Offset"] - dataSource.data[b]["Offset"]);
    }

    function timeZoneResolvesToLastSelectedTimeZone(timeZone) {
        return timeZone === Plasmoid.configuration.lastSelectedTimezone
        || displayStringForTimeZone(timeZone) === displayStringForTimeZone(Plasmoid.configuration.lastSelectedTimezone);
    }

    preferredRepresentation: compactRepresentation;
    fullRepresentation: WebViewCalendar {}

    compactRepresentation: Loader {
        id: conditionalLoader;

        property bool containsMouse: item?.containsMouse ?? false;
        Layout.minimumWidth: item.Layout.minimumWidth;
        Layout.minimumHeight: item.Layout.minimumHeight;
        Layout.preferredWidth: item.Layout.preferredWidth;
        Layout.preferredHeight: item.Layout.preferredHeight;
        Layout.maximumWidth: item.Layout.maximumWidth;
        Layout.maximumHeight: item.Layout.maximumHeight;

        sourceComponent: (currentDateTimeInSelectedTimeZone == "Invalid Date") ? noTimezoneComponent : digitalClockComponent;
    }

    Component {
        id: digitalClockComponent;
        DigitalClock {
            activeFocusOnTab: true;
            hoverEnabled: true;

            Accessible.name: tooltipLoader.item.Accessible.name;
            Accessible.description: tooltipLoader.item.Accessible.description;
        }
    }

    Component {
        id: noTimezoneComponent;
        NoTimezoneWarning {}
    }

    toolTipItem: Loader {
        id: tooltipLoader;

        Layout.minimumWidth: item ? item.implicitWidth : 0;
        Layout.maximumWidth: item ? item.implicitWidth : 0;
        Layout.minimumHeight: item ? item.implicitHeight : 0;
        Layout.maximumHeight: item ? item.implicitHeight : 0;

        source: Qt.resolvedUrl("Tooltip.qml");
    }

    property list<string> allTimeZones;

    Connections {
        target: Plasmoid.configuration;
        function onSelectedTimeZonesChanged() {
            root.initTimeZones();
        }
    }

    hideOnWindowDeactivate: !Plasmoid.configuration.pin;

    P5Support.DataSource {
        id: dataSource;
        engine: "time";
        connectedSources: allTimeZones;
        interval: intervalAlignment === P5Support.Types.NoAlignment ? 1000 : 60000;
        intervalAlignment: {
            if (Plasmoid.configuration.showSeconds) {
                return P5Support.Types.NoAlignment;
            } else {
                return P5Support.Types.AlignToMinute;
            }
        }
    }

    function setDateFormatString() {
        let format = Qt.locale().dateFormat(Locale.LongFormat);
        format = format.replace(/(^dddd.?\s)|(,?\sdddd$)/, "");
        return format;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            id: clipboardAction;
            text: i18n("Copy to Clipboard");
            icon.name: "edit-copy";
        }
    ]

    Component.onCompleted: {
        ClipboardMenu.setupMenu(clipboardAction);
        initTimeZones();
    }
}
