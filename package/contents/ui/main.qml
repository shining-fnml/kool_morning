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

	// Plasmoid.fullRepresentation: ColumnLayout {
	RowLayout {
		/*
		id: son
	       Item {
		*/
		anchors.fill: parent
		       id: monster
		       Image {
			       id: phone
			       width: 64
			       height: 64
			       Layout.fillHeight: true
			       Layout.fillWidth: true
			       fillMode: Image.PreserveAspectFit
			       source: "../images/Phone.svg"
			       smooth: true
			       visible: false
			       signal clicked
			       ToolTip {
				       id: tooltip
				       // width: 300
				       font.pointSize: 12
				       text: "vicious"
				       visible: tooltip_visible
			       }
		       }
		       ColorOverlay {
			       id: co
			       anchors.fill: monster
			       // Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
			       source: phone
			       color: overlay
		       }
		       MouseArea {
			       anchors.fill: phone
			       hoverEnabled: true
			       onClicked: { phone.clicked();}
			       onPressed: { root.overlay= "#80ff00ff" }
			       onReleased: { root.overlay= "#80ffff00" }
			       onEntered: { root.tooltip_visible = true }
			       onExited: { root.tooltip_visible = false }
		       }
		       /*
		}
		*/
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
	Component.onCompleted: print("Completed Running!")
}
