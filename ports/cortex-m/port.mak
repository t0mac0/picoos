#
# Copyright (c) 2011-2013, Ari Suutari <ari@stonepile.fi>.
# Copyright (c) 2004,      Dennis Kuschel / Swen Moczarski.
# All rights reserved. 
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. The name of the author may not be used to endorse or promote
#     products derived from this software without specific prior written
#     permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT,  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.


#  This file is originally from the pico]OS realtime operating system
#  (http://picoos.sourceforge.net).


# Set default compiler.
# Possible compilers are currently GCC (GNU C).
ifeq '$(strip $(COMPILER))' ''
COMPILER = GCC
endif
export COMPILER

ifeq '$(strip $(CORTEX))' ''
CORTEX=m3
endif

# Set to 1 to include generic pico]OS "findbit" function
ifeq '$(strip $(CORTEX))' 'm0'
GENERIC_FINDBIT = 1
else
GENERIC_FINDBIT = 0
endif

# Define extensions
EXT_C   = .c
EXT_ASM = .s
EXT_INT = .i
EXT_OBJ = .o
EXT_LIB = .a
EXT_OUT = .elf


#----------------------------------------------------------------------------
#  GNU C
#

# Define tools: compiler, assembler, archiver, linker
CXX = arm-none-eabi-g++
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc
AR = arm-none-eabi-ar
LD = arm-none-eabi-gcc

# Define to 1 if CC outputs an assembly file
CC2ASM = 0

# Define to 1 if assembler code must be preprocessed by the compiler
A2C2A  = 0

# Define general options
OPT_CC_INC   = -I
OPT_CC_DEF   = -D
OPT_CC_OFILE = -o
OPT_AS_INC   = -I
OPT_AS_DEF   = -D
OPT_AS_OFILE = -o
OPT_AR_ADD   =
OPT_LD_SEP   =
OPT_LD_PFOBJ =
OPT_LD_PFLIB =
OPT_LD_FIRST = -Wl,--start-group
OPT_LD_LAST  = -lc -Wl,--end-group
OPT_LD_OFILE = -o

# Set global defines for compiler / assembler
CDEFINES += GCC
ADEFINES += GCC

# Set global includes
CINCLUDES = .
AINCLUDES = .

# Distinguish between build modes
ifeq '$(BUILD)' 'DEBUG'
  CFLAGS_COMMON   += -g
  ASFLAGS         += -g
  CDEFINES        += _DBG
  ADEFINES        += _DBG
else
  CFLAGS_COMMON   += -O2 -fomit-frame-pointer
  CDEFINES        += _REL
  ADEFINES        += _REL
endif

CFLAGS_COMMON  += -mthumb
LDFLAGS        += -mthumb

# Define Compiler Flags
# TODO: extract -mcpu as constant
CFLAGS_COMMON += -fno-common -mcpu=cortex-$(CORTEX) -ffunction-sections -fdata-sections
CFLAGS_COMMON += -Wcast-align -Wall -Wextra -Wshadow -Wpointer-arith
CFLAGS_COMMON += -Wno-unused-parameter -Wno-unused-label -Wno-unused-but-set-variable

ifeq '$(strip $(CORTEX))' 'm4'
CFLAGS_COMMON += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
endif

CFLAGS += -Wbad-function-cast -Wno-strict-prototypes -Wmissing-prototypes
CFLAGS += $(CFLAGS_COMMON) $(EXTRA_CFLAGS)
CFLAGS += -c
CXXFLAGS += -fno-threadsafe-statics -fno-exceptions -fno-rtti $(CFLAGS_COMMON) $(EXTRA_CFLAGS) -c

# Define Assembler Flags
# TODO: extract -mcpu as constant
ASFLAGS += -c -mcpu=cortex-$(CORTEX) -Wa,-gstabs -Wa,-I${CURDIR}/ports/arm
ASFLAGS += -x assembler-with-cpp


# Define Linker Flags
#  -Wl   : pass arguments to the linker
#  -Map  : create a map file
#  --cref: add cross reference to the map file
LDFLAGS += -L$(DIR_PORT)/boot  $(addprefix -T,$(LD_SCRIPTS)) -mcpu=cortex-$(CORTEX)
ifeq '$(strip $(CORTEX))' 'm4'
LDFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
endif
#
# newlib-nano would be nice. But first there
# were odd problems with getc(). After that 
# odd problems with malloc'ed memory.
# But to try it, uncomment following line:
#LDFLAGS += --specs=nano.specs
LDFLAGS += -Wl,--wrap=malloc,--wrap=free,--wrap=realloc,--wrap=__sfp_lock_acquire,--wrap=__sfp_lock_release,--wrap=fopen
LDFLAGS += -nostartfiles -Wl,-Map,$(DIR_OUT)/$(TARGET).map,--cref,--gc-sections

# Define archiver flags
ARFLAGS = cr 

ifneq '$(strip CMSIS_MODULES)' ''
export CMSIS_MODULES
endif

MODULES += $(CMSIS_MODULES)
