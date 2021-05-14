PROG ?= tomb
PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

SYSTEM_EXTENSION_DIR ?= $(LIBDIR)/password-store/extensions

BASHCOMPDIR ?= $(PREFIX)/share/bash-completion/completions
ZSHCOMPDIR ?= $(PREFIX)/share/zsh/site-functions

all:
	@echo "pass-$(PROG) is a shell script and does not need compilation, it can be simply executed."
	@echo ""
	@echo "To install it try \"make install\" instead."
	@echo

install:
	@install -d "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/" "$(DESTDIR)$(MANDIR)/man1" \
				  "$(DESTDIR)$(BASHCOMPDIR)" "$(DESTDIR)$(ZSHCOMPDIR)" \
				  "$(DESTDIR)$(LIBDIR)/systemd/system/"
	@install -m 0755 $(PROG).bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash"
	@install -m 0755 open.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/open.bash"
	@install -m 0755 close.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/close.bash"
	@install -m 0644 pass-$(PROG).1 "$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
	@install -m 0644 timer/pass-close@.service "$(DESTDIR)$(LIBDIR)/systemd/system/pass-close@.service"
	@install -m 0644 "completion/pass-$(PROG).bash" "$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)"
	@install -m 0644 "completion/pass-$(PROG).zsh" "$(DESTDIR)$(ZSHCOMPDIR)/_pass-$(PROG)"
	@install -m 0644 "completion/pass-open.zsh" "$(DESTDIR)$(ZSHCOMPDIR)/_pass-open"
	@install -m 0644 "completion/pass-close.zsh" "$(DESTDIR)$(ZSHCOMPDIR)/_pass-close"
	@echo
	@echo "pass-$(PROG) is installed succesfully"
	@echo

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash" \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/open.bash" \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/close.bash" \
		"$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1" \
		"$(DESTDIR)$(LIBDIR)/systemd/system/pass-close@.service" \
		"$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-$(PROG)" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-open" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-close"


COVERAGE ?= true
TMP ?= /tmp/pass-tomb
PASS_TEST_OPTS ?= --verbose --immediate --chain-lint --root=/tmp/sharness
T = $(sort $(wildcard tests/*.sh))
export COVERAGE TMP

tests: $(T)
	@tests/results

$(T):
	@$@ $(PASS_TEST_OPTS)


lint:
	shellcheck -s bash $(PROG).bash open.bash close.bash tests/commons tests/results

clean:
	@rm -vrf tests/test-results/ tests/gnupg/random_seed


.PHONY: install uninstall tests $(T) lint clean
