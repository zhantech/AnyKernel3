DEVICE := $(shell echo ${DEVICE})
BRANCH := $(shell git -C .. rev-parse --abbrev-ref HEAD)

ifeq ($(findstring 10,$(BRANCH)),10)
    ifeq ($(findstring vince,$(DEVICE)),vince)
        NAME := Genom-vince-msm-4.9-AOSP-10
    else
        NAME := Genom-$(DEVICE)-AOSP-10
    endif
    DATE := $(shell date "+%Y%m%d")
    ZIP := $(NAME)-$(DATE).zip
else
    ifeq ($(findstring lavender,$(DEVICE)),lavender)
        NAME := Genom-lavender-AOSP-Pie
    else
    ifeq ($(findstring vince,$(DEVICE)),vince)
        NAME := Genom-vince-MIUI-Oreo
    else
        NAME := Genom-$(DEVICE)-Multi-Pie
    endif
    endif
    DATE := $(shell date "+%Y%m%d")
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
	rm -vf modules/vendor/lib/modules/*.ko
	echo "Cleaning done."

