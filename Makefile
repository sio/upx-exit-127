.PHONY: demo
demo: demo-packed
	unshare --map-root-user \
	unshare --root=. \
	./$<

demo-unpacked: demo.go
	go build -o $@

demo-packed: demo-unpacked
	upx -V
	upx $< -o $@ --best --lzma
	touch $@

.PHONY: clean
clean:
	$(RM) demo-unpacked demo-packed
