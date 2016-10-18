
set(HUH_SOURCES
    huh.h
    huh.c)

set(TEST_SOURCES
    main.c)

find_package(ALLEGRO5 5.2 REQUIRED)
include_directories(${ALLEGRO5_INCLUDE_DIRS})

find_package(OpenGL REQUIRED)

add_library(huh SHARED ${HUH_SOURCES})
target_link_libraries(huh ${ALLEGRO5_LIBRARIES} ${OPENGL_LIBRARIES})
    
add_executable(huh_test ${TEST_SOURCES})
target_link_libraries(huh_test huh ${ALLEGRO5_LIBRARIES})

