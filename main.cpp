#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <Controllers/system.h>
#include <Controllers/hvachandler.h>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    System m_systemHandler;
    HVACHandler m_driverHVACHandler;
    HVACHandler m_passengerHVACHandler;

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
    // Read the secure macro string defined by qmake
    QString apiKey = QString(THUNDERFOREST_API_KEY);

    // Construct the complete tile query path safely.
    // Use double percent signs (%%3F) so QString doesn't mistake %3 for an argument marker.
    QString secureMapUrl = QString("http://tile.thunderforest.com/transport/%z/%x/%y.png?.arg(apiKey)&fake=.png");

    // Pass the completed URL configuration into the QML runtime engine context
    engine.rootContext()->setContextProperty("secureMapUrl", secureMapUrl);
    engine.load(url);

    QQmlContext * context ( engine.rootContext() );
    context->setContextProperty("systemHandler", &m_systemHandler );
    context->setContextProperty("driverHVAC", &m_driverHVACHandler );
    context->setContextProperty("passengerHVAC", &m_passengerHVACHandler );

    return app.exec();
}
