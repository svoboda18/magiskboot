#include <sched.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#ifndef SVB_WIN32
#include <sys/socket.h>
#include <sys/sendfile.h>
#include <sys/ptrace.h>
#include <sys/inotify.h>
#include <sys/mount.h>
#else
#include <errno.h>
#include "windows.h"
#endif

#include <base.hpp>

using namespace std;

FILE *xfopen(const char *pathname, const char *mode) {
    FILE *fp = fopen(pathname, mode);
    if (fp == nullptr) {
        PLOGE("fopen: %s", pathname);
    }
    return fp;
}

FILE *xfdopen(int fd, const char *mode) {
    FILE *fp = fdopen(fd, mode);
    if (fp == nullptr) {
        PLOGE("fopen");
    }
    return fp;
}

int xopen(const char *pathname, int flags) {
#ifdef SVB_MINGW
    flags |= O_BINARY;
#endif
    int fd = open(pathname, flags);
    if (fd < 0) {
        PLOGE("open: %s", pathname);
    }
    return fd;
}

int xopen(const char *pathname, int flags, mode_t mode) {
#ifdef SVB_MINGW
    flags |= O_BINARY;
#endif
    int fd = open(pathname, flags, mode);
    if (fd < 0) {
        PLOGE("open: %s", pathname);
    }
    return fd;
}

#ifndef SVB_MINGW
int xopenat(int dirfd, const char *pathname, int flags) {
    int fd = openat(dirfd, pathname, flags);
    if (fd < 0) {
        PLOGE("openat: %s", pathname);
    }
    return fd;
}

int xopenat(int dirfd, const char *pathname, int flags, mode_t mode) {
    int fd = openat(dirfd, pathname, flags, mode);
    if (fd < 0) {
        PLOGE("openat: %s", pathname);
    }
    return fd;
}
#endif

// Write exact same size as count
ssize_t xwrite(int fd, const void *buf, size_t count) {
    size_t write_sz = 0;
    ssize_t ret;
    do {
        ret = write(fd, (::byte *) buf + write_sz, count - write_sz);
        if (ret < 0) {
            if (errno == EINTR)
                continue;
            PLOGE("write");
            return ret;
        }
        write_sz += ret;
    } while (write_sz != count && ret != 0);
    if (write_sz != count) {
        PLOGE("write (%zu != %zu)", count, write_sz);
    }
    return write_sz;
}

// Read error other than EOF
ssize_t xread(int fd, void *buf, size_t count) {
    int ret = read(fd, buf, count);
    if (ret < 0) {
        PLOGE("read");
    }
    return ret;
}

// Read exact same size as count
ssize_t xxread(int fd, void *buf, size_t count) {
    size_t read_sz = 0;
    ssize_t ret;
    do {
        ret = read(fd, (::byte *) buf + read_sz, count - read_sz);
        if (ret < 0) {
            if (errno == EINTR)
                continue;
            PLOGE("read");
            return ret;
        }
        read_sz += ret;
    } while (read_sz != count && ret != 0);
    if (read_sz != count) {
        PLOGE("read (%zu != %zu)", count, read_sz);
    }
    return read_sz;
}

off_t xlseek(int fd, off_t offset, int whence) {
    off_t ret = lseek(fd, offset, whence);
    if (ret < 0) {
        PLOGE("lseek");
    }
    return ret;
}

#ifndef SVB_MINGW
int xpipe2(int pipefd[2], int flags) {
    int ret = pipe2(pipefd, flags);
    if (ret < 0) {
        PLOGE("pipe2");
    }
    return ret;
}
#endif

#ifndef SVB_WIN32
int xsetns(int fd, int nstype) {
    int ret = setns(fd, nstype);
    if (ret < 0) {
        PLOGE("setns");
    }
    return ret;
}

int xunshare(int flags) {
    int ret = unshare(flags);
    if (ret < 0) {
        PLOGE("unshare");
    }
    return ret;
}
#endif

DIR *xopendir(const char *name) {
    DIR *d = opendir(name);
    if (d == nullptr) {
        PLOGE("opendir: %s", name);
    }
    return d;
}

#ifndef SVB_MINGW
DIR *xfdopendir(int fd) {
    DIR *d = fdopendir(fd);
    if (d == nullptr) {
        PLOGE("fdopendir");
    }
    return d;
}
#endif

struct dirent *xreaddir(DIR *dirp) {
    errno = 0;
    for (dirent *e;;) {
        e = readdir(dirp);
        if (e == nullptr) {
            if (errno)
                PLOGE("readdir");
            return nullptr;
        } else if (e->d_name == "."sv || e->d_name == ".."sv) {
            // Filter . and .. for users
            continue;
        }
        return e;
    }
}

#ifndef SVB_WIN32
pid_t xsetsid() {
    pid_t pid = setsid();
    if (pid < 0) {
        PLOGE("setsid");
    }
    return pid;
}

int xsocket(int domain, int type, int protocol) {
    int fd = socket(domain, type, protocol);
    if (fd < 0) {
        PLOGE("socket");
    }
    return fd;
}

int xbind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    int ret = bind(sockfd, addr, addrlen);
    if (ret < 0) {
        PLOGE("bind");
    }
    return ret;
}

int xlisten(int sockfd, int backlog) {
    int ret = listen(sockfd, backlog);
    if (ret < 0) {
        PLOGE("listen");
    }
    return ret;
}

int xaccept4(int sockfd, struct sockaddr *addr, socklen_t *addrlen, int flags) {
    int fd = accept4(sockfd, addr, addrlen, flags);
    if (fd < 0) {
        PLOGE("accept4");
    }
    return fd;
}
#endif

void *xmalloc(size_t size) {
    void *p = malloc(size);
    if (p == nullptr) {
        PLOGE("malloc");
    }
    return p;
}

void *xcalloc(size_t nmemb, size_t size) {
    void *p = calloc(nmemb, size);
    if (p == nullptr) {
        PLOGE("calloc");
    }
    return p;
}

void *xrealloc(void *ptr, size_t size) {
    void *p = realloc(ptr, size);
    if (p == nullptr) {
        PLOGE("realloc");
    }
    return p;
}

#ifndef SVB_WIN32
ssize_t xsendmsg(int sockfd, const struct msghdr *msg, int flags) {
    int sent = sendmsg(sockfd, msg, flags);
    if (sent < 0) {
        PLOGE("sendmsg");
    }
    return sent;
}

ssize_t xrecvmsg(int sockfd, struct msghdr *msg, int flags) {
    int rec = recvmsg(sockfd, msg, flags);
    if (rec < 0) {
        PLOGE("recvmsg");
    }
    return rec;
}

int xpthread_create(pthread_t *thread, const pthread_attr_t *attr,
                    void *(*start_routine) (void *), void *arg) {
    errno = pthread_create(thread, attr, start_routine, arg);
    if (errno) {
        PLOGE("pthread_create");
    }
    return errno;
}
#endif
int xaccess(const char *path, int mode) {
    int ret = access(path, mode);
    if (ret < 0) {
        PLOGE("access %s", path);
    }
    return ret;
}

int xstat(const char *pathname, struct stat *buf) {
    int ret = stat(pathname, buf);
    if (ret < 0) {
        PLOGE("stat %s", pathname);
    }
    return ret;
}

int xlstat(const char *pathname, struct stat *buf) {
    int ret = lstat(pathname, buf);
    if (ret < 0) {
        PLOGE("lstat %s", pathname);
    }
    return ret;
}

int xfstat(int fd, struct stat *buf) {
    int ret = fstat(fd, buf);
    if (ret < 0) {
        PLOGE("fstat %d", fd);
    }
    return ret;
}

#ifndef SVB_MINGW
int xfstatat(int dirfd, const char *pathname, struct stat *buf, int flags) {
    int ret = fstatat(dirfd, pathname, buf, flags);
    if (ret < 0) {
        PLOGE("fstatat %s", pathname);
    }
    return ret;
}
#endif

int xdup(int fd) {
    int ret = dup(fd);
    if (ret < 0) {
        PLOGE("dup");
    }
    return ret;
}

int xdup2(int oldfd, int newfd) {
    int ret = dup2(oldfd, newfd);
    if (ret < 0) {
        PLOGE("dup2");
    }
    return ret;
}

#ifndef SVB_MINGW
int xdup3(int oldfd, int newfd, int flags) {
    int ret = dup3(oldfd, newfd, flags);
    if (ret < 0) {
        PLOGE("dup3");
    }
    return ret;
}
#endif

ssize_t xreadlink(const char *pathname, char *buf, size_t bufsiz) {
    ssize_t ret = readlink(pathname, buf, bufsiz);
    if (ret < 0) {
        PLOGE("readlink %s", pathname);
    } else {
        buf[ret] = '\0';
    }
    return ret;
}

#ifndef SVB_MINGW
ssize_t xreadlinkat(int dirfd, const char *pathname, char *buf, size_t bufsiz) {
    // readlinkat() may fail on x86 platform, returning random value
    // instead of number of bytes placed in buf (length of link)
#if defined(__i386__) || defined(__x86_64__)
    memset(buf, 0, bufsiz);
    ssize_t ret = readlinkat(dirfd, pathname, buf, bufsiz);
    if (ret < 0) {
        PLOGE("readlinkat %s", pathname);
    }
    return ret;
#else
    ssize_t ret = readlinkat(dirfd, pathname, buf, bufsiz);
    if (ret < 0) {
        PLOGE("readlinkat %s", pathname);
    } else {
        buf[ret] = '\0';
    }
    return ret;
#endif
}

int xfaccessat(int dirfd, const char *pathname) {
    int ret = faccessat(dirfd, pathname, F_OK, 0);
    if (ret < 0) {
        PLOGE("faccessat %s", pathname);
    }
#if defined(__i386__) || defined(__x86_64__)
    if (ret > 0 && errno == 0) {
        LOGD("faccessat success but ret is %d\n", ret);
        ret = 0;
    }
#endif
    return ret;
}
#endif

#if defined(SVB_WIN32) && !defined(SVB_MINGW)
#define symlink xxsymlink
#endif
int xsymlink(const char *target, const char *linkpath) {
    int ret = symlink(target, linkpath);
    if (ret < 0) {
        PLOGE("symlink %s->%s", target, linkpath);
    }
    return ret;
}

#if defined SVB_WIN32 && !defined SVB_MINGW
#define SYMLINK_ID "!<symlink>\xff\xfe"
#define SYMLINK_IDLEN	strlen(SYMLINK_ID)
#define SYMLINK_MAXSIZE	1024
int xxsymlink(const char *target, const char *file)
{
    int sz = strlen(target) + 1;
    char buf[sz * sizeof(WCHAR)];

    FILE *lnk = fopen(file, "wb");
    if (!lnk || fprintf(lnk, SYMLINK_ID) < 0)
        return -1;

    if (MultiByteToWideChar(CP_UTF8, 0, target, sz, (LPWSTR)buf, sz) != sz) {
        errno = EINVAL;
        sz = -1;
        goto err;
    }
    sz = fwrite(buf, 1, sizeof(buf), lnk);
    if (sz != sizeof(buf)) {
	sz = -1;
        goto err;
    }
    if (!SetFileAttributes(file, FILE_ATTRIBUTE_SYSTEM)) {
        sz = -1;
        goto err;
    }
    sz = 0;
err:
    fclose(lnk);
    return sz;
}
#endif

#ifndef SVB_MINGW
int xsymlinkat(const char *target, int newdirfd, const char *linkpath) {
    int ret = symlinkat(target, newdirfd, linkpath);
    if (ret < 0) {
        PLOGE("symlinkat %s->%s", target, linkpath);
    }
    return ret;
}

int xlinkat(int olddirfd, const char *oldpath, int newdirfd, const char *newpath, int flags) {
    int ret = linkat(olddirfd, oldpath, newdirfd, newpath, flags);
    if (ret < 0) {
        PLOGE("linkat %s->%s", oldpath, newpath);
    }
    return ret;
}
#endif

#ifndef SVB_WIN32
int xmount(const char *source, const char *target,
    const char *filesystemtype, unsigned long mountflags,
    const void *data) {
    int ret = mount(source, target, filesystemtype, mountflags, data);
    if (ret < 0) {
        PLOGE("mount %s->%s", source, target);
    }
    return ret;
}

int xumount(const char *target) {
    int ret = umount(target);
    if (ret < 0) {
        PLOGE("umount %s", target);
    }
    return ret;
}

int xumount2(const char *target, int flags) {
    int ret = umount2(target, flags);
    if (ret < 0) {
        PLOGE("umount2 %s", target);
    }
    return ret;
}
#endif

int xrename(const char *oldpath, const char *newpath) {
    int ret = rename(oldpath, newpath);
    if (ret < 0) {
        PLOGE("rename %s->%s", oldpath, newpath);
    }
    return ret;
}

int xmkdir(const char *pathname, mode_t mode) {
#ifdef SVB_MINGW
#define mkdir(y, x) mkdir(y)
#endif
    int ret = mkdir(pathname, mode);
    if (ret < 0 && errno != EEXIST) {
        PLOGE("mkdir %s %u", pathname, mode);
    }
    return ret;
}

int xmkdirs(const char *pathname, mode_t mode) {
    int ret = mkdirs(pathname, mode);
    if (ret < 0) {
        PLOGE("mkdirs %s", pathname);
    }
    return ret;
}

#ifndef SVB_MINGW
int xmkdirat(int dirfd, const char *pathname, mode_t mode) {
    int ret = mkdirat(dirfd, pathname, mode);
    if (ret < 0 && errno != EEXIST) {
        PLOGE("mkdirat %s %u", pathname, mode);
    }
    return ret;
}
#endif

void *xmmap(void *addr, size_t length, int prot, int flags,
    int fd, off_t offset) {
    void *ret = mmap(addr, length, prot, flags, fd, offset);
    if (ret == MAP_FAILED) {
        PLOGE("mmap");
        return nullptr;
    }
    return ret;
}

#ifndef SVB_WIN32
ssize_t xsendfile(int out_fd, int in_fd, off_t *offset, size_t count) {
    ssize_t ret = sendfile(out_fd, in_fd, offset, count);
    if (ret < 0) {
        PLOGE("sendfile");
    }
    return ret;
}
#else
ssize_t xsendfile(int out_fd, int in_fd, off_t *offset, size_t count) {
    ssize_t bytes = 0;

    while (count) {
        char buf[count];
        ssize_t read;
        if (offset)
#ifndef SVB_MINGW
            read = pread(in_fd, buf, count, *offset);
#else
        {
            lseek(in_fd, *offset, SEEK_SET);
            offset = nullptr;
            continue;
        }
#endif
        else
            read = xread(in_fd, buf, count);
        if (read < 0) {
            bytes = -1;
            break;
        }
        ssize_t write = xwrite(out_fd, buf, read);
        if (write < 0 || read != write) {
            bytes = -1;
            break;
        }
        count -= read;
        bytes += write;
    }
    
    if (bytes == -1)
        PLOGE("sendfile");

    return bytes;
}
#endif

#ifndef SVB_WIN32
pid_t xfork() {
    int ret = fork();
    if (ret < 0) {
        PLOGE("fork");
    }
    return ret;
}

int xpoll(struct pollfd *fds, nfds_t nfds, int timeout) {
    int ret = poll(fds, nfds, timeout);
    if (ret < 0) {
        PLOGE("poll");
    }
    return ret;
}

int xinotify_init1(int flags) {
    int ret = inotify_init1(flags);
    if (ret < 0) {
        PLOGE("inotify_init1");
    }
    return ret;
}
#endif

#ifndef SVB_MINGW
char *xrealpath(const char *path, char *resolved_path) {
    char buf[PATH_MAX];
    char *ret = realpath(path, buf);
    if (ret == nullptr) {
        PLOGE("xrealpath");
    } else {
        strcpy(resolved_path, buf);
    }
    return ret;
}
#endif

#ifndef SVB_WIN32
int xmknod(const char *pathname, mode_t mode, dev_t dev) {
    int ret = mknod(pathname, mode, dev);
    if (ret < 0) {
        PLOGE("mknod");
    }
    return ret;
}

long xptrace(int request, pid_t pid, void *addr, void *data) {
    long ret = ptrace(request, pid, addr, data);
    if (ret < 0)
        PLOGE("ptrace %d", pid);
    return ret;
}
#endif
