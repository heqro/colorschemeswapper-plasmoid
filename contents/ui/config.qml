/*
 * Copyright (C) 2019 by Piotr Markiewicz p.marki@wp.pl
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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configPage

    property alias cfg_colorA: labelA.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    property alias cfg_colorB: labelB.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    // TODO - allow the user to set them from here.
    property string cfg_iconA: plasmoid.configuration.iconA
    property string cfg_iconB: plasmoid.configuration.iconB


    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        signal colorsListReady(var colors)

        function exec(cmd) {
            connectSource(cmd)
        }

        onNewData: {
            var colors = data["stdout"].split("\n").slice(0, -1)
            for (var i = 0; i < colors.length; i++) { // parse command output
                //console.log("input", colors[i])
                colors[i] = colors[i].trim().substring(2).replace(/ \(.*\)/g, ''); // remove leading asterisk. Then, remove everything between and parentheses (usually "(current color scheme)")
                //console.log("output", colors[i])
            }
            colorsListReady(colors)
            disconnectSource(sourceName) // cmd finished
        }

    }

    // Copies of the last saved ComboBox entries.
    Label {
        id: labelA
        visible: false
    }
    Label {
        id: labelB
        visible: false
    }

    function setText(comboBox, text) { // comboboxes don't really allow to set current entry by text => manually search for them
        var found = false
        for (var colorIndex = 0; colorIndex < comboBox.count; colorIndex++) {
            if (comboBox.currentText === text) {
                found = true
                break
            }
            comboBox.incrementCurrentIndex()
        }
        if (!found)
            console.log("Color not found (perhaps it has been removed?).")
    }

    Connections {
        target: executable
        onColorsListReady: {
            cBoxA.model = colors
            cBoxB.model = colors
            // look for color in list
            setText(cBoxA, labelA.text)
            setText(cBoxB, labelB.text)
            // enable changes user just after everything is set up
            cBoxA.isChangeAvailable = true
            cBoxB.isChangeAvailable = true
        }
    }

    ColumnLayout {
        GridLayout {
            columns: 2
            Label {
                Layout.row :0
                Layout.column: 0
                text: i18n("Color A")
            }

            ComboBox {
                id: cBoxA
                property bool isChangeAvailable: false

                Layout.row: 0
                Layout.column: 1
                Layout.minimumWidth: 300
                onCurrentTextChanged: {
                    if (isChangeAvailable)
                        labelA.text = currentText
                }
            }

            Label {
                Layout.row :1
                Layout.column: 0
                text: i18n("Color B")
            }

            ComboBox {
                id: cBoxB
                property bool isChangeAvailable: false

                Layout.row: 1
                Layout.column: 1
                Layout.minimumWidth: 300

                onCurrentTextChanged: {
                    if (isChangeAvailable)
                        labelB.text = currentText
                }
            }

            Label {
                Layout.row: 2
                Layout.column: 0
                text: i18n("Icon A")
            }
            IconPicker {
                Layout.row: 2
                Layout.column: 1
                currentIcon: cfg_iconA
                defaultIcon: "weather-clear"
                    onIconChanged: cfg_iconA = iconName
                    enabled: true
            }
            Label {
                Layout.row: 3
                Layout.column: 0
                text: i18n("Icon B")
            }
            IconPicker {
                Layout.row: 3
                Layout.column: 1
                currentIcon: cfg_iconB
                defaultIcon: "weather-clear-night"
                    onIconChanged: cfg_iconB = iconName
                    enabled: true
            }
        }
    }

    Component.onCompleted: {
        executable.exec("plasma-apply-colorscheme --list-schemes | tail --lines=+2")
    }
}
