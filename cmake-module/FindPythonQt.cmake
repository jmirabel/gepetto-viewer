# Find PythonQt
#
# Sets PYTHONQT_FOUND, PYTHONQT_INCLUDE_DIR, PYTHONQT_LIBRARY, PYTHONQT_QTALL_LIBRARY, PYTHONQT_LIBRARIES
#

IF(NOT EXISTS "${PYTHONQT_INSTALL_DIR}")
  FIND_PATH(PYTHONQT_INSTALL_DIR include/PythonQt/PythonQt.h
    DOC "Directory where PythonQt was installed.")
ENDIF()
# XXX Since PythonQt 3.0 is not yet cmakeified, depending
#     on how PythonQt is built, headers will not always be
#     installed in "include/PythonQt". That is why "src"
#     is added as an option. See [1] for more details.
#     [1] https://github.com/commontk/CTK/pull/538#issuecomment-86106367
FIND_PATH(PYTHONQT_INCLUDE_DIR PythonQt.h
  PATHS "${PYTHONQT_INSTALL_DIR}/include/PythonQt"
  DOC "Path to the PythonQt include directory")
FIND_PATH(PYTHONQT_QTALL_INCLUDE_DIR PythonQt_QtAll.h
  PATHS "${PYTHONQT_INSTALL_DIR}/include/PythonQt"
  PATH_SUFFIXES "extensions/PythonQt_QtAll"
  DOC "Path to the PythonQt QtAll extension include directory")

SET(PYTHONQT_INCLUDE_DIR
  ${PYTHONQT_INCLUDE_DIR}
  ${PYTHONQT_QTALL_INCLUDE_DIR}
  )

SET(PYTHONQT_LIBRARIES)
IF(PROJECT_USE_QT4)
  SET(PYTHONQT_LIBRARIES_SUFFIX "-Qt4-Python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
ELSE(PROJECT_USE_QT4)
  SET(PYTHONQT_LIBRARIES_SUFFIX "-Qt5-Python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
ENDIF(PROJECT_USE_QT4)


MACRO(_SEARCH_FOR COMPONENT)
  STRING(TOUPPER ${COMPONENT} _COMP_UPPERCASE)
  FIND_LIBRARY(${_COMP_UPPERCASE}_LIBRARY
    NAMES ${COMPONENT} "${COMPONENT}${PYTHONQT_LIBRARIES_SUFFIX}"
    PATHS "${PYTHONQT_INSTALL_DIR}/lib"
    DOC "The ${COMPONENT} library.")
  IF(NOT ${${_COMP_UPPERCASE}_LIBRARY} STREQUAL "${_COMP_UPPERCASE}_LIBRARY-NOTFOUND")
    SET(${COMPONENT}_FOUND TRUE)
    SET(PYTHONQT_LIBRARIES ${PYTHONQT_LIBRARIES} ${${_COMP_UPPERCASE}_LIBRARY})
  ENDIF(NOT ${${_COMP_UPPERCASE}_LIBRARY} STREQUAL "${_COMP_UPPERCASE}_LIBRARY-NOTFOUND")

  MARK_AS_ADVANCED(${_COMP_UPPERCASE}_LIBRARY)
ENDMACRO(_SEARCH_FOR COMP)

_SEARCH_FOR(PythonQt)

FOREACH(_COMPONENT_SHORT ${PythonQt_FIND_COMPONENTS})
  SET(_COMPONENT "PythonQt_${_COMPONENT_SHORT}")
  _SEARCH_FOR(${_COMPONENT})
ENDFOREACH(_COMPONENT_SHORT ${PythonQt_FIND_COMPONENTS})

MARK_AS_ADVANCED(PYTHONQT_INSTALL_DIR)
MARK_AS_ADVANCED(PYTHONQT_INCLUDE_DIR)
MARK_AS_ADVANCED(PYTHONQT_LIBRARIES)

# All upper case _FOUND variable is maintained for backwards compatibility.
SET(PythonQt_FOUND 0)
IF(PYTHONQT_INCLUDE_DIR AND PYTHONQT_LIBRARIES)
  # Currently CMake'ified PythonQt only supports building against a python Release build.
  ADD_DEFINITIONS(-DPYTHONQT_USE_RELEASE_PYTHON_FALLBACK)
  SET(PythonQt_FOUND 1)
ENDIF()
SET(PYTHONQT_FOUND ${PythonQt_FOUND})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PythonQt
  REQUIRED_VARS PYTHONQT_LIBRARY PYTHONQT_INCLUDE_DIR
  HANDLE_COMPONENTS)
