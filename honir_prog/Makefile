TARGET =  sffixpix
CC = s++
SRCDIR = src
LIBS = -lsfitsio
CFLAGS =
#
# 2021/11/08 H. Akitaya
# If you meet the following error when executing sffixpix,
# activate the next CFLAGS.
# (error sample)
#  ld-elf.so.1: /usr/local/lib/compat/libstdc++.so.6: version CXXABI_1.3.9 required by /.../sffixpix not found
#
#
#CFLAGS = -static-libstdc++

all: $(TARGET)

sffixpix: $(SRCDIR)/sffixpix.cc
	$(CC) -o sffixpix $(SRCDIR)/sffixpix.cc $(LIBS) $(CFLAGS)

simg: $(SRCDIR)/simg.sh
	cp $(SRCDIR)/simg.sh simg
	chmod a+x simg

