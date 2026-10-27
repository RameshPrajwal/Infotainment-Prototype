#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <Controllers/system.h>
#include <Controllers/hvachandler.h>
#include <Controllers/audiocontroller.h>
#include <Controllers/vehiclestate.h>
#include <Testing/uilocator.h>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    System m_systemHandler;
    HVACHandler m_driverHVACHandler;
    HVACHandler m_passengerHVACHandler;
    audioController m_volumeLevel;
    VehicleState m_vehicleState;

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    // Context properties must be set before load(), otherwise the QML
    // bindings are evaluated while these names are still undefined.
    QQmlContext * context ( engine.rootContext() );
    context->setContextProperty("secureMapUrl", QStringLiteral("https://tile.openstreetmap.org/"));
    context->setContextProperty("systemHandler", &m_systemHandler );
    context->setContextProperty("driverHVAC", &m_driverHVACHandler );
    context->setContextProperty("passengerHVAC", &m_passengerHVACHandler );
    context->setContextProperty("audioController", &m_volumeLevel );
    context->setContextProperty("vehicleState", &m_vehicleState );

    UiLocator::installFromEnvironment(engine);   // no-op unless UI_LOCATOR_FILE is set
    engine.load(url);

    return app.exec();
}
