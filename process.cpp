#include <QProcessEnvironment>
#include <QDir>
#include "process.h"

Process::Process(QObject* parent) : QProcess(parent)
{
}

void Process::start(const QString& program, const QVariantList& arguments)
{
    QStringList args;

    qDebug() << "Running" << program;
    // convert QVariantList from QML to QStringList for QProcess

    for (int i = 0; i < arguments.length(); i++) {
        args << arguments[i].toString();
    }

    QProcessEnvironment environment = QProcessEnvironment();
    QProcess process;
    process.setProgram(program);
    process.setArguments(args);
    process.setProcessEnvironment(environment);
    qint64 pid = 0;
    QDir runDirectory = QDir::homePath();
    if (!QProcess::startDetached(program, args, runDirectory.absolutePath(),
                                 &pid)) {
        qDebug() << "Failed to spawn new process!";
    }
    qDebug() << "Spawned new process, pid:" << pid;
}

QByteArray Process::readAll()
{
    return QProcess::readAll();
}
