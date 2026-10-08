#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <Controllers/system.h>
#include <Controllers/hvachandler.h>
#include <Controllers/audiocontroller.h>

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

    engine.rootContext()->setContextProperty(
        "secureMapUrl", QStringLiteral("https://tile.openstreetmap.org/"));
    engine.load(url);


    QQmlContext * context ( engine.rootContext() );
    context->setContextProperty("systemHandler", &m_systemHandler );
    context->setContextProperty("driverHVAC", &m_driverHVACHandler );
    context->setContextProperty("passengerHVAC", &m_passengerHVACHandler );
    context->setContextProperty("audioController", &m_volumeLevel );

    return app.exec();
}
