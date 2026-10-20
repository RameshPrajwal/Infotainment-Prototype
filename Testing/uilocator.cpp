#include "uilocator.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSaveFile>
#include <QTimer>

namespace {

QString namedPath(const QQuickItem *item)
{
    QStringList parts;
    for (const QQuickItem *it = item; it; it = it->parentItem()) {
        if (!it->objectName().isEmpty())
            parts.prepend(it->objectName());
    }
    return parts.join(QLatin1Char('.'));
}

void collect(const QQuickItem *item, QJsonObject &out)
{
    if (!item->isVisible())
        return;

    if (!item->objectName().isEmpty() && item->width() > 0 && item->height() > 0) {
        const QPointF topLeft = item->mapToGlobal(QPointF(0, 0));
        QString key = namedPath(item);
        for (int n = 2; out.contains(key); ++n)
            key = namedPath(item) + QLatin1Char('#') + QString::number(n);

        out.insert(key, QJsonObject{
            { QStringLiteral("x"), qRound(topLeft.x()) },
            { QStringLiteral("y"), qRound(topLeft.y()) },
            { QStringLiteral("w"), qRound(item->width()) },
            { QStringLiteral("h"), qRound(item->height()) },
        });
    }

    const auto children = item->childItems();
    for (const QQuickItem *child : children)
        collect(child, out);
}

void writeLocations(QQuickWindow *window, const QString &path)
{
    QJsonObject items;
    collect(window->contentItem(), items);

    QSaveFile file(path);   // atomic replace, readers never see half a file
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(items).toJson(QJsonDocument::Indented));
        file.commit();
    }
}

} // namespace

void UiLocator::installFromEnvironment(QQmlApplicationEngine &engine)
{
    const QString path = qEnvironmentVariable("UI_LOCATOR_FILE");
    if (path.isEmpty())
        return;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &engine,
                     [path](QObject *obj, const QUrl &) {
        auto *window = qobject_cast<QQuickWindow *>(obj);
        if (!window)
            return;
        auto *timer = new QTimer(window);
        QObject::connect(timer, &QTimer::timeout, window,
                         [window, path] { writeLocations(window, path); });
        timer->start(1000);
    });
}
