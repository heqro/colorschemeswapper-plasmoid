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
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg


Button {
    id: iconButton

    required property string currentIconName
    required property string defaultIconName
    required property var formFactor

    Kirigami.FormData.label: i18n("Icon:")

    implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
    implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
    hoverEnabled: true

    Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
    Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", currentIconName)
    Accessible.role: Accessible.ButtonMenu

    ToolTip.delay: Kirigami.Units.toolTipDelay
    ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", currentIconName)
    ToolTip.visible: iconButton.hovered && currentIconName.length > 0

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: currentIconName = iconName || defaultIconName
    }

    onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

    KSvg.FrameSvgItem {
        id: previewFrame
        anchors.centerIn: parent
        imagePath: formFactor === PlasmaCore.Types.Vertical || formFactor === PlasmaCore.Types.Horizontal
                ? "widgets/panel-background" : "widgets/background"
        width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
        height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.large
            height: width
            source: iconOrDefault(currentIconName)
        }
    }

    Menu {
        id: iconMenu

        // Appear below the button
        y: +parent.height

        MenuItem {
            text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
            icon.name: "document-open-folder"
            Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
            onClicked: iconDialog.open()
        }
        MenuItem {
            text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
            icon.name: "edit-clear"
            enabled: currentIconName !== defaultIconName
            onClicked: currentIconName = defaultIconName
        }
    }

    function iconOrDefault(preferredIconName) {
        // Vertical panels must have an icon, at least a default one.
        return (formFactor === PlasmaCore.Types.Vertical && preferredIconName === "")
            ? defaultIconName : preferredIconName;
    }
}
