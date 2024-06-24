#include <QQmlApplicationEngine>
#include <QGuiApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine("qrc:///qml.test.project/imports/main/scene/qml/main.qml");
    return app.exec();
}
