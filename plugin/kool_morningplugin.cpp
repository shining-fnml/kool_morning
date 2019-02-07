/*
 *   Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3, or
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
#include <QDir>

#include <arpa/inet.h>

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
