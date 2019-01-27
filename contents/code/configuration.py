# -*- coding: iso-8859-1 -*-
import os
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyKDE4.kdecore import *
from PyKDE4.kdecore import i18n
from PyKDE4.kdeui import *
from PyKDE4.kio import *

class ServerListEditor(QWidget):
        def __init__(self, servers = None):
                QWidget.__init__(self)
                if servers == None:
                        servers = []
                # end if

                # copied from pyuic generated
                self.gridLayout = QGridLayout(self)
                self.gridLayout.setObjectName("gridLayout")

                # todo: use tablewidget
                self.klistwidget = KListWidget(self)
                self.klistwidget.setObjectName("klistwidget")
                self.gridLayout.addWidget(self.klistwidget, 0, 0, 1, 1)
                self.verticalLayout = QVBoxLayout()
                self.verticalLayout.setObjectName("verticalLayout")
                self.AddButton = QToolButton(self)
                self.AddButton.setObjectName("AddButton")
                self.verticalLayout.addWidget(self.AddButton)
                self.EditButton = QToolButton(self)
                self.EditButton.setEnabled(False)
                self.EditButton.setCheckable(True)
                self.EditButton.setObjectName("EditButton")
                self.verticalLayout.addWidget(self.EditButton)
                self.RemoveButton = QToolButton(self)
                self.RemoveButton.setEnabled(False)
                self.RemoveButton.setCheckable(True)
                self.RemoveButton.setObjectName("RemoveButton")
                self.verticalLayout.addWidget(self.RemoveButton)
                spacerItem = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
                self.verticalLayout.addItem(spacerItem)
                self.gridLayout.addLayout(self.verticalLayout, 0, 1, 1, 1)

                self.retranslateUi()

                for s in servers:
                    self.addServer(s.name, s.ip, s.mac, s.wolEnabled)
                # end for

                self.connect(self.AddButton, SIGNAL("clicked(bool)"), self.addClicked)
                self.connect(self.RemoveButton, SIGNAL("clicked(bool)"), self.removeClicked)
                self.connect(self.EditButton, SIGNAL("clicked(bool)"), self.editClicked)
                self.connect(self.klistwidget, SIGNAL("itemSelectionChanged()"), self.selectionChanged)

        # end def __init__

        def addServer(self, name, ip, mac, wolEnabled):
            item = QListWidgetItem( name + ": " + ip )
            item.setData(32, QVariant(name))
            item.setData(33, QVariant(ip))
            item.setData(34, QVariant(mac))
            item.setData(35, QVariant(wolEnabled))
            self.klistwidget.addItem(item)
        # end def addServer

        def selectionChanged(self):
            self.RemoveButton.setEnabled(self.klistwidget.currentItem() != None)
            self.EditButton.setEnabled(self.klistwidget.currentItem() != None)
        # end def selectionChanged

        def newServerAccepted(self):
            s = self.serverEditor.getServer()
            if self.selectedRow ==None:
              self.addServer(s[0], s[1], s[2], s[3])
            else:
              name = s[0]
              ip = s[1]
              self.selectedRow.setText( name + ": " + ip )
              self.selectedRow.setData(32, QVariant(name))
              self.selectedRow.setData(33, QVariant(ip))
              self.selectedRow.setData(34, QVariant(s[2]))
              self.selectedRow.setData(35, QVariant(s[3]))

            self.newServerDenied()
        # end def configAccepted

        def newServerDenied(self):
            self.serverEditor.deleteLater()
        # end def configDenied

        @pyqtSignature("bool")
        def addClicked(self, b):
            self.showServerEditor()
        # end def addClicked

        @pyqtSignature("bool")
        def editClicked(self, b):
            self.showServerEditor( self.klistwidget.currentItem() )
        # end def editClicked

        @pyqtSignature("bool")
        def removeClicked(self, b):
            self.klistwidget.takeItem( self.klistwidget.currentRow() )

            if self.klistwidget.count() == 0:
                    self.RemoveButton.setEnabled(False)
            # end if
        # end def removeClicked

        def showServerEditor(self, row = None):
            self.selectedRow = row
            dialog = KDialog()
            dialog.setButtons(KDialog.ButtonCode(KDialog.Ok | KDialog.Cancel))
            self.serverEditor = ServerEditor()
            dialog.setMainWidget(self.serverEditor)
            if row != None:
              self.serverEditor.setServer(self.getCells(row))

            self.connect(dialog, SIGNAL("okClicked()"), self.newServerAccepted)
            self.connect(dialog, SIGNAL("cancelClicked()"), self.newServerDenied)

            dialog.resize(300,200)
            dialog.exec_()
        #end showDialog

        def getCells(self, row):
          return (row.data(32).toString().__str__(), row.data(33).toString().__str__(), row.data(34).toString().__str__(), row.data(35).toBool())

        def getServers(self):
          s = []
          for row in range(self.klistwidget.count()):
            i = self.klistwidget.item(row)
            s.append(self.getCells(i))
          # end for

          return s
        # end def getServers

        def retranslateUi(self):
          self.AddButton.setText(i18n("Add ..."))
          self.EditButton.setText(i18n("Edit ..."))
          self.RemoveButton.setText(i18n("Remove"))
        # end def retranslateUi
# end class FilterEditor

class ServerEditor(QWidget):
    def __init__(self):
        QWidget.__init__(self)

        # copied from pyuic generated
        self.gridLayout_2 = QGridLayout(self)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.gridLayout = QGridLayout()
        self.gridLayout.setObjectName("gridLayout")
        self.label = QLabel(self)
        self.label.setObjectName("label")
        self.gridLayout.addWidget(self.label, 0, 0, 1, 1)
        self.lineEditName = QLineEdit(self)
        self.lineEditName.setObjectName("lineEdit")
        self.gridLayout.addWidget(self.lineEditName, 0, 1, 1, 1)
        self.label_3 = QLabel(self)
        self.label_3.setObjectName("label_3")
        self.gridLayout.addWidget(self.label_3, 1, 0, 1, 1)
        self.lineEditIp = QLineEdit(self)
        self.lineEditIp.setObjectName("lineEdit_3")
        self.gridLayout.addWidget(self.lineEditIp, 1, 1, 1, 1)
        self.checkBox = QCheckBox(self)
        self.checkBox.setObjectName("checkBox")
        self.gridLayout.addWidget(self.checkBox, 2, 0, 1, 1)
        self.label_2 = QLabel(self)
        self.label_2.setObjectName("label_2")
        self.gridLayout.addWidget(self.label_2, 3, 0, 1, 1)
        self.lineEditMac = QLineEdit(self)
        self.lineEditMac.setObjectName("lineEdit_2")
        self.gridLayout.addWidget(self.lineEditMac, 3, 1, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)
        spacerItem = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
        self.gridLayout_2.addItem(spacerItem, 1, 0, 1, 1)

        self.retranslateUi()
        #self.connect(self.AddButton, SIGNAL("clicked(bool)"), self.addClicked)
        #self.connect(self.RemoveButton, SIGNAL("clicked(bool)"), self.removeClicked)
        #self.connect(self.klistwidget, SIGNAL("itemSelectionChanged()"), self.selectionChanged)
        # end def __init__
    # end def __init__

    def retranslateUi(self):
        self.label.setText(i18n("Name"))
        self.label_3.setText(i18n("IP or hostname"))
        self.checkBox.setText(i18n("Enable Wak-On-Lan"))
        self.label_2.setText(i18n("MAC-Address"))
    # end def retranslateUi

    def getServer(self):
        return (self.lineEditName.text(), self.lineEditIp.text(), self.lineEditMac.text(), self.checkBox.isChecked())
    # end def getServer

    def setServer(self, row):
        self.lineEditName.setText(row[0])
        self.lineEditIp.setText(row[1])
        self.lineEditMac.setText(row[2])
        self.checkBox.setChecked(row[3])
    # end def setServer

# end class ServeEditor

