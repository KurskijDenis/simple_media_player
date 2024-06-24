#pragma once

#include <QObject>
#include <QString>

#include <set>
#include <optional>
#include <qqml.h>

class PlayListController: public QObject {
	Q_OBJECT
	Q_PROPERTY(QString currentFileName READ currentFileName NOTIFY currentFileNameChanged)
	QML_ELEMENT

private:
	struct ActionsWithFile {
		bool isNext;
		int operationCount;
	};

public:
	Q_INVOKABLE void switchToNext();
	Q_INVOKABLE void switchToPrevious();
	Q_INVOKABLE void apply();
	Q_INVOKABLE void setFileToPlay(const QString& value, const bool force);

public:
	explicit PlayListController(QObject* parent = nullptr);

private:
	QString GetNextFile(const size_t count) const;
	QString GetPreviousFile(const size_t count) const;

public:
	QString currentFileName();

signals:
	void currentFileNameChanged();

private:
	bool setCurrentFileImpl(const QString& value);
	bool switchToNextImpl(const size_t count);
	bool switchToPrevImpl(const size_t count);

private:
	QString currentFileName_;

	std::optional<QString> fileToPlay_;
	std::optional<ActionsWithFile> actions_;
	std::set<QString> filesToPlay_;
};
