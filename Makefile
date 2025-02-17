
build-x86: typst
	docker build -t txpst:latest .

container: build
	docker run -itd -p 8787:8787 --name txp txpst:latest

typst: typst-get-x86
	cd .build && tar -xJf ./_typst.tar.xz
	cp ./.build/_typst/typst ./build/typst

typst-get-x86: ./.build/typst.tar.xz
	wget -O _typst.tar.xz -P ./.build https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz

typst-get-aarch64: ./.build/typst.tar.xz
	wget -O _typst.tar.xz -P ./.build https://github.com/typst/typst/releases/download/v0.12.0/typst-aarch64-unknown-linux-musl.tar.xz

prep: clean
	mkdir ./build

clean:
	rm -rf ./.build
