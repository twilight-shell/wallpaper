PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Wallpaper

install:
	install -d $(DEST)
	cp -r Twilight/Wallpaper/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
