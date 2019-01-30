add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.kool_morning\")

set(kool_morningplugin_SRCS
    kool_morningplugin.cpp
)

add_library(kool_morningplugin SHARED ${kool_morningplugin_SRCS})

target_link_libraries(kool_morningplugin
    KF5::I18n
    Qt5::Gui
    Qt5::Qml
)
install(TARGETS kool_morningplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/kool_morning)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/kool_morning)
