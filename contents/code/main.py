# -*- coding: utf-8 -*-
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyKDE4.kdeui import *
from PyKDE4.plasma import Plasma
from PyKDE4 import plasmascript
from PyKDE4.kdecore import i18n
from math import *
from wol import *
from configuration import *

import time

class Server:
  def __init__(self, parent, name, ip, mac, wolEnabled):
    self.name = name
    self.ip = ip
    self.mac = mac
    self.parent = parent
    self.button = Plasma.IconWidget(self.parent)
    self.wolEnabled = wolEnabled

    self.iconUnknown = KIcon("user-offline")
    self.iconOnline = KIcon("user-online")
    self.iconOffline = KIcon("user-busy")

    self.status = "Unknown"

    self.refreshUI()

  # end def __init__

  def toggle(self):
    wake_on_lan(self.mac)
  # end def toggle

  def close(self):
    self.button.close()
    self.button = None
  # end def close

  def refresh(self, sourceName, data):
    if sourceName != QString( self.ip ):
      return
    self.status = data[QString("status")]
    self.refreshUI()

  def refreshUI(self):
    msg = self.ip + "\n" + self.mac

    if self.status == 'Offline':
        self.button.setIcon(self.iconOffline)
        if self.wolEnabled:
            msg + "\n\n Click to wake up the server." 
        # end if
    elif self.status == 'Online':
        self.button.setIcon(self.iconOnline)
    else:
        self.button.setIcon(self.iconUnknown)
    # end if

    #And update tooltip's description
    tt = Plasma.ToolTipContent(i18n(self.name), msg)
    Plasma.ToolTipManager.self().setContent(self.button, tt)
  # end def refreshUI
# end class Server
 
class WakeOnLanApplet(plasmascript.Applet):
    def __init__(self, parent, args=None):
        plasmascript.Applet.__init__(self, parent)
    # end def __init__

    def readServers(self):
    
        fc = self.config().group("servers")
        (count, bummer) = fc.readEntry("count", QVariant(0) ).toInt()
        if count > 0:
                s = []
                for i in range(0, count):
                        cc = fc.group("_" + str(i) )
                        name = cc.readEntry("Name", QVariant("")).toString().__str__()
                        ip = cc.readEntry("Ip", QVariant("")).toString().__str__()
                        mac = cc.readEntry("MAC", QVariant("") ).toString().__str__()
                        wol = cc.readEntry("wol", QVariant(True) ).toBool()
                        s.append(Server(self.applet, name, ip, mac, wol))
                # end for
                print "Servers read from config: "
                print len(s)
                return s
        else:
                s0 = Server(self.applet, "KDE Homepage", "www.kde.org", "", False)
                return [s0]
        # end if
    # end def readServers

    def init(self):
        self.setAspectRatioMode(Plasma.KeepAspectRatio)
        self.setBackgroundHints(Plasma.Applet.DefaultBackground)

        self.resize(200, 150)

        self.setHasConfigurationInterface(True)
        self.theme = Plasma.Svg(self)
        self.theme.setImagePath('widgets/background')

        self.layout = QGraphicsGridLayout(self.applet)
        self.layout.setContentsMargins(0,0,0,0)
        self.setMinimumSize(10,10)

        self.pingEngine = self.dataEngine("icmp")
        self.servers = []
        self.reloadServers()

        
        self.refreshAll()
    # end def init

    def reloadServers(self, servers = None):

        for s in self.servers:
          s.close()
        # end for
          
        if servers is None:
          self.servers = self.readServers()
        else:
          self.servers = servers[:]
        # end if

        while self.layout.count() > 0:
            self.layout.removeAt(0)
        # end while
            
        x = 0
        y = 0
        maxLevel = sqrt(len(self.servers))

        for server in self.servers:
            self.layout.addItem(server.button, x, y)
            self.pingEngine.connectSource(server.ip, self, 6000)
            if server.wolEnabled:
                QObject.connect(server.button, SIGNAL('clicked()'), server.toggle)
            # end if
            x += 1
            if x >= maxLevel:
                x = 0
                y += 1
            # end if
        # end for
    # end def reloadServers

    def refreshAll(self):
        for server in self.servers:
            server.refreshUI()
        # end for
    # end def refreshAll

    def configAccepted(self):
      # todo: save to config
      newServerList = []
      for t in self.serverEditor.getServers():
        newServerList.append(Server(self.applet, t[0], t[1], t[2], t[3]))
      # end for

      self.saveServers(newServerList)
      # end for

      self.reloadServers(newServerList)
      self.configDenied()
    # end def configAccepted

    def saveServers(self, servers):
        counter = 0
        fc = self.config().group("servers")
        fc.writeEntry("count", QVariant( len(servers) ) )
        for server in servers:
                cc = fc.group("_" + str(counter) )
                cc.writeEntry("Name", QVariant( server.name) )
                cc.writeEntry("Ip", QVariant(server.ip) )
                cc.writeEntry("MAC", QVariant(server.mac) )
                cc.writeEntry("wol", QVariant(server.wolEnabled) )
                counter += 1
        # end for
    # end def saveServers

    def configDenied(self):
        self.serverEditor.deleteLater()
    # end def configDenied

    def createConfigurationInterface(self, parent):
        self.serverEditor = ServerListEditor(self.servers)
        p = parent.addPage(self.serverEditor, i18n("Server list") )
        p.setIcon( KIcon("network-server") )

        self.connect(parent, SIGNAL("okClicked()"), self.configAccepted)
        self.connect(parent, SIGNAL("cancelClicked()"), self.configDenied)
    # end def createConfigurationInterface

    def showConfigurationInterface(self):
        dialog = KPageDialog()
        dialog.setFaceType(KPageDialog.List)
        dialog.setButtons(KDialog.ButtonCode(KDialog.Ok | KDialog.Cancel))
        self.createConfigurationInterface(dialog)
        dialog.resize(450,300)
        dialog.exec_()
    # end def showConfigurationInterface

    @pyqtSignature("dataUpdated(const QString &, const Plasma::DataEngine::Data &)")
    def dataUpdated(self, sourceName, data):
        for s in self.servers:
            s.refresh(sourceName, data);

# end class WakeOnLanApplet
    

def CreateApplet(parent):
    return WakeOnLanApplet(parent)
# end def CreateApplet


