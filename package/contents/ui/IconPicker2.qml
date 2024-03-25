/*
 * IconPicker taken from Redshift Control applet by Martin Kotelnik:
 * https://github.com/kotelnik/plasma-applet-redshift-control
 * 
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kquickcontrolsaddons as KQuickAddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Button {
    id: iconButton

    property string currentIcon
    property string defaultIcon

    signal iconChanged(string iconName)

    Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
    Layout.maximumWidth: Layout.minimumWidth
    Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
    Layout.maximumHeight: Layout.minimumWidth

    KQuickAddons.IconDialog {
        id: iconDialog
        onIconNameChanged: {
            iconPreview.source = iconName
            iconChanged(iconName)
        }
    }

    // just to provide some visual feedback, cannot have checked without checkable enabled
    checkable: true
    onClicked: {
        checked = Qt.binding(function() { // never actually allow it being checked
            return iconMenu.status === PlasmaComponents.DialogStatus.Open
        })

        iconMenu.open(0, height)
    }

    KSvg.FrameSvgItem {
        id: previewFrame
        anchors.centerIn: parent
        imagePath: location === PlasmaCore.Types.Vertical || location === PlasmaCore.Types.Horizontal
                    ? "widgets/panel-background" : "widgets/background"
        width: units.iconSizes.medium   + fixedMargins.left + fixedMargins.right
        height: units.iconSizes.medium  + fixedMargins.top + fixedMargins.bottom

        Kirigami.IconItem {
            id: iconPreview
            anchors.centerIn: parent
            width: units.iconSizes.medium  
            height: width
            source: currentIcon
        }
    }

    function setDefaultIcon() {
        iconPreview.source = defaultIcon
        iconChanged(defaultIcon)
    }

    // QQC Menu can only be opened at cursor position, not a random one
    PlasmaComponents.ContextMenu {
        id: iconMenu
        visualParent: iconButton

        PlasmaComponents.MenuItem {
            text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
            icon: "document-open-folder"
            onClicked: iconDialog.open()
        }
        PlasmaComponents.MenuItem {
            text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
            icon: "edit-clear"
            onClicked: setDefaultIcon()
        }
    }
}
 
