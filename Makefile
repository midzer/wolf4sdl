CONFIG ?= config.default
-include $(CONFIG)


BINARY    ?= index.html
PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)

INSTALL         ?= install
INSTALL_PROGRAM ?= $(INSTALL) -m 555 -s
INSTALL_MAN     ?= $(INSTALL) -m 444
INSTALL_DATA    ?= $(INSTALL) -m 444


SDL_CONFIG  ?= 
CFLAGS_SDL  ?= 
LDFLAGS_SDL ?= 


CFLAGS += $(CFLAGS_SDL)

#CFLAGS += -Wall
#CFLAGS += -W
#CFLAGS += -Wpointer-arith
#CFLAGS += -Wreturn-type
#CFLAGS += -Wwrite-strings
#CFLAGS += -Wcast-align
CFLAGS += -sUSE_SDL=2
CFLAGS += -sUSE_SDL_MIXER=2
CFLAFS += -sSUPPORT_ERRNO=0
CFLAGS += -O3
CFLAGS += -g0
CFLAGS += -flto

CCFLAGS += $(CFLAGS)
CCFLAGS += -std=gnu99
CCFLAGS += -Werror-implicit-function-declaration
#CCFLAGS += -Wimplicit-int
#CCFLAGS += -Wsequence-point

CXXFLAGS += $(CFLAGS)

LDFLAGS += $(LDFLAGS_SDL)
ifneq (,$(findstring MINGW,$(shell uname -s)))
LDFLAGS += -static-libgcc
endif
LDFLAGS += -sASYNCIFY
LDFLAGS += -sWASM=1
LDFLAGS += -sINITIAL_MEMORY=80mb
LDFLAGS += -sENVIRONMENT=web
LDFLAGS += --closure 1
LDFLAGS += --preload-file data

SRCS :=
SRCS += dosbox/dbopl.cpp
SRCS += id_ca.cpp
SRCS += id_in.cpp
SRCS += id_pm.cpp
SRCS += id_sd.cpp
SRCS += id_us_1.cpp
SRCS += id_vh.cpp
SRCS += id_vl.cpp
SRCS += signon.cpp
SRCS += wl_act1.cpp
SRCS += wl_act2.cpp
SRCS += wl_agent.cpp
SRCS += wl_atmos.cpp
SRCS += wl_cloudsky.cpp
SRCS += wl_debug.cpp
SRCS += wl_draw.cpp
SRCS += wl_floorceiling.cpp
SRCS += wl_game.cpp
SRCS += wl_inter.cpp
SRCS += wl_main.cpp
SRCS += wl_menu.cpp
SRCS += wl_parallax.cpp
SRCS += wl_play.cpp
SRCS += wl_state.cpp
SRCS += wl_text.cpp
SRCS += states.cpp

DEPS = $(filter %.d, $(SRCS:.c=.d) $(SRCS:.cpp=.d))
OBJS = $(filter %.o, $(SRCS:.c=.o) $(SRCS:.cpp=.o))

.SUFFIXES:
.SUFFIXES: .c .cpp .d .o

Q ?= @

all: $(BINARY)

ifndef NO_DEPS
depend: $(DEPS)

ifeq ($(findstring $(MAKECMDGOALS), clean depend Data),)
-include $(DEPS)
endif
endif

$(BINARY): $(OBJS)
	@echo '===> LD $@'
	$(Q)$(CXX) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

.c.o:
	@echo '===> CC $<'
	$(Q)$(CC) $(CCFLAGS) -c $< -o $@

.cpp.o:
	@echo '===> CXX $<'
	$(Q)$(CXX) $(CXXFLAGS) -c $< -o $@

.c.d:
	@echo '===> DEP $<'
	$(Q)$(CC) $(CCFLAGS) -MM $< | sed 's#^$(@F:%.d=%.o):#$@ $(@:%.d=%.o):#' > $@

.cpp.d:
	@echo '===> DEP $<'
	$(Q)$(CXX) $(CXXFLAGS) -MM $< | sed 's#^$(@F:%.d=%.o):#$@ $(@:%.d=%.o):#' > $@

clean distclean:
	@echo '===> CLEAN'
	$(Q)rm -fr $(DEPS) $(OBJS) $(BINARY) $(BINARY).exe

install: $(BINARY)
	@echo '===> INSTALL'
	$(Q)$(INSTALL) -d $(PREFIX)/bin
	$(Q)$(INSTALL_PROGRAM) $(BINARY) $(PREFIX)/bin
