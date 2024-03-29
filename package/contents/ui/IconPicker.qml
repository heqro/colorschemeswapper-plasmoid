import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.iconthemes as KIconThemes
import org.kde.ksvg as KSvg


import "code/tools.js" as Tools

Button {
    id: iconButton

    required property string currentIconName
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
        onIconNameChanged: currentIconName = iconName || Tools.defaultIconName
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
            source: Tools.iconOrDefault(formFactor, currentIconName)
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
            enabled: currentIconName !== Tools.defaultIconName
            onClicked: currentIconName = Tools.defaultIconName
        }
    }
}
