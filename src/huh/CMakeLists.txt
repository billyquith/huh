
set(HUH_SOURCES
    huh.h
    huh.c

    nanovg/nanovg.h
    nanovg/nanovg.c
    nanovg/nanovg_gl.h
    nanovg/nanovg_gl_utils.h
    nanovg/fontstash.h
    nanovg/stb_image.h
    nanovg/stb_truetype.h)

set(MAIN_SOURCES
    main.c)

set(LUAJIT_CL "${EXT_DIR}/luajit/src/luajit.c")

find_package(ALLEGRO5 5.2 REQUIRED)
find_package(OpenGL REQUIRED)

include_directories(${LOCAL_DIR}/include ${ALLEGRO5_INCLUDE_DIRS})


add_executable(huh ${MAIN_SOURCES} ${HUH_SOURCES})

target_compile_definitions(huh PRIVATE HUH_LUAJIT_PATH="${LUAJIT_CL}")

if (APPLE)
    # As mention in "Embedding LuaJIT" docs: http://luajit.org/install.html
    set_target_properties(huh PROPERTIES LINK_FLAGS "-pagezero_size 10000 -image_base 100000000")
endif()

target_link_libraries(huh
    ${ALLEGRO5_LIBRARIES}
    ${OPENGL_LIBRARIES}
     -L${LOCAL_DIR}/lib -lluajit-5.1)

# set <TARGET>_OUTPUT_DIRECTORY_<CONFIG>
set_target_properties(huh PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${LOCAL_DIR}/bin)
