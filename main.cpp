#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QVariantMap>
#include <QIcon>

#include "imageprovider.h"
#include "process.h"

struct AppInfo {
    QString name;
    QString icon = "application";
    QString exec;
};

QVariantList apps()
{
    QVariantList apps;

    QDir dir("/usr/share/applications");
    foreach (auto fn,
             dir.entryList(QStringList() << "*.desktop", QDir::Files)) {
        QFile file(dir.filePath(fn));
        if (file.open(QIODevice::ReadOnly)) {
            QTextStream in(&file);

            AppInfo app;

            bool foundDesktopEntry = false;

            while (!in.atEnd()) {
                QString line = in.readLine();

                if (line.trimmed().isEmpty())
                    continue;

                if (!foundDesktopEntry) {
                    if (line.contains("[Desktop Entry]"))
                        foundDesktopEntry = true;
                    continue;
                } else if (line.startsWith('[') && line.endsWith(']')) {
                    break;
                }

                QStringList values = line.split("=");
                QString name = values.takeFirst();
                QString value = QString(values.join('='));

                if (name == "Name") {
                    app.name = value;
                    qDebug() << "Found name: " << value;
                }

                if (name == "Icon") {
                    app.icon = value;
                }

                if (name == "Exec") {
                    app.exec = value.remove("\"").remove(QRegExp(" %."));
                }
            }

            apps.append(QStringList() << app.name << app.icon << app.exec);
        }
    }

    qDebug() << "Found apps: " << apps.length();
    return apps;
}

int main(int argc, char* argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    engine.addImageProvider("icons", new ImageProvider());
    engine.rootContext()->setContextProperty("appModel", apps());
    engine.rootContext()->setContextProperty("proc", new Process(&engine));

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
