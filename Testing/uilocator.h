#ifndef UILOCATOR_H
#define UILOCATOR_H

class QQmlApplicationEngine;

// Test support for the automated UI demo (scripts/record-ui-demo.sh).
//
// When the environment variable UI_LOCATOR_FILE is set, the app writes the
// on-screen rectangle of every visible QML item that has an objectName to
// that file as JSON, refreshed once per second. Names are the path of named
// ancestors, e.g. "driverHVAC.up". Each entry says whether the element is
// interactive (handles clicks, typing or dragging). Clickable elements without
// a name are listed as "(unnamed ...)". The demo script reads the file, clicks
// elements by name instead of hard-coded pixel positions, and reports
// interactive elements that the demo does not test yet.
//
// Without the variable this does nothing.
namespace UiLocator {
void installFromEnvironment(QQmlApplicationEngine &engine);
}

#endif // UILOCATOR_H
