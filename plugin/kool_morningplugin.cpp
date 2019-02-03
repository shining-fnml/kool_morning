/*
 *   Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "kool_morningplugin.h"

// KF
#include <KLocalizedString>
// Qt
#include <QJSEngine>
#include <QQmlEngine>
#include <QQmlContext>

#include <QCoreApplication>
#include <QDebug>
#include <QHostInfo>
#include <QDir>

#include <arpa/inet.h>

#define MAGIC_SIZE	102

/* Stolen from https://shadesfgray.wordpress.com/2010/12/17/wake-on-lan-how-to-tutorial/ */
static void wol(in_addr_t ip_addr, void *tosend)
{
	int udpSocket;
	struct sockaddr_in udpClient, udpServer;
	int broadcast = 1;
	ssize_t sent;

	udpSocket = socket(AF_INET, SOCK_DGRAM, 0);

	/** you need to set this so you can broadcast **/
	if (setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof broadcast) == -1) {
		qDebug() << "error: setsockopt (SO_BROADCAST)";
		return;
	}
	udpClient.sin_family = AF_INET;
	udpClient.sin_addr.s_addr = INADDR_ANY;
	udpClient.sin_port = 0;

	bind(udpSocket, (struct sockaddr*)&udpClient, sizeof(udpClient));

	/** set server end point (the broadcast addres)**/
	udpServer.sin_family = AF_INET;
	udpServer.sin_addr.s_addr = htonl(ip_addr | 0xFF);
	udpServer.sin_port = htons(7);

	/** send the packet **/
	sent = sendto(udpSocket, tosend, sizeof(unsigned char) * MAGIC_SIZE, 0, (struct sockaddr*)&udpServer, sizeof(udpServer));
	if (sent != MAGIC_SIZE)
		qDebug() << "warning: sent " << sent << " bytes instead of " << MAGIC_SIZE;
}

void mac_to_magic(unsigned char *buffer, QString &mac)
{
	unsigned char address[6];
	mac.replace( ":", "" );
	mac.replace( "-", "" );
	bool check;
	for (int position=0; position<6; position++) {
		QStringRef ref = QStringRef(&mac, position*2, 2);
		address[position] = ref.toUShort(&check, 16);
		buffer[position] = 0xFF;
	}
	for (int position=1; position<17; position++) {
		unsigned char *cursor = buffer+position*6;
		memcpy((void *)cursor, address, 6);
	}
}

QStringList Logic::icons(QString path)
{
	path.remove(0, 7);
	QDir directory(path + "../images");
	if (!directory.exists()) {
		qDebug() << "directory does not exists";
		return QStringList();
	}
	QStringList files = directory.entryList(QStringList() << "*.svg" << "*.SVG",QDir::Files);
	files.replaceInStrings(".svg", "", Qt::CaseInsensitive);
	return files;

}

void Logic::wake(QString host, QString mac)
{
	unsigned char tosend[MAGIC_SIZE];

	mac_to_magic(tosend, mac);
	QHostInfo info = QHostInfo::fromName(host);
	if (info.addresses().isEmpty()) {
		qDebug() << "cannot find host " << host;
		return;
	}
	QHostAddress address = info.addresses().first();
	wol(address.toIPv4Address(), tosend);
	emit somePropertyChanged(1);
}

static QObject *singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)

	Logic *example = new Logic();
	return example;
}


void kool_morningPlugin::registerTypes(const char* uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.private.kool_morning"));

    qmlRegisterSingletonType<Logic>(uri, 1, 0, "Custom", singletontype_provider);
}
