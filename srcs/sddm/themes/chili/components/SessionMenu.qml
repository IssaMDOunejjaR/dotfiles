/*
 *   Copyright 2018 Marian Alexander Arlt <marianarlt@icloud.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
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

import QtQuick
import QtQuick.Controls.Basic

ToolButton {
    id: root

    property int currentIndex: -1
    property int rootFontSize
    property string rootFontColor

    visible: menu.count > 1

    opacity: root.activeFocus ? 1 : 0.5

    contentItem: Label {
        color: rootFontColor
        font.pointSize: Math.max(1, rootFontSize)
        renderType: Text.QtRendering
        text: menu.count > currentIndex && menu.itemAt(currentIndex) ? menu.itemAt(currentIndex).text : ""
        font.underline: root.activeFocus
    }
    background: Rectangle {
        color: "transparent"
    }

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    onClicked: menu.open()
    Menu {
        id: menu
        objectName: "sessionMenu"
        y: -height
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: function(index, object) { menu.insertItem(index, object) }
            onObjectRemoved: function(index, object) { menu.removeItem(object) }
            delegate: MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}
