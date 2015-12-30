# Container parameters
NAME = larionov/jira
VERSION = $(shell /bin/cat JIRA.VERSION)
JAVA_OPTS = -Djava.io.tmpdir=/var/tmp -XX:-UseAESIntrinsics -Dcom.sun.net.ssl.checkRevocation=false
MEMORY_LIMIT = 8192
CONFIGURE_FRONTEND = FALSE
JIRA_FE_NAME = jira.local
JIRA_FE_PORT = 443
JIRA_FE_PROTO = https
CPU_LIMIT_CPUS = 2-4
CPU_LIMIT_LOAD = 100
IO_LIMIT = 500

# Calculated parameters.
VOLUMES_FROM = $(shell if [ $$(/usr/bin/docker ps -a | /bin/grep -i "$(NAME)" | /bin/wc -l) -gt 0 ]; then /bin/echo -en "--volumes-from="$$(/usr/bin/docker ps -a | /bin/grep -i "$(NAME)" | /bin/tail -n 1 | /usr/bin/awk "{print \$$1}"); fi)
SWAP_LIMIT = $(shell /bin/echo $$[$(MEMORY_LIMIT)*2])
JAVA_MEM_MAX = $(shell /bin/echo $$[$(MEMORY_LIMIT)-32+$(SWAP_LIMIT)])m
JAVA_MEM_MIN = $(shell /bin/echo $$[$(MEMORY_LIMIT)/4])m
CPU_LIMIT_LOAD_THP = $(shell /bin/echo $$[$(CPU_LIMIT_LOAD)*1000])

.PHONY: all build install

all: build install

build:
	/usr/bin/docker build -t $(NAME):$(VERSION) --rm image

install:
	/usr/bin/docker run --publish 8092:8080 --name=jira-$(VERSION) $(VOLUMES_FROM)\
							-e CONFIGURE_FRONTEND="$(CONFIGURE_FRONTEND)"                     \
							-e JAVA_OPTS="$(JAVA_OPTS)"                                       \
							-e JAVA_MEM_MIN="$(JAVA_MEM_MIN)"                                 \
							-e JAVA_MEM_MAX="$(JAVA_MEM_MAX)"                                 \
							-e JIRA_FE_NAME="$(JIRA_FE_NAME)"                                 \
							-e JIRA_FE_PORT="$(JIRA_FE_PORT)"                                 \
							-e JIRA_FE_PROTO="$(JIRA_FE_PROTO)"                               \
							-m $(MEMORY_LIMIT)M --memory-swap $(JAVA_MEM_MAX)                 \
							--oom-kill-disable=false                                          \
							--cpuset-cpus=$(CPU_LIMIT_CPUS) --cpu-quota=$(CPU_LIMIT_LOAD_THP) \
							--blkio-weight=$(IO_LIMIT)                                        \
							-d larionov/jira:$(VERSION)
