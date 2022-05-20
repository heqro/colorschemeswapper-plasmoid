/*
 * Copyright (C) 2019 by Piotr Markiewicz p.marki@wp.pl>
 * 
 * Credits to Norbert Eicker <norbert.eicker@gmx.de>
 * https://github.com/neicker/on-off-switch
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
import QtQuick.Controls 1.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
 
    // TODO - detect external color scheme change

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: { 
//             if (checked && data['exit code'] != 0) {
//                 checked = false;
//             }
            
            disconnectSource(sourceName)
        }
        
        function exec(cmd) {
            connectSource(cmd)
        }

        function swapColorScheme() {
            var colorSchemeName = Plasmoid.configuration.checked ? Plasmoid.configuration.colorB : Plasmoid.configuration.colorA
            exec("plasma-apply-colorscheme " + colorSchemeName)
        }
    }
    
    Plasmoid.compactRepresentation: RowLayout {
        id: mainItem
        spacing: 0
        Item {
            Layout.fillWidth: true
        }
        PlasmaCore.IconItem {
            id: icon
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: Plasmoid.configuration.checked ? Plasmoid.configuration.iconA : Plasmoid.configuration.iconB
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    executable.swapColorScheme()
                    Plasmoid.configuration.checked = !Plasmoid.configuration.checked
                }
            }
        }
    }
}
