/*
 * Copyright (C) 2024 by Heqro <heqromancer@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // TODO - detect external color scheme change

    Timer {
        id: timeCheckTimer
        interval: 60000
        running: plasmoid.configuration.enableAutoSwitch
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const themeAShouldBeEnabled = isDaytime()
            const themeAIsEnabled = plasmoid.configuration.checked

            if (themeAShouldBeEnabled !== themeAIsEnabled) {
                executable.swapColorScheme()
                executable.executeAdditionalCommand()
                plasmoid.configuration.checked = !plasmoid.configuration.checked
            }
        }

        function isDaytime() {
            const now = new Date()
            const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`

            const dayStart = plasmoid.configuration.dayStartTime || "06:00"
            const nightStart = plasmoid.configuration.nightStartTime || "18:00"

            return (currentTime >= dayStart && currentTime < nightStart)
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            disconnectSource(sourceName)
        }

        function exec(cmd) {
            connectSource(cmd)
        }

        function swapColorScheme() {
            const colorSchemeName = plasmoid.configuration.checked ? plasmoid.configuration.colorB : plasmoid.configuration.colorA
            exec("plasma-apply-colorscheme " + colorSchemeName)
        }

        function executeAdditionalCommand() {
            if (!plasmoid.configuration.checked && plasmoid.configuration.useExtraCommand_iconA) {
                exec(plasmoid.configuration.textField_iconA)
            }

            if (plasmoid.configuration.checked && plasmoid.configuration.useExtraCommand_iconB) {
                exec(plasmoid.configuration.textField_iconB)
            }
        }
    }

    Kirigami.Icon {

        id: icon
        anchors.fill: parent
        source: plasmoid.configuration.checked ? plasmoid.configuration.iconA : plasmoid.configuration.iconB

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                executable.swapColorScheme()
                executable.executeAdditionalCommand()
                plasmoid.configuration.checked = !plasmoid.configuration.checked
            }
        }
    }
}
