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
import QtQuick.Controls 1.2 as Controls
import QtQuick.Controls 2.2 as Controls2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Dialogs 1.2

import org.kde.plasma.private.kool_morning 1.0

Item
{
	id: root
	signal configurationChanged
	property var libraryModel: {[]}
	readonly property var iconModel: { return Custom.icons(Qt.resolvedUrl(".")) }

	function table_update()
	{
		var model_new = [ ]
		for (var iter in libraryModel) {
			model_new[iter] = libraryModel[iter]
		}
		root.libraryModel = model_new
	}

	function saveConfig() {
		plasmoid.configuration.iconsize = iconsize.value
		plasmoid.configuration.spacing = spacing.value
	}

	function saveTarget() {
		plasmoid.configuration.json = JSON.stringify(libraryModel)
		root.configurationChanged()
	}

	Dialog {
		id: editDialog
		title: table.currentRow == -1 ? "Add a new host" : "Edit this one"
		onAccepted: {
			var index = table.currentRow < 0 ? libraryModel.length : table.currentRow
			libraryModel[index] = {
				host: host.text,
				icon: icon.currentText,
				mac: mac.text,
				status: "Unknown",
				wol: wol.checked
			}
			table_update()
			saveTarget()
		}
		/*
		onAccepted: lastChosen.text = "Accepted " +
		(clickedButton == StandardButton.Ok ? "(OK)" : "(Ignore)")
		onRejected: lastChosen.text = "Rejected " +
		(clickedButton == StandardButton.Close ? "(Close)" : (clickedButton == StandardButton.Abort ? "(Abort)" : "(Cancel)"))
		onButtonClicked: print("clicked button " + clickedButton)
		*/
		modality: Qt.WindowModal
		standardButtons: StandardButton.Ok|StandardButton.Cancel

		GridLayout {
			id: layout
			columns: 2
			property string host_start: {
				return table.currentRow < 0 ? "" : libraryModel[table.currentRow].host
			}
			property string icon_start: {
				return iconModel.indexOf(table.currentRow < 0 ? "Generic" : libraryModel[table.currentRow].icon)
			}
			property bool wol_start: {
				return table.currentRow < 0 ? false : libraryModel[table.currentRow].wol
			}
			property string mac_start: {
				return table.currentRow < 0 ? "" : libraryModel[table.currentRow].mac
			}

			PlasmaComponents.Label {
				text: "Hostname or IP address:"
			}
			PlasmaComponents.TextField {
				id: host
				placeholderText: "127.0.0.1"
				text: layout.host_start
				focus: true
			}
			PlasmaComponents.Label {
				text: "Type:"
			}
			Controls2.ComboBox {
				id: icon
				currentIndex: layout.icon_start
				model: iconModel
				focus: true
			}
			PlasmaComponents.Label {
				text: "Wake on lan:"
			}
			Controls2.CheckBox {
				id: wol
				text: i18n("wol")
				checked: layout.wol_start
				focus: true
			}
			PlasmaComponents.Label {
				text: "Mac address:"
			}
			PlasmaComponents.TextField {
				id: mac
				placeholderText: "00:00:00:00:00:00"
				text: layout.mac_start
				enabled: wol.checked
				validator:  RegExpValidator { regExp: /[0-9a-fA-F]{2}[:-]?[0-9a-fA-F]{2}[:-]?[0-9a-fA-F]{2}[:-]?[0-9a-fA-F]{2}[:-]?[0-9a-fA-F]{2}[:-]?[0-9a-fA-F]{2}/ }
				onAccepted: print("Good")
				focus: true
			}
		}
	}

	Column{
		anchors.fill: parent
		id: climber
		spacing: 5
		Controls2.GroupBox {
			title: qsTr("Icons geometry")
			RowLayout {
				anchors.fill: parent
				PlasmaComponents.Label {
					text: "Spacing:"
				}
				Controls.SpinBox {
					id: spacing
					value: plasmoid.configuration.spacing
				}
				PlasmaComponents.Label {
					text: "Size:"
				}
				Controls.SpinBox {
					id: iconsize
					value: plasmoid.configuration.iconsize
				}
			}
		}
		Controls2.GroupBox {
			width: parent.width
			title: qsTr("Targets")
			Column {
				anchors.fill: parent
				Controls.TableView {
					id: table
					width: parent.width
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
				Row {
					width: parent.width
					Controls2.Button {
						id: adder
						icon.name: "entry-new"
						text: "Add new host"
						onClicked: { table.currentRow=-1; editDialog.open()}
					}
					Controls2.Button {
						id: editer
						icon.name: "entry-edit"
						text: "Edit selected host"
						onClicked: { editDialog.open() }
						enabled: table.currentRow != -1
					}
				}
			}
		}
	}
	Component.onCompleted: {
		var stored = plasmoid.configuration.json
		libraryModel = stored=="" ? [] : JSON.parse(plasmoid.configuration.json)
		print("icons: " + iconModel);
	}
}
