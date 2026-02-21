import QtQml 2.15
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    
    
    // setting background as transparent with a drop shadow
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    
    // loading fonts
    FontLoader {
        id: font_anurati
        source: "../fonts/Anurati.otf"
    }
    FontLoader {
        id: font_poppins
        source: "../fonts/Poppins.ttf"
    }
    

    // setting preferred size
    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {

        // applet default size
        Layout.minimumWidth: container.implicitWidth
        Layout.minimumHeight: container.implicitHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        // Updating time every minute
        Plasma5Support.DataSource {
            id: dataSource
            engine: "time"
            connectedSources: ["Local"]
            intervalAlignment: Plasma5Support.Types.AlignToMinute
            interval: 60000

            property bool use24HourFormat: plasmoid.configuration.use_24_hour_format
            property string timeCharacter: plasmoid.configuration.time_character
            property string dateFormat: plasmoid.configuration.date_format
            property string timeFormat: plasmoid.configuration.time_format
            property string dayFormat: plasmoid.configuration.day_format
            property bool uppercaseDay: plasmoid.configuration.uppercase_day
            property bool uppercaseDate: plasmoid.configuration.uppercase_date
            property bool usesSeconds: false
            readonly property string default24HourFormat: "hh:mm"
            readonly property string default12HourFormat: "hh:mm AP"
            readonly property int secondInterval: 1000
            readonly property int minuteInterval: 60000
            function currentTimeFormat() {
                var custom = timeFormat ? timeFormat.trim() : ""
                return custom.length > 0 ? custom : (use24HourFormat ? default24HourFormat : default12HourFormat)
            }

            function updateIntervalForFormat(format) {
                // Qt time format uses 's' or 'ss' for seconds; adjust refresh cadence when seconds are present.
                var needsSeconds = /s{1,2}/.test(format)
                if (needsSeconds !== usesSeconds) {
                    usesSeconds = needsSeconds
                    interval = needsSeconds ? secondInterval : minuteInterval
                    intervalAlignment = needsSeconds ? Plasma5Support.Types.NoAlignment : Plasma5Support.Types.AlignToMinute
                }
            }

            function formatTimeSafely(date) {
                var format = currentTimeFormat()
                updateIntervalForFormat(format)
                var formatted = ""
                try {
                    formatted = Qt.formatTime(date, format)
                } catch (e) {
                    formatted = ""
                }
                if (!formatted || formatted.trim() === "") {
                    format = use24HourFormat ? default24HourFormat : default12HourFormat
                    updateIntervalForFormat(format)
                    formatted = Qt.formatTime(date, format)
                }
                return formatted
            }

            onDataChanged: {
                var curDate = dataSource.data["Local"]["DateTime"]
                var formattedTime = formatTimeSafely(curDate)
                var df = dayFormat && dayFormat.trim().length > 0 ? dayFormat : "dddd"
                var dayText = Qt.formatDate(curDate, df)
                display_day.text = uppercaseDay ? dayText.toUpperCase() : dayText
                var dateText = Qt.formatDate(curDate, dateFormat)
                display_date.text = uppercaseDate ? dateText.toUpperCase() : dateText
                display_time.text = timeCharacter + " " + formattedTime + " " + timeCharacter
            }

            onUse24HourFormatChanged: {
                updateIntervalForFormat(currentTimeFormat())
                dataChanged()
            }
            onTimeCharacterChanged: dataChanged()
            onDateFormatChanged: dataChanged()
            onDayFormatChanged: dataChanged()
            onUppercaseDayChanged: dataChanged()
            onUppercaseDateChanged: dataChanged()
            onTimeFormatChanged: {
                updateIntervalForFormat(currentTimeFormat())
                dataChanged()
            }

            Component.onCompleted: updateIntervalForFormat(currentTimeFormat())

            
        }

        // Main Content
        Column {
            id: container

            // Column settings
            anchors.centerIn: parent
            spacing: plasmoid.configuration.widget_spacing

            // The day ("Tuesday", "Wednesday" etc..)
            PlasmaComponents.Label {
                id: display_day
                
                // visible
                visible: plasmoid.configuration.show_day

                // font settings
                font.pixelSize: plasmoid.configuration.day_font_size
                font.letterSpacing: plasmoid.configuration.day_letter_spacing
                font.family: font_anurati.name
                font.bold: plasmoid.configuration.day_font_bold
                color: plasmoid.configuration.day_font_color
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter 
            }

            // The Date
            PlasmaComponents.Label {
                id: display_date

                // visibility
                visible: plasmoid.configuration.show_date

                // font settings
                font.pixelSize: plasmoid.configuration.date_font_size
                font.letterSpacing: plasmoid.configuration.date_letter_spacing
                font.family: font_poppins.name
                font.bold: plasmoid.configuration.date_font_bold
                color: plasmoid.configuration.date_font_color
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // The Time
            PlasmaComponents.Label {
                id: display_time

                // visibility
                visible: plasmoid.configuration.show_time

                // font settings
                font.pixelSize: plasmoid.configuration.time_font_size
                font.family: font_poppins.name
                font.bold: plasmoid.configuration.time_font_bold
                color: plasmoid.configuration.time_font_color
                font.letterSpacing: plasmoid.configuration.time_letter_spacing
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
