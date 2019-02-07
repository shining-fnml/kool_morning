/***************************************************************************
 *   Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kool_morning 1.0

Item {
	id: root

	property int clicked_pointer: -1
	property var dynamic_model: JSON.parse(plasmoid.configuration.json)
	property int tooltip_pointer: -1
	property int exitCode: -1
	readonly property string item_dir: Qt.resolvedUrl(".")

	/* This unused property is the only way I've found so far to force the update of dynamic_model */
	readonly property bool forced_update: {
		print("forced_update")
		var model_new = [ ]
		if (plasmoid.configuration.json != "") {
			var parsed = JSON.parse(plasmoid.configuration.json)
			for (var iter in parsed) {
				model_new[iter] = parsed[iter]
			}
		}
		root.dynamic_model = model_new
		return true
	}
	function dynamic_model_update()
	{
		var model_new = [ ]
		for (var iter in dynamic_model) {
			var current = root.dynamic_model[iter]
			model_new[iter] = { host: current.host, icon: current.icon, mac: current.mac, status: current.status, wol: current.wol }
		}
		root.dynamic_model = model_new
	}
	PlasmaCore.DataSource {
		property string installationCommand: ""
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: {
			if (sourceName == installationCommand) {
				exitCode = data["exit code"]
			}
			disconnectSource(sourceName)
		}

		/*
		function exec(cmd) {
			var path = item_dir.replace(/file:\/\//, '') + "../scripts/" + cmd
			print("exec: " + path)
			connectSource(path)
		}
		*/
		function icmpinstall() {
			var path = item_dir.replace(/file:\/\//, '') + "../scripts/icmpinstall.sh"
			installationCommand = "konsole -e " + path
			connectSource(installationCommand)
		}
	}
	readonly property QtObject source: PlasmaCore.DataSource {
		id: dataSource
		engine: "icmp"
		connectedSources: {
			var result = [ ]
			for (var iter in dynamic_model) {
				result[iter] = dynamic_model[iter].host
			}
			return result
		}
		interval: plasmoid.configuration.interval * 1000
		onSourceAdded: {
			connectSource(source)
		}
		onDataChanged: {
			for (var iter in connectedSources) {
				var a_key = connectedSources[iter]
				root.dynamic_model[iter].status = data[a_key].status
			}
			dynamic_model_update()
		}
	}
	readonly property bool icmpReady: dataSource.valid

	ColumnLayout{
		visible: !icmpReady && exitCode!=0
		Text {
			text: i18n("icmp engine not working")
		}
		PlasmaComponents.Button {
			iconSource: "run-build-install-root"
			text: i18nc("@action:button", "Install ICMP engine...")
			onClicked: executable.icmpinstall()
		}
	}
	Text {
		visible: !icmpReady && !exitCode
		text: i18n("icmp engine installation completed.\nRestart plasma shell with the following commands in a terminal:\nkbuildsycoca5 && kquitapp5 plasmashell && kstart5 plasmashell")
	}
	PlasmaComponents.Button {
		anchors.centerIn: parent
		iconSource: "configure"
		text: i18nc("@action:button", "Configure...")
		visible: icmpReady && dynamic_model.length < 1
		onClicked: plasmoid.action("configure").trigger();
	}
	Flow {
		id: host
		anchors.fill: parent
		spacing: plasmoid.configuration.spacing
		visible: icmpReady && dynamic_model.length > 0
		Repeater {
			model: dynamic_model

			delegate:
				PlasmaCore.SvgItem {
					id: host
					width: plasmoid.configuration.iconsize
					height: plasmoid.configuration.iconsize
					// fillMode: Image.PreserveAspectFit
					elementId: modelData.status
					svg: PlasmaCore.Svg { imagePath: item_dir + "../images/" + modelData.icon + ".svg" }
					smooth: true
					visible: true
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						onPressed: {
							if (modelData.status=="Offline" && modelData.wol) {
								root.clicked_pointer = index } }
						onReleased: {
							if (modelData.status=="Offline" && modelData.wol) {
								Custom.wake(modelData.host, modelData.mac) }
							root.clicked_pointer = -1 }
						onEntered: { root.tooltip_pointer = index }
						onExited: { root.tooltip_pointer = -1 }
					}
					ToolTip {
						visible: root.tooltip_pointer == index
						text: modelData.host + (modelData.status=="Offline" && modelData.wol ? " " + modelData.mac : "")
						delay: 250
					}
					ColorOverlay {
						anchors.fill: parent
						source: parent
						color: { return root.clicked_pointer == index ? "#40ffff00" : "transparent" }
					}
				}
		}
	}
	Component.onCompleted: {
		Custom.someProperty = 2
	}
}
