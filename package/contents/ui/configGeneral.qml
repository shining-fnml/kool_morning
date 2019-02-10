/***************************************************************************
*   Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>                            *
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 3 of the License, or
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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item
{
	id: root
	signal configurationChanged
	property var libraryModel: {[]}
	readonly property var iconModel: {
		var result = []
		for (var iter = 0; iter < foldermodel.count; iter++) {
			result.push(foldermodel.get(iter, "fileName").split(".").shift())
		}
		return result
	}
	FolderListModel {
		id: foldermodel
		folder: Qt.resolvedUrl(".") + "../images/"
		nameFilters: ["[A-Z]*.svg"]
		showDirs: false
		showOnlyReadable: true
		sortField: FolderListModel.Name
	}

	function table_update()
	{
		var position = table.currentRow
		var model_new = [ ]
		for (var iter in libraryModel) {
			model_new[iter] = libraryModel[iter]
		}
		root.libraryModel = model_new
		table.currentRow = position
		plasmoid.configuration.json = JSON.stringify(libraryModel)
		root.configurationChanged()
	}

	function saveConfig() {
		plasmoid.configuration.iconsize = iconsize.value
		plasmoid.configuration.spacing = spacing.value
	}

	function moveEntry(direction) {
		print("moveEntry()")
		var tmp = root.libraryModel[table.currentRow]
		root.libraryModel[table.currentRow] = root.libraryModel[table.currentRow+direction]
		root.libraryModel[table.currentRow+direction] = tmp
		table_update()
		table.selection.select(table.currentRow+direction)
		table.currentRow += direction
	}

	Dialog {
		id: editDialog
		title: table.currentRow == -1 ? "Add a new host" : "Edit this one"
		onAccepted: {
			if (!host.text.length) {
				return
			}
			var index = table.currentRow < 0 ? libraryModel.length : table.currentRow
			libraryModel[index] = {
				host: host.text,
				icon: icon.currentText,
				mac: mac.text,
				status: "Unknown",
				wol: wol.checked
			}
			table_update()
		}
		/*
		onAccepted: lastChosen.text = "Accepted " +
		(clickedButton == StandardButton.Ok ? "(OK)" : "(Ignore)")
		onRejected: lastChosen.text = "Rejected " +
		(clickedButton == StandardButton.Close ? "(Close)" : (clickedButton == StandardButton.Abort ? "(Abort)" : "(Cancel)"))
	        onButtonClicked: {
		       print("clicked button " + clickedButton)
	        }
		*/
		modality: Qt.WindowModal
		standardButtons: StandardButton.Ok|StandardButton.Cancel

		GridLayout {
			id: layout
			columns: 2
			property string host_start: {
				return table.currentRow < 0 ? "" : libraryModel[table.currentRow].host
			}
			property bool wol_start: {
				return table.currentRow < 0 ? false : libraryModel[table.currentRow].wol
			}
			property string mac_start: {
				return table.currentRow < 0 ? "" : libraryModel[table.currentRow].mac
			}

			PlasmaComponents.Label {
				text: i18n("Hostname or IP address:")
			}
			PlasmaComponents.TextField {
				id: host
				placeholderText: "127.0.0.1"
				text: layout.host_start
				validator:  RegExpValidator { regExp: /(^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$)|(^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$)/ }
				focus: true
			}
			PlasmaComponents.Label {
				text: i18n("Type:")
			}
			Controls2.ComboBox {
				id: icon
				model: iconModel
				focus: true
			}
			PlasmaComponents.Label {
				text: i18n("Wake on lan:")
			}
			Controls2.CheckBox {
				id: wol
				text: i18n("wol")
				checked: layout.wol_start
				focus: true
			}
			PlasmaComponents.Label {
				text: i18n("Mac address:")
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
			states: State {
				name: "folderReady"
				when: (foldermodel.status == FolderListModel.Ready)
				PropertyChanges { target: icon; currentIndex: iconModel.indexOf(table.currentRow < 0 ? "Generic" : libraryModel[table.currentRow].icon) }
			}
		}
	}

	Column{
		anchors.fill: parent
		id: climber
		spacing: 20
		Controls2.GroupBox {
			title: qsTr("Data engine")
			RowLayout {
				anchors.fill: parent
				PlasmaComponents.Label {
					text: i18n("Polling interval in seconds:")
				}
				Controls2.SpinBox {
					id: interval
					value: plasmoid.configuration.interval
					onValueModified: root.configurationChanged()
				}
			}
		}
		Controls2.GroupBox {
			title: qsTr("Icons geometry")
			RowLayout {
				anchors.fill: parent
				PlasmaComponents.Label {
					text: i18n("Spacing:")
				}
				Controls2.SpinBox {
					id: spacing
					value: plasmoid.configuration.spacing
					onValueModified: root.configurationChanged()
				}
				PlasmaComponents.Label {
					text: i18n("Size:")
				}
				Controls2.SpinBox {
					id: iconsize
					value: plasmoid.configuration.iconsize
					onValueModified: { root.configurationChanged() }
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
						width: 250
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
						id: moverUp
						icon.name: "arrow-up"
						text: i18n("Move up")
						onClicked: { moveEntry(-1) }
						enabled: table.currentRow > 0
					}
					Controls2.Button {
						id: adder
						icon.name: "entry-new"
						text: i18n("Add new host...")
						onClicked: { table.currentRow=-1; editDialog.open()}
					}
					Controls2.Button {
						id: editer
						icon.name: "entry-edit"
						text: i18n("Edit...")
						onClicked: { editDialog.open() }
						enabled: table.currentRow != -1
					}
					Controls2.Button {
						id: remover
						icon.name: "entry-delete"
						text: i18n("Remove")
						onClicked: {
							libraryModel.splice(table.currentRow, 1)
							table_update()
						}
						enabled: table.currentRow != -1
					}
					Controls2.Button {
						id: moverDown
						icon.name: "arrow-down"
						text: i18n("Move down")
						onClicked: { moveEntry(+1) }
						enabled: table.currentRow != -1 && libraryModel.length-table.currentRow > 1
					}
				}
			}
		}
	}
	Component.onCompleted: {
		var stored = plasmoid.configuration.json
		libraryModel = stored=="" ? [] : JSON.parse(plasmoid.configuration.json)
		table.currentRow = -1
	}
}
