TARGET = LinenAlert.dylib

CC = gcc
LD = $(CC)
CFLAGS = -isysroot /User/sysroot \
	 -I. \
	 -I.. \
	 -Wall \
	 -DTARGET_OS_IPHONE=1 \
	 -c
LDFLAGS = -isysroot /User/sysroot \
	  -w \
	  -dynamiclib \
	  -lobjc \
	  -lsubstrate \
	  -framework CoreFoundation \
	  -framework Foundation \
	  -framework CoreGraphics \
	  -framework UIKit

OBJECTS = $(patsubst %.m, %.o, $(wildcard *.m))

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS)
	sudo chown root:wheel $(TARGET)
	sudo cp $(TARGET) /Library/MobileSubstrate/DynamicLibraries/

clean:
	rm -rf $(TARGET) $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^

