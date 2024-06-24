qt_cmake_path = "<path to qt>/lib/cmake"
install_path = "<path where install app>"

.PHONY: generate_release
generate_release:
	rm -rf build/Release/*
	cmake -B build/Release -S . \
		-DCMAKE_PREFIX_PATH=$(qt_cmake_path) \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=1

.PHONY: build_release
build_release:
	cmake --build build/Release --verbose -j 8

.PHONY: install_release
install_release:
	cmake --install build/Release --prefix "$(install_path)/release"



.PHONY: generate_rel_with_deb_info
generate_rel_with_deb_info:
	rm -rf build/RelWithDebInfo/*
	cmake -B build/RelWithDebInfo -S . \
		-DCMAKE_PREFIX_PATH=$(qt_cmake_path) \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=1

.PHONY: build_rel_with_deb_info
build_rel_with_deb_info:
	cmake --build build/RelWithDebInfo -j 8


.PHONY: install_rel_with_deb_info
install_rel_with_deb_info:
	cmake --install build/RelWithDebInfo --prefix "$(install_path)/rel_with_deb_info"


.PHONY: generate_debug
generate_debug:
	rm -rf build/Debug/*
	cmake -B build/Debug -S . \
		-DCMAKE_PREFIX_PATH=$(qt_cmake_path) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DCMAKE_CXX_FLAGS_DEBUG="-ggdb3" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=1

.PHONY: build_debug
build_debug:
	cmake --build build/Debug -j 8

.PHONY: install_debug
install_debug:
	cmake --install build/Debug --prefix "$(install_path)/debug"

