
set(SOURCES
    main.c)

find_package(ALLEGRO5 5.2 REQUIRED)
include_directories(${ALLEGRO5_INCLUDE_DIRS})

find_package(OpenGL REQUIRED)
    
add_executable(huh ${SOURCES})

target_link_libraries(huh ${ALLEGRO5_LIBRARIES} ${OPENGL_LIBRARIES})
