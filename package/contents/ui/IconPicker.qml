import Kirigami

Button {
    id: iconButton

    Kirigami.FormData.label: i18n("Icon:")

    implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
    implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
    hoverEnabled: true

    Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
    Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_icon)
    Accessible.role: Accessible.ButtonMenu

    ToolTip.delay: Kirigami.Units.toolTipDelay
    ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_icon)
    ToolTip.visible: iconButton.hovered && cfg_icon.length > 0

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: cfg_icon = iconName || Tools.defaultIconName
    }

    onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

    KSvg.FrameSvgItem {
        id: previewFrame
        anchors.centerIn: parent
        imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                ? "widgets/panel-background" : "widgets/background"
        width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
        height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.large
            height: width
            source: Tools.iconOrDefault(Plasmoid.formFactor, cfg_icon)
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
            enabled: cfg_icon !== Tools.defaultIconName
            onClicked: cfg_icon = Tools.defaultIconName
        }
        MenuItem {
            text: i18nc("@action:inmenu", "Remove icon")
            icon.name: "delete"
            enabled: cfg_icon !== "" && menuLabel.text && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
            onClicked: cfg_icon = ""
        }
    }
}
