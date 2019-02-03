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

#ifndef KOOL_MORNINGPLUGIN_H
#define KOOL_MORNINGPLUGIN_H

#include <QQmlExtensionPlugin>

class kool_morningPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
};

class Logic : public QObject
{
    Q_OBJECT
    // Q_PROPERTY (int someProperty READ someProperty WRITE setSomeProperty NOTIFY somePropertyChanged)

public:
    Logic(QObject* parent = 0)
        : QObject(parent), m_someProperty(0)
    {
    }

    ~Logic() {}

    Q_INVOKABLE QStringList icons(QString path);
    Q_INVOKABLE void wake(QString host, QString mac);

    int someProperty() const { return m_someProperty; }
    // void setSomeProperty(int val) {};

signals:
    void somePropertyChanged(int newValue);

private:
    int m_someProperty;
};

#endif // KOOL_MORNINGPLUGIN_H
