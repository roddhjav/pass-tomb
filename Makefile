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
	@echo "To install it try \"make install\" instead."

install:
	@install -Dm0755 $(PROG).bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash"
	@install -Dm0755 open.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/open.bash"
	@install -Dm0755 close.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/close.bash"
	@install -Dm0755 timer.bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/timer.bash"
	@install -Dm0644 pass-close@.service "$(DESTDIR)$(LIBDIR)/systemd/system/pass-close@.service"
	@install -Dm0644 share/pass-$(PROG).1 "$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
	@install -Dm0644 share/pass-$(PROG).bash "$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)"
	@install -Dm0644 share/pass-$(PROG).zsh "$(DESTDIR)$(ZSHCOMPDIR)/_pass-$(PROG)"
	@install -Dm0644 share/pass-open.zsh "$(DESTDIR)$(ZSHCOMPDIR)/_pass-open"
	@install -Dm0644 share/pass-close.zsh "$(DESTDIR)$(ZSHCOMPDIR)/_pass-close"
	@install -Dm0644 share/pass-timer.zsh "$(DESTDIR)$(ZSHCOMPDIR)/_pass-timer"
	@echo "pass-$(PROG) is installed succesfully"

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash" \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/open.bash" \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/close.bash" \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/timer.bash" \
		"$(DESTDIR)$(LIBDIR)/systemd/system/pass-close@.service" \
		"$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1" \
		"$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-$(PROG)" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-open" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-close" \
		"$(DESTDIR)$(ZSHCOMPDIR)/_pass-timer"


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
