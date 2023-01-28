/* This is CMake-template for libmdbx's version.c
 ******************************************************************************/

#include "internals.h"

//#if MDBX_VERSION_MAJOR != 0 ||                             \
//    MDBX_VERSION_MINOR != 9
//#error "API version mismatch! Had `git fetch --tags` done?"
//#endif

static const char sourcery[] = STRINGIFY(MDBX_BUILD_SOURCERY);

__dll_export
#ifdef __attribute_used__
    __attribute_used__
#elif defined(__GNUC__) || __has_attribute(__used__)
    __attribute__((__used__))
#endif
#ifdef __attribute_externally_visible__
        __attribute_externally_visible__
#elif (defined(__GNUC__) && !defined(__clang__)) ||                            \
    __has_attribute(__externally_visible__)
    __attribute__((__externally_visible__))
#endif
    const mdbx_version_info mdbx_version = {
        0,
        9,
        3,
        0,
        {"", "", "",
         ""},
        sourcery};

__dll_export
#ifdef __attribute_used__
    __attribute_used__
#elif defined(__GNUC__) || __has_attribute(__used__)
    __attribute__((__used__))
#endif
#ifdef __attribute_externally_visible__
        __attribute_externally_visible__
#elif (defined(__GNUC__) && !defined(__clang__)) ||                            \
    __has_attribute(__externally_visible__)
    __attribute__((__externally_visible__))
#endif
    const char *const mdbx_sourcery_anchor = sourcery;
