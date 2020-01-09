DEVICE := $(shell echo ${DEVICE})
BRANCH := $(shell git -C .. rev-parse --abbrev-ref HEAD)

ifeq ($(findstring 10,$(BRANCH)),10)
    ifeq ($(findstring lavender,$(DEVICE)),lavender)
        NAME := Genom-Multi-10-lavender
    else
        NAME := Genom-AOSP-10-$(DEVICE)
    endif    
    DATE := $(shell date "+%Y%m%d-%H%M")
    ZIP := $(NAME)-$(DATE).zip
else
    NAME := Genom-Multi-Pie-$(DEVICE)
    DATE := $(shell date "+%Y%m%d-%H%M")
    ZIP := $(NAME)-$(DATE).zip
endif

EXCLUDE := Makefile *.git* *.jar* *placeholder* *.md*

normal: $(ZIP)

$(ZIP):
	sed -i 's/universal/${DEVICE}/g' anykernel.sh
	zip -r9 "$@" . -x $(EXCLUDE)
	echo "Done creating ZIP: $(ZIP)"

clean:
	rm -vf *.zip
	rm -vf *.gz-dtb
	rm -vf kernel/*.gz
	rm -vf dtbs/*.dtb
	rm -vf modules/vendor/lib/modules/*.ko
	echo "Cleaning done."
