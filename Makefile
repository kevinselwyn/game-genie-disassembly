NAME := gamegenie
BANK := bank

all: build

build: $(NAME).asm
	@# Build nesasm
	@make -C utilities/nesasm > /dev/null

	@# Generate CHR
	@python utilities/img2chr/img2chr.py $(NAME).png

	@# 0x1000-sized Bank
	@utilities/nesasm/nesasm $(BANK).asm -raw > /dev/null
	@tail -c 4096 $(BANK).nes > $(BANK).raw

	@# Compile ROM
	@utilities/nesasm/nesasm $(NAME).asm

	@# Compare To Original ROM
	@if [ -e orig/$(NAME).nes ] ; then \
		if [ $(shell cat $(NAME).nes | openssl md5 | tail -c 32) != $(shell cat orig/$(NAME).nes | openssl md5 | tail -c 32) ] ; then \
			echo "Invalid file" ; \
		fi ; \
	fi

	@# Cleanup
	@rm -f $(BANK).nes $(BANK).raw

clean:
	@rm -f $(BANK).nes $(BANK).raw
	@rm -f $(NAME).chr $(NAME).nes