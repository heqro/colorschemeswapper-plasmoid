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
import org.kde.plasma.core as PlasmaCore
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents

KCM.SimpleKCM {
    id: configPage

    property alias cfg_colorA: labelA.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    property alias cfg_colorB: labelB.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    // TODO - allow the user to set them from here.
    property string cfg_iconA: configuration.iconA
    property string cfg_iconB: configuration.iconB

    property alias cfg_useExtraCommand_iconA: checkBox_iconA.checked
    property alias cfg_useExtraCommand_iconB: checkBox_iconB.checked

    property alias cfg_textField_iconA: textField_iconA.text
    property alias cfg_textField_iconB: textField_iconB.text
    property alias cfg_enableAutoSwitch: enableAutoSwitch.checked
    property alias cfg_dayStartTime: dayStartTime.text
    property alias cfg_nightStartTime: nightStartTime.text

    // HACK - this should be read from /package/contents/config/main.xml
    readonly property string default_iconA: 'semi-starred-symbolic'
    readonly property string default_iconB: 'semi-starred-symbolic-rtl'




    Plasma5Support.DataSource {
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
                // console.log("input", colors[i])
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

                currentIconName: cfg_iconA
                defaultIconName: default_iconA
                formFactor: plasmoid.formFactor

                onCurrentIconNameChanged: cfg_iconA = currentIconName
            }

            Label {
                Layout.row: 3
                Layout.column: 0
                text: i18n("Icon B")
            }

            IconPicker {
                Layout.row: 3
                Layout.column: 1

                currentIconName: cfg_iconB
                defaultIconName: default_iconB
                formFactor: plasmoid.formFactor


                onCurrentIconNameChanged: cfg_iconB = currentIconName
            }

            CheckBox {
                id: checkBox_iconA
                Layout.row: 4
                Layout.column:0
                Layout.columnSpan:2
                text: i18n('Execute the following command when changing to color A')
            }

            TextField {
                id: textField_iconA
                Layout.row: 5
                Layout.column:0
                Layout.columnSpan:2
                enabled: checkBox_iconA.checked
            }

            CheckBox {
                id: checkBox_iconB
                Layout.row: 6
                Layout.column:0
                Layout.columnSpan:2
                text: i18n('Execute the following command when changing to color B')
            }

            TextField {
                id: textField_iconB
                Layout.row: 7
                Layout.column:0
                Layout.columnSpan:2
                enabled: checkBox_iconB.checked
            }
        }

        GroupBox {
            Layout.fillWidth: true
            title: i18n("Automatic Switching")

            ColumnLayout {
                CheckBox {
                    id: enableAutoSwitch
                    text: i18n("Enable automatic switching")
                }

                GridLayout {
                    columns: 2
                    enabled: enableAutoSwitch.checked

                    Label {
                        text: i18n("Day starts at:")
                    }
                    TextField {
                        id: dayStartTime
                        placeholderText: "06:00"
                        inputMask: "99:99"
                        text: plasmoid.configuration.dayStartTime
                    }

                    Label {
                        text: i18n("Night starts at:")
                    }
                    TextField {
                        id: nightStartTime
                        placeholderText: "18:00"
                        inputMask: "99:99"
                        text: plasmoid.configuration.nightStartTime
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        executable.exec("plasma-apply-colorscheme --list-schemes | tail --lines=+2")
    }
}
