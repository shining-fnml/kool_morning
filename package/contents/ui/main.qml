/***************************************************************************
 *   Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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

Item {
	id: root

	property string status_vicious: "vicious"
	property string status_www_google_com: "google"
	property string status_www_repubblica_it: "repubblica"
	property string overlay: "#00FFFFFF"
	property bool tooltip_visible: false
	property bool tooltip_visible2: false
	property var dynamic_model

	readonly property QtObject source: PlasmaCore.DataSource {
		id: dataSource
		engine: "icmp"
		connectedSources: ["www.google.com", "www.repubblica.it", "vicious"]
		interval: 500
		onSourceAdded: {
			print("adding " + source)
			connectSource(source)
		}
		onDataChanged: {
			for (var iter in connectedSources) {
				var a_key = connectedSources[iter]
				var target = "status_" + a_key.replace(/\./g, '_');
				/*
				print(a_key + ": " + data[a_key].status)
				print("target: " + target)
				*/
				root[target] = a_key + "\n" + data[a_key].status
				if (a_key != "vicious") {
					continue
				}
				if (data[a_key].status == "Offline") {
					root.overlay= "#80ff0000"
				}
				else if (data[a_key].status == "Online") {
					root.overlay= "#8000ff00"
				}
				else {
					root.overlay= "#00ffffff"
				}
			}
		}
	}

	Row {
		id: host
		anchors.fill: parent
		Repeater {
			model: dynamic_model

			delegate:
				Image {
					id: host
					width: 64
					height: 64
					/*
					Layout.fillHeight: true
					Layout.fillWidth: true
					*/
					fillMode: Image.PreserveAspectFit
					source: "../images/" + modelData.icon
					smooth: true
					visible: true
					signal clicked
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						// onClicked: { host.clicked();}
						onClicked: { print(modelData.host) }
						onPressed: { root.overlay= "#80ff00ff" }
						onReleased: { root.overlay= "#80ffff00" }
						onEntered: { root.tooltip_visible = true }
						onExited: { root.tooltip_visible = false }
					}
					ColorOverlay {
						anchors.fill: parent
						source: parent
						color: overlay
					}
				}
		}
	}

	readonly property string site_fn: {
		var ret = "";
		var found = false;
		for (var v in dataSource.connectedSources) {
			var source = dataSource.connectedSources[v]
			ret = ret + source + "\n"
		}
		return ret
	}
	Component.onCompleted: {
		// available icons = [ "AccessPoint.svg", "Generic.svg", "Notebook.svg", "Printer.svg", "Desktop.svg", "LinuxDesktop.svg", "Phone.svg", "Router.svg" ]
		var google = { host: "www.google.com", icon: "Generic.svg", mac: "", wol: false }
		var repubblica = { host: "www.repubblica.it", icon: "Generic.svg", mac: "", wol: false }
		var vicious = { host: "vicious", icon: "LinuxDesktop.svg", mac: "", wol: false }
		dynamic_model = [ google, repubblica, vicious ]
		print("Completed Running!")
	}
}
