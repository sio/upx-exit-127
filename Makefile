.PHONY: demo
demo: demo-packed
	./demo-unpacked
	./demo-packed
	unshare --map-root-user \
	unshare --root=. \
	./demo-unpacked
	unshare --map-root-user \
	unshare --root=. \
	./demo-packed

demo-unpacked: demo.c
	$(CC) $< -o $@ -static

demo-packed: demo-unpacked
	upx -V
	upx $< -o $@
	touch $@
	upx --fileinfo $@

.PHONY: clean
clean:
	-$(RM) demo-unpacked demo-packed
