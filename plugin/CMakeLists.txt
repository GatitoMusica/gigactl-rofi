add_library(gigacontrolbackend)

ecm_add_qml_module(gigacontrolbackend
    URI org.gigactl.hardware
    VERSION 1.0
    GENERATE_PLUGIN_SOURCE
)

target_sources(gigacontrolbackend
    PRIVATE
        hardwarecontroller.cpp
        hardwarecontroller.h
        daemonclient.cpp
        daemonclient.h
)

target_link_libraries(gigacontrolbackend
    PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::DBus
)

ecm_finalize_qml_module(gigacontrolbackend
    DESTINATION ${KDE_INSTALL_QMLDIR}
)

# Resolve the backend library relative to the QML plugin directory.
file(RELATIVE_PATH GIGACONTROL_BACKEND_RELATIVE_PATH
    "${KDE_INSTALL_FULL_QMLDIR}/org/gigactl/hardware"
    "${KDE_INSTALL_FULL_LIBDIR}"
)

set_target_properties(gigacontrolbackendplugin PROPERTIES
    INSTALL_RPATH "$ORIGIN/${GIGACONTROL_BACKEND_RELATIVE_PATH}"
)

install(TARGETS gigacontrolbackend
    ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
)
