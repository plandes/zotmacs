## makefile automates the build and deployment for Emacs Lisp projects

## Build
#
# type of project
PROJ_TYPE =	elisp


## Project
#
ZS_TEST =	zotsite-test-resources
EL_DEPS +=	$(ZS_TEST)
ADD_CLEAN =	$(ZS_TEST)

## Includes
#
include ./zenbuild/main.mk


## Targets
#
$(ZS_TEST):
		@echo "cloning zotsite for test resources"
		mkdir -p $(ZS_TEST)
		( cd $(ZS_TEST) && git clone https://github.com/plandes/zotsite )
