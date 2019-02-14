cmake_minimum_required(VERSION 3.5.2 FATAL_ERROR)

set(PROJECT_NAME exif_util)
project(${PROJECT_NAME})

find_package(OpenCV QUIET)
if(OpenCV_FOUND)
    add_definitions(-DOpenCV_FOUND)
else()
    message(WARNING "OpenCV package is required to write JPEG!")
    set(OpenCV_LIBS "")
    set(OpenCV_DIR  "")
endif()

find_package(EXIF QUIET)
if(NOT EXIF_FOUND)
    message(STATUS "libexif NOT FOUND.")

else()
    message(STATUS "libexif FOUND at ${EXIF_ROOT_DIR}")

    add_library(${PROJECT_NAME} STATIC
        libjpeg/jpeg-data.c
        libjpeg/jpeg-data.h
        libjpeg/jpeg-marker.c
        libjpeg/jpeg-marker.h
    )

    target_include_directories(${PROJECT_NAME} PUBLIC ${OpenCV_DIR} PRIVATE . ${EXIF_INCLUDE_DIR})
    target_link_libraries(${PROJECT_NAME} PUBLIC ${EXIF_LIBRARIES} ${OpenCV_LIBS})

    set_target_properties(${PROJECT_NAME} PROPERTIES
        FOLDER "Library"
        CXX_STANDARD 14
    )
endif()
