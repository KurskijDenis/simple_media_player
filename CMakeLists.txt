cmake_minimum_required(VERSION 3.16)

# export QT_MEDIA_BACKEND=ffmpeg

project(qml_test VERSION 1.0.0 LANGUAGES CXX)

#set(Qt6Core_DIR "<path_to_qt>/lib/cmake/Qt6Core")
#set(Qt6_DIR "<path_to_qt>/lib/cmake/Qt6")
#set(QT_QMAKE_EXECUTABLE "<path_to_qt>/bin/qmake")

set(CMAKE_AUTOMOC ON) # need for qml file work
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON) # need for resource file work

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Gui Widgets Multimedia QuickControls2)

qt_standard_project_setup()

# Order qt_add_executable and qt_add_qml_module is important
qt_add_executable(qml_test
    main.cpp
    headers/play_list.hpp
    src/play_list.cpp
)

qt_add_qml_module(qml_test
    URI main.scene
    RESOURCE_PREFIX
         /qml.test.project/imports
    QML_FILES
        qml/main.qml
        qml/MetaDataInfo.qml
        qml/PlaybackSlider.qml
        qml/MetaInfoWindow.qml
        qml/FindFiles.qml
        qml/OpenFileItem.qml
	qml/ControllerButton.qml
	qml/TrackInfo.qml
	qml/ControlPanel.qml
    RESOURCES
	resources/play.svg
	resources/pause.svg
	resources/backward10.svg
	resources/forward10.svg
	resources/rewind.svg
	resources/next.svg
	resources/sound.svg
	resources/mute.svg
    SOURCES
        headers/play_list.hpp
        src/play_list.cpp
    DEPENDENCIES QtQuick
)

set_target_properties(qml_test PROPERTIES
    MACOSX_BUNDLE TRUE
)

# view.setSource(QUrl("qrc:///qml.test.project/imports/main/scene/qml/main.qml"));
message("-- Use install path ${CMAKE_INSTALL_PREFIX}")
# qt_standard_project_setup()

target_include_directories(qml_test PRIVATE headers)

target_link_libraries(qml_test PRIVATE
			       Qt6::Core
			       Qt6::QuickControls2
			       Qt6::Gui
			       Qt6::Quick
			       Qt6::Widgets
			       Qt6::Multimedia
		       )

qt_generate_deploy_qml_app_script(
    TARGET qml_test
    OUTPUT_SCRIPT deploy_script
)

message("-- Use install path ${deploy_script}")

install(TARGETS qml_test
    BUNDLE  DESTINATION .
    RUNTIME
      DESTINATION ${CMAKE_INSTALL_BINDIR}/qml_test
)

install(SCRIPT ${deploy_script})
