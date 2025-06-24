cmake_minimum_required(VERSION 3.31.6)
project(Internationalization)

set(NVIM_DIR "${CMAKE_SOURCE_DIR}/..")
set(TRANSLATION_DIR "${CMAKE_SOURCE_DIR}")
set(TEMPLATE_FILE "${TRANSLATION_DIR}/template.pot")
set(TRANSLATION_SCRIPT_TYPE "po")

set(LANGUAGES en ja)

file(MAKE_DIRECTORY ${TRANSLATION_DIR})
file(GLOB_RECURSE LUA_FILES "${NVIM_DIR}/*.lua")

add_custom_command(
    OUTPUT ${TEMPLATE_FILE}
    DEPENDS ${LUA_FILES}
    COMMAND bash -c "mkdir -p '${TRANSLATION_DIR}' && cd '${NVIM_DIR}' && xgettext -L Lua --keyword=Msgstr --from-code=UTF-8  --directory=. -o '${TEMPLATE_FILE}' $(find . -name '*.lua')"
    COMMENT "Generating template.pot from Lua source"
    VERBATIM
)

foreach(LANGUAGE ${LANGUAGES})
    set(PO_FILE "${TRANSLATION_DIR}/${LANGUAGE}.${TRANSLATION_SCRIPT_TYPE}")

    add_custom_command(
        OUTPUT ${PO_FILE}
        DEPENDS ${TEMPLATE_FILE}
        COMMAND bash -c "if [ -f '${PO_FILE}' ]; then msgmerge --update --backup=off '${PO_FILE}' '${TEMPLATE_FILE}'; else cp '${TEMPLATE_FILE}' '${PO_FILE}' && sed -i '' -e 's/charset=CHARSET/charset=UTF-8/' -e 's/^\\\"Language:.*\\\"$/\\\"Language: ${LANGUAGE}\\\\n\\\"/' '${PO_FILE}'; fi"
        COMMENT "Merging or creating ${LANGUAGE}.po"
        VERBATIM
    )

    add_custom_target(${LANGUAGE}_po ALL DEPENDS ${PO_FILE})
endforeach()

add_custom_target(update_translations ALL
    DEPENDS ${TEMPLATE_FILE}
)
