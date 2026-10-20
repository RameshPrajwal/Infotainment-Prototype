#include "uilocator.h"

#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickWindow>
#include <QRegularExpression>
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

// "MouseArea" instead of "QQuickMouseArea" / "QQuickRectangle_QML_12".
QString typeName(const QObject *obj)
{
    QString name = QString::fromLatin1(obj->metaObject()->className());
    name.remove(QRegularExpression(QStringLiteral("_QML_\\d+$")));
    if (name.startsWith(QLatin1String("QQuick")))
        name.remove(0, 6);
    return name;
}

// Where an unnamed element sits, using QML ids: "leftScreen > MouseArea".
QString describe(const QQuickItem *item)
{
    QString where;
    for (const QQuickItem *it = item->parentItem(); it; it = it->parentItem()) {
        const QQmlContext *ctx = qmlContext(it);
        const QString id = ctx ? ctx->nameForObject(const_cast<QQuickItem *>(it)) : QString();
        if (!it->objectName().isEmpty() || !id.isEmpty()) {
            where = it->objectName().isEmpty() ? id : namedPath(it);
            break;
        }
    }
    return QStringLiteral("(unnamed %1 in %2)")
        .arg(typeName(item), where.isEmpty() ? QStringLiteral("window") : where);
}

// Things a user can click, type into or drag.
bool isInputItem(const QObject *obj)
{
    return obj->inherits("QQuickMouseArea") || obj->inherits("QQuickTextInput")
        || obj->inherits("QQuickTextEdit") || obj->inherits("QQuickAbstractButton")
        || obj->inherits("QQuickPointerHandler");   // TapHandler, DragHandler, ...
}

// An item is interactive if it handles input itself, or through an unnamed
// MouseArea / handler directly inside it (the usual QML pattern).
bool isInteractive(const QQuickItem *item)
{
    if (isInputItem(item))
        return true;
    const auto children = item->children();   // includes handlers, which are not items
    for (const QObject *child : children) {
        if (child->objectName().isEmpty() && isInputItem(child))
            return true;
    }
    return false;
}

void addEntry(QJsonObject &out, QString key, const QQuickItem *item, bool interactive)
{
    const QString base = key;
    for (int n = 2; out.contains(key); ++n)
        key = base + QLatin1Char('#') + QString::number(n);

    const QPointF topLeft = item->mapToGlobal(QPointF(0, 0));
    out.insert(key, QJsonObject{
        { QStringLiteral("x"), qRound(topLeft.x()) },
        { QStringLiteral("y"), qRound(topLeft.y()) },
        { QStringLiteral("w"), qRound(item->width()) },
        { QStringLiteral("h"), qRound(item->height()) },
        { QStringLiteral("interactive"), interactive },
    });
}

void collect(const QQuickItem *item, QJsonObject &out)
{
    if (!item->isVisible())
        return;

    if (item->width() > 0 && item->height() > 0) {
        if (!item->objectName().isEmpty()) {
            addEntry(out, namedPath(item), item, isInteractive(item));
        } else if (isInputItem(item)
                   && !(item->parentItem() && !item->parentItem()->objectName().isEmpty())) {
            // Clickable but no objectName on it or its parent: the demo cannot
            // reach it. Reported so the pipeline can ask for a name.
            addEntry(out, describe(item), item, true);
        }
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

    // On a bare virtual display there is no desktop to supply a pointer shape,
    // so areas without their own cursor would show X11's "X". Use an arrow.
    QGuiApplication::setOverrideCursor(Qt::ArrowCursor);

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
