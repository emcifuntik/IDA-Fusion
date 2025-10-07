#pragma once

#include <cstdio>
#include <cstring>
#include <string>
#include <regex>

// Platform-specific headers
#ifdef __NT__
  #include <windows.h>
#endif

// Include typedefs
#include "typedefs.h"

#include <loader.hpp>
#include <idp.hpp>
#include <search.hpp>

// Custom
#include "n_utils.h"
#include "n_settings.h"
#include "n_signature.h"