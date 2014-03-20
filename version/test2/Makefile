#!/bin/bash

CC=x10c++
EXEC=community convert 

all: $(EXEC)

community : ComDetect.x10
	$(CC) -OPTIMIZE=true -o $@ $^ 

convert : Convert.x10
	$(CC) -OPTIMIZE=true -o $@ $^ 

##########################################
# Generic rules
##########################################

clean:
	rm -f *.cc *~ *.h $(EXEC)
