#include <play_list.hpp>

#include <filesystem>
#include <regex>
#include <set>

namespace {

constexpr char const* sourcePrefixRegexp = "[a-zA-z0-9]+://";

bool IsFileSourceSupported(const std::string& file_source_prefix) {
	static const std::set<std::string> supported_file_sources = {"file://"};
	return supported_file_sources.count(file_source_prefix) != 0;
}

} // namespace

PlayListController::PlayListController(QObject *parent)
	: QObject(parent)
{
}

QString PlayListController::currentFileName() {
	return currentFileName_;
}

bool PlayListController::setCurrentFileImpl(const QString& value) {
	if (value == currentFileName_) {
		return false;
	}

	filesToPlay_.clear();
	currentFileName_ = "";

	if (value.size() == 0) {
		return true;
	}

	const auto std_string_value = value.toStdString();

	std::smatch match;
	std::regex_search(std_string_value, match, std::regex(sourcePrefixRegexp));

	if (match.size() != 1) {
		qWarning("File name doesn't have source prefix %s", std_string_value.data());

		return true;
	}

	const auto file_source = match[0].str();
	if (!IsFileSourceSupported(file_source)) {
		qWarning("File source isn't supported %s", file_source.data());

		return true;

	}

	const auto file_path_str = match.suffix().str();
	const std::filesystem::path file_path{file_path_str};

	if (!std::filesystem::exists(file_path)) {
		qWarning("Can't find file '%s'", file_path_str.data());

		return true;
	}

	if (!std::filesystem::is_regular_file(file_path)) {
		qWarning("Can't load other files instead regular file '%s'", file_path_str.data());

		return true;
	}

	const auto file_extension = file_path.extension();
	const auto directory = file_path.parent_path();

	std::set<QString> filesToPlay;
	for (const auto& entry : std::filesystem::directory_iterator(directory)) {
		if (entry.is_regular_file() && entry.path().extension() == file_extension) {
			auto file_name = file_source + entry.path().string();
			filesToPlay.insert(QString::fromStdString(std::move(file_name)));
		}
	}

	currentFileName_ = value;
	filesToPlay_ = std::move(filesToPlay);

	return true;
}

QString PlayListController::GetNextFile(const size_t count) const {
	size_t file_index = 0;
	size_t file_count = filesToPlay_.size();

	if (currentFileName_.size() == 0) {
		if (file_count == 0) {
			return {};
		}

		if (count == 0) {
			return {};
		}

		file_index = count % (file_count + 1);
	}
	else
	{
		const auto it = filesToPlay_.find(currentFileName_);
		if (it == filesToPlay_.cend()) {
			return {};
		}

		if (count == 0) {
			return *it;
		}

		file_index = (std::distance(filesToPlay_.cbegin(), it) + count + 1) % (file_count + 1);
	}

	if (file_index == 0) {
		return {};
	}

	return (*std::next(filesToPlay_.cbegin(), file_index - 1));
}

QString PlayListController::GetPreviousFile(const size_t count) const {
	size_t file_index = 0;
	size_t file_count = filesToPlay_.size();

	if (currentFileName_.size() == 0) {
		if (file_count == 0) {
			return {};
		}

		if (count == 0) {
			return {};
		}

		file_index = count % (file_count + 1);
	}
	else
	{
		const auto it = filesToPlay_.find(currentFileName_);
		if (it == filesToPlay_.cend()) {
			return {};
		}

		if (count == 0) {
			return *it;
		}

		file_index = (file_count - std::distance(filesToPlay_.cbegin(), it) + count) % (file_count + 1);
	}

	if (file_index == 0) {
		return {};
	}

	return (*std::next(filesToPlay_.cbegin(), file_count - file_index));
}

void PlayListController::switchToNext() {
	if (!actions_)
	{
		actions_ = ActionsWithFile{true, 1};
		return;
	}

	if (actions_->isNext)
	{
		++actions_->operationCount;
		return;
	}

	if (actions_->operationCount <= 1) {
		actions_ = std::nullopt;
		return;
	}

	--actions_->operationCount;
}

void PlayListController::switchToPrevious() {
	if (!actions_)
	{
		actions_ = ActionsWithFile{false, 1};
		return;
	}

	if (!actions_->isNext)
	{
		++actions_->operationCount;
		return;
	}

	if (actions_->operationCount <= 1) {
		actions_ = std::nullopt;
		return;
	}

	--actions_->operationCount;
}

void PlayListController::apply() {
	if (!fileToPlay_ && !actions_)
	{
		return;
	}

	const auto fileToPlay = fileToPlay_;
	const auto actions = actions_;

	fileToPlay_ = std::nullopt;
	actions_ = std::nullopt;

	auto is_file_changed = false;

	if (fileToPlay)
	{
		is_file_changed = setCurrentFileImpl(*fileToPlay);
		if (!is_file_changed && !actions)
		{
			return;
		}
	}

	if (actions)
	{
		if (actions->isNext)
		{
			if (!switchToNextImpl(actions->operationCount) && !is_file_changed)
			{
				return;
			}
		}
		else
		{
			if (!switchToPrevImpl(actions->operationCount) && !is_file_changed)
			{
				return;
			}
		}
	}

	emit currentFileNameChanged();
}

void PlayListController::setFileToPlay(const QString& value, const bool force) {
	actions_ = std::nullopt;
	fileToPlay_ = value;

	if (force) {
		apply();
	}
}

bool PlayListController::switchToNextImpl(const size_t count) {
	auto nxtFile = GetNextFile(count);

	if (nxtFile == currentFileName_) {
		return false;
	}

	std::swap(nxtFile, currentFileName_);

	return true;
}

bool PlayListController::switchToPrevImpl(const size_t count) {
	auto prFile = GetPreviousFile(count);

	if (prFile == currentFileName_) {
		return false;
	}

	std::swap(prFile, currentFileName_);

	return true;
}
