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

    property alias cfg_colorA: cBoxA.currentText
    property alias cfg_colorB: cBoxB.currentText
    // TODO - allow the user to set them from here.
    //property alias cfg_iconA:
    //property alias cfg_iconB:
    

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        signal colorsListReady(var colors)

        function exec(cmd) {
            connectSource(cmd)
        }

        onNewData: {
            var colors = data["stdout"].split("\n")
            for (var i = 0; i < colors.length; i++) // parse command output
                colors[i] = colors[i].substring(3).replace(" (current color scheme)", "")
            colorsListReady(colors)
            disconnectSource(sourceName) // cmd finished
        }

    }

    Connections {
        target: executable
        onColorsListReady: {
            cBoxA.model = colors
            cBoxB.model = colors
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
                Layout.row: 0
                Layout.column: 1
                Layout.minimumWidth: 300
            }
            Label {
                Layout.row :1
                Layout.column: 0
                text: i18n("Color B")
            }
            ComboBox {
                id: cBoxB
                Layout.row: 1
                Layout.column: 1
                Layout.minimumWidth: 300
            }
        }   
    }

    Component.onCompleted: {
        console.log("Completo")
        executable.exec("plasma-apply-colorscheme --list-schemes | tail --lines=+2")
    }
}
