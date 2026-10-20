#ifndef UILOCATOR_H
#define UILOCATOR_H

class QQmlApplicationEngine;

// Test support for the automated UI demo (scripts/record-ui-demo.sh).
//
// When the environment variable UI_LOCATOR_FILE is set, the app writes the
// on-screen rectangle of every visible QML item that has an objectName to
// that file as JSON, refreshed once per second. Names are the path of named
// ancestors, e.g. "driverHVAC.up". The demo script reads the file and clicks
// elements by name instead of hard-coded pixel positions.
//
// Without the variable this does nothing.
namespace UiLocator {
void installFromEnvironment(QQmlApplicationEngine &engine);
}

#endif // UILOCATOR_H
