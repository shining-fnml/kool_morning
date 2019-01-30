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

#include <QDebug>
#include <QCoreApplication>

#include <iostream>

void Logic::setSomeProperty(int val)
{
	std::cerr << "Logic:setSomeProperty()" << std::endl;
	qDebug() << "Logic:setSomeProperty()";
	m_someProperty = val;
	emit somePropertyChanged(val);
}

static QJSValue singletonTypeExampleProvider(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue custom = scriptEngine->newObject();
    custom.setProperty("DirPath", QCoreApplication::applicationDirPath());
    custom.setProperty("FilePath", QCoreApplication::applicationFilePath());
    return custom;
}

static QObject *example_qobject_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)

	Logic *example = new Logic();
	return example;
}


void kool_morningPlugin::registerTypes(const char* uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.private.kool_morning"));

    qmlRegisterSingletonType(uri, 1, 0, "Custom", singletonTypeExampleProvider);
    qmlRegisterSingletonType<Logic>(uri, 1, 0, "Custom", example_qobject_singletontype_provider);
}
