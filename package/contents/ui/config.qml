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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import "code/tools.js" as Tools

KCM.SimpleKCM {
    id: configPage

    property alias cfg_colorA: labelA.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    property alias cfg_colorB: labelB.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    // TODO - allow the user to set them from here.
    property string cfg_iconA: configuration.iconA
    property string cfg_iconB: configuration.iconB


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

            Button {
                id: iconButton_A

                Kirigami.FormData.label: i18n("Icon:")

                implicitWidth: previewFrame_A.width + Kirigami.Units.smallSpacing * 2
                implicitHeight: previewFrame_A.height + Kirigami.Units.smallSpacing * 2
                hoverEnabled: true

                Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
                Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_iconA)
                Accessible.role: Accessible.ButtonMenu

                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_iconA)
                ToolTip.visible: cfg_iconA.length > 0 && iconButton_A.hovered

                KIconThemes.IconDialog {
                    id: iconDialog_A
                    onIconNameChanged: cfg_iconA = iconName || Tools.defaultIconName
                }

                onPressed: iconMenu_A.opened ? iconMenu_A.close() : iconMenu_A.open()

                KSvg.FrameSvgItem {
                    id: previewFrame_A
                    anchors.centerIn: parent
                    imagePath: plasmoid.formFactor === PlasmaCore.Types.Vertical || plasmoid.formFactor === PlasmaCore.Types.Horizontal
                            ? "widgets/panel-background" : "widgets/background"
                    width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                    height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.large
                        height: width
                        source: Tools.iconOrDefault(plasmoid.formFactor, cfg_iconA)
                    }
                }

                Menu {
                    id: iconMenu_A

                    // Appear below the button
                    y: +parent.height

                    MenuItem {
                        text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                        icon.name: "document-open-folder"
                        Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                        onClicked: iconDialog_A.open()
                    }
                    MenuItem {
                        text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                        icon.name: "edit-clear"
                        enabled: cfg_iconA !== Tools.defaultIconName
                        onClicked: cfg_iconA = Tools.defaultIconName
                    }
                    MenuItem {
                        text: i18nc("@action:inmenu", "Remove icon")
                        icon.name: "delete"
                        enabled: cfg_iconA !== "" //&& menuLabel.text && plasmoid.formFactor !== PlasmaCore.Types.Vertical
                        onClicked: cfg_iconA = ""
                    }
                }
            }
            Label {
                Layout.row: 3
                Layout.column: 0
                text: i18n("Icon B")
            }
            Button {
                id: iconButton_B

                Kirigami.FormData.label: i18n("Icon:")

                implicitWidth: previewFrame_B.width + Kirigami.Units.smallSpacing * 2
                implicitHeight: previewFrame_B.height + Kirigami.Units.smallSpacing * 2
                hoverEnabled: true

                Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
                Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_iconB)
                Accessible.role: Accessible.ButtonMenu

                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_iconB)
                ToolTip.visible: cfg_iconB.length > 0 && iconButton_B.hovered

                KIconThemes.IconDialog {
                    id: iconDialog_B
                    onIconNameChanged: cfg_iconB = iconName || Tools.defaultIconName
                }

                onPressed: iconMenu_B.opened ? iconMenu_B.close() : iconMenu_B.open()

                KSvg.FrameSvgItem {
                    id: previewFrame_B
                    anchors.centerIn: parent
                    imagePath: plasmoid.formFactor === PlasmaCore.Types.Vertical || plasmoid.formFactor === PlasmaCore.Types.Horizontal
                            ? "widgets/panel-background" : "widgets/background"
                    width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                    height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.large
                        height: width
                        source: Tools.iconOrDefault(plasmoid.formFactor, cfg_iconB)
                    }
                }

                Menu {
                    id: iconMenu_B

                    // Appear below the button
                    y: +parent.height

                    MenuItem {
                        text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                        icon.name: "document-open-folder"
                        Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                        onClicked: iconDialog_B.open()
                    }
                    MenuItem {
                        text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                        icon.name: "edit-clear"
                        enabled: cfg_iconB !== Tools.defaultIconName
                        onClicked: cfg_iconB = Tools.defaultIconName
                    }
                    MenuItem {
                        text: i18nc("@action:inmenu", "Remove icon")
                        icon.name: "delete"
                        enabled: cfg_iconB !== "" //&& menuLabel.text && plasmoid.formFactor !== PlasmaCore.Types.Vertical
                        onClicked: cfg_iconB = ""
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        executable.exec("plasma-apply-colorscheme --list-schemes | tail --lines=+2")
    }
}
