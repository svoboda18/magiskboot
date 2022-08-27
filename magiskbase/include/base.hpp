#pragma once

#ifdef SVB_WIN32
#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#else
#include "../missing.hpp"
#endif

#include "../xwrap.hpp"
#include "../files.hpp"
#include "../misc.hpp"

#ifndef SVB_WIN32
#include <base-rs.hpp>
#endif

#define LOG(fmt, args...) fprintf(stderr, fmt, ##args)
#define PLOGE(fmt, args...) LOG(fmt " failed with %d: %s\n", ##args, errno, std::strerror(errno))
#define LOGE(fmt, args...) { LOG("Error: " fmt, ##args); exit(1); }
#define LOGW(fmt, args...) LOG("Warning: " fmt, ##args)
#define LOGD(fmt, args...) LOG("Debug: " fmt, ##args)
