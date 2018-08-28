TARGET =  sffixpix
CC = s++
SRCDIR = src
LIBS = -lsfitsio

all: $(TARGET)

sffixpix: $(SRCDIR)/sffixpix.cc
	$(CC) -o sffixpix $(SRCDIR)/sffixpix.cc $(LIBS)

simg: $(SRCDIR)/simg.sh
	cp $(SRCDIR)/simg.sh simg
	chmod a+x simg

