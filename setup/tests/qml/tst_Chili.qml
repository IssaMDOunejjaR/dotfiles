import QtQuick
import QtTest
import "../../../srcs/sddm/themes/chili/components" as Chili

TestCase {
    id: root
    name: "ChiliQt6"
    width: 1000
    height: 600
    visible: true
    when: windowShown

    property var config: ({PasswordFieldOutlined: "false", PowerIconSize: 24})
    property QtObject textConstants: QtObject { property string password: "Password" }
    property QtObject sddm: QtObject { signal loginFailed() }
    property QtObject keyboard: QtObject {
        property int currentLayout: 0
        property var layouts: [{longName: "English"}, {longName: "French"}]
    }
    property ListModel userModel: ListModel {
        property int lastIndex: 0
        ListElement { name: "tester"; realName: "Test User"; icon: "" }
    }
    property ListModel sessionModel: ListModel {
        property int lastIndex: 0
        ListElement { name: "Hyprland" }
        ListElement { name: "Another session" }
    }

    Chili.LoginForm {
        id: form
        width: 700
        height: 400
        usernameFontSize: 12
        usernameFontColor: "white"
        faceSize: 64
        userListModel: userModel
        userListCurrentIndex: 0
        actionItems: [Item { width: 24; height: 24 }]
    }
    SignalSpy { id: login; target: form; signalName: "loginRequest" }
    Chili.SessionMenu { id: sessions; rootFontSize: 12; rootFontColor: "white" }
    Chili.KeyboardLayoutButton { id: layouts }

    function test_password_and_login_signal() {
        var field = findChild(form, "passwordField");
        verify(field !== null);
        field.text = "test-password";
        login.clear();
        form.startLogin();
        compare(login.count, 1);
        compare(login.signalArguments[0][0], "tester");
        compare(login.signalArguments[0][1], "test-password");
        sddm.loginFailed();
        compare(field.selectedText, "test-password");
    }

    function test_session_and_keyboard_menus() {
        tryCompare(sessions, "visible", true);
        compare(sessions.currentIndex, 0);
        compare(sessions.contentItem.text, "Hyprland");
        verify(layouts.visible);
        layouts.clicked();
        findChild(layouts, "keyboardLayoutMenu").itemAt(1).triggered();
        compare(keyboard.currentLayout, 1);
        sessions.clicked();
        findChild(sessions, "sessionMenu").itemAt(1).triggered();
        compare(sessions.currentIndex, 1);
        compare(sessions.contentItem.text, "Another session");
    }
}
