.PHONY: default clean

SRC_DIR = src
TARGET_DIR = bin

## our target
TARGET = $(TARGET_DIR)/main.js

# constants

## compiler
CC = elm-make

## compilation flags that should always be used
CFLAGS = --warn

## output flags
OFLAGS = --output=$(TARGET)

## file(s) to compile
FILES = $(SRC_DIR)/Main.elm $(SRC_DIR)/Post.elm

# compile our Elm file(s) to our JS target
default: $(TARGET)

# compile executable file
$(TARGET): $(FILES)
	$(CC) $(CFLAGS) $(OFLAGS) $(FILES)

# clean compiled files
clean:
	rm -f $(TARGET_DIR)/*.js

mrproper:
	rm -rf $(TARGET_DIR)/*
