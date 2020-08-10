BRANCH := $(shell git -C .. rev-parse --abbrev-ref HEAD)

NAME := Genom-AOSP-10-Joyeuse-dev

DATE := $(shell date "+%Y%m%d")
COMMIT := $(shell git -C .. rev-parse HEAD | cut -c 1-12)
ZIP := $(NAME)-$(DATE)-$(COMMIT).zip

EXCLUDE := Makefile *.git* *.jar* *placeholder* *.md*

normal: $(ZIP)

$(ZIP):
	zip -r9 "$@" . -x $(EXCLUDE)
	echo "Done creating ZIP: $(ZIP)"

clean:
	rm -vf dtbo.img
	rm -vf *.zip
	rm -vf *.gz-dtb
	rm -vf modules/vendor/lib/modules/*.ko
	echo "Cleaning done."
