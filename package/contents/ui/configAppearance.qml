/*
*  Copyright 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.2
// import QtQuick.Controls 2.2 as Controls
import QtQuick.Controls 1.2 as Controls
import QtQuick.Controls 2.2 as Controls2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Dialogs 1.2

Item
{
	id: root
	signal configurationChanged
	property var libraryModel: ({})

	function saveConfig() {
		print("uniq: "+JSON.stringify(libraryModel))
		var line = []
		for(var i in libraryModel) {
			line = JSON.stringify(libraryModel[i])
			print("json[" + i + "]: "+ line)
		}
		plasmoid.configuration.json = line
		/*
		 var names = []
		 for(var i in layout.children) {
			 var cur = layout.children[i]
			 if (cur.checked)
			 names.push(cur.name)
		 }
		 plasmoid.configuration.key = names
		 */
	}

	Dialog {
		id: editDialog
		title: table.currentRow == -1 ? "Add a new host" : "Edit this one"
		onAccepted: lastChosen.text = "Accepted " +
		(clickedButton == StandardButton.Ok ? "(OK)" : "(Ignore)")
		onRejected: lastChosen.text = "Rejected " +
		(clickedButton == StandardButton.Close ? "(Close)" : (clickedButton == StandardButton.Abort ? "(Abort)" : "(Cancel)"))
		modality: Qt.WindowModal
		onButtonClicked: console.log("clicked button " + clickedButton)
		standardButtons: StandardButton.Ok|StandardButton.Cancel

		/*
		 PlasmaComponents.Label {
			 text: "Hello world! " + table.currentRow
		 }
		 */
		GridLayout {
			columns: 2
			PlasmaComponents.Label {
				text: "Host:"
			}
			PlasmaComponents.TextField {
				id: host
				placeholderText: "hostname or ip address"
				text: table.currentRow < 0 ? "" : libraryModel[table.currentRow].host
			}
			PlasmaComponents.Label {
				text: "Type:"
			}
			PlasmaComponents.TextField {
				id: icon
				placeholderText: "icon"
				text: table.currentRow < 0 ? "" : libraryModel[table.currentRow].icon
			}
			PlasmaComponents.Label {
				text: "Wake on lane:"
			}
			PlasmaComponents.TextField {
				id: wol
				placeholderText: "wol"
				text: table.currentRow < 0 ? "" : libraryModel[table.currentRow].wol
			}
			PlasmaComponents.Label {
				text: "Mac address:"
			}
			PlasmaComponents.TextField {
				id: mac
				placeholderText: "mac"
				text: table.currentRow < 0 ? "" : libraryModel[table.currentRow].mac
			}
		}
	}

	Column{
		anchors.fill: parent
		id: climber
		Controls.TableView {
			id: table
			width: climber.width
			Controls.TableViewColumn {
				title: "Host"
				role: "host"
			}
			Controls.TableViewColumn {
				title: "Icon"
				role: "icon"
			}
			Controls.TableViewColumn {
				title: "wol"
				role: "wol"
				width: 50
			}
			Controls.TableViewColumn {
				title: "mac"
				role: "mac"
			}
			model: libraryModel
		}
		Controls2.Button {
			id: adder
			icon.name: "entry-new"
			// text: plasmoid.configuration.uuid
			text: "Add new host"
			onClicked: { table.currentRow=-1; editDialog.open()}
		}
		Controls2.Button {
			id: editer
			// text: plasmoid.configuration.uuid
			icon.name: "entry-edit"
			text: "Edit selected host"
			onClicked: { editDialog.open() }
			enabled: table.currentRow != -1
		}
	}
	/*
	 ColumnLayout {
		 visible: false
		 id: layout
		 Controls.CheckBox {
			 Layout.fillWidth: true
			 readonly property string name: "Caps Lock"
			 checked: plasmoid.configuration.key.indexOf(name) >= 0
			 text: i18nc("@option:check", "Caps Lock")
			 onCheckedChanged: root.configurationChanged()
		 }
		 Controls.CheckBox {
			 Layout.fillWidth: true
			 readonly property string name: "Num Lock"
			 checked: plasmoid.configuration.key.indexOf(name) >= 0
			 text: i18nc("@option:check", "Num Lock")
			 onCheckedChanged: root.configurationChanged()
		 }
	 }
	 */
	Component.onCompleted: {
		libraryModel = [
			{ host: "doraemon", icon: "comic", wol: true, mac: "unknown" },
			{ host: "scilla", icon: "accesspoint", wol: false, mac: "defined" }
		]
		table.currentRow = -1
	}
}
