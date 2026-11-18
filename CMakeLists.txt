cmake_minimum_required(VERSION 3.16)

project(TestPrototype VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)

add_executable(TestPrototype
    main.cpp
    Controllers/audiocontroller.cpp Controllers/audiocontroller.h
    Controllers/hvachandler.cpp     Controllers/hvachandler.h
    Controllers/system.cpp          Controllers/system.h
    Controllers/vehiclestate.cpp    Controllers/vehiclestate.h
    Testing/uilocator.cpp           Testing/uilocator.h
    qml.qrc
)

target_include_directories(TestPrototype PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(TestPrototype PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick)

# Where the binary goes on the target board. Qt Creator's "Remote Linux"
# deployment copies whatever is installed here. Override with
#   -DDEPLOY_PATH=/home/pi/TestPrototype
set(DEPLOY_PATH "/opt/TestPrototype/bin" CACHE PATH "Install directory on the target device")
install(TARGETS TestPrototype RUNTIME DESTINATION "${DEPLOY_PATH}")
