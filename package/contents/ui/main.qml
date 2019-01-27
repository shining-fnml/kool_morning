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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: root

	property string status_www_google_com: "google"
	property string status_www_repubblica_it: "repubblica"

	readonly property QtObject source: PlasmaCore.DataSource {
		id: dataSource
		engine: "icmp"
		connectedSources: ["www.google.com", "www.repubblica.it"]
		interval: 500
		/*
		connectedSources: ["Local"]
 */
		onSourceAdded: {
			connectSource(source)
		}
		onDataChanged: {
			for (var iter in connectedSources) {
				var a_key = connectedSources[iter]
				print(a_key + ": " + data[a_key].status)
				var target = "status_" + a_key.replace(/\./g, '_');
				print("target: " + target)
				root[target] = a_key + "\n" + data[a_key].status
			}
		}
	}

	// Plasmoid.fullRepresentation: ColumnLayout {
	Row {
		id: son
		anchors.fill: parent
		/*
		Image {
			Layout.fillHeight: true
			Layout.fillWidth: true
			fillMode: Image.PreserveAspectFit
			source: "../images/pairs.svgz"
		}
		*/
		PlasmaComponents.Label {
			Layout.alignment: Qt.AlignCenter
			text: status_www_google_com
		}
		PlasmaComponents.Label {
			Layout.alignment: Qt.AlignCenter
			text: status_www_repubblica_it
		}
		PlasmaComponents.Button {
			text: "This is a button!"
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

	/*
	readonly property string status_fn: {
		var ret = "";
		var found = false;
		for (var v in dataSource.connectedSources) {
			var a_key = connectedSources[iter]
			var value = dataSource.data[a_key].status
			print("status_fn: " + value)
			ret = ret + value + "\n"
		}
		return ret
	}
	*/
}
