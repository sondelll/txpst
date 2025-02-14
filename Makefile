build: typst
	docker build -t txpst:latest .

container: build
	docker run -itd -p 8787:8787 --name txp txpst:latest

typst: typst-get
	cd build && tar -xJf ./typst-x86_64-unknown-linux-musl.tar.xz
	cp ./build/typst-x86_64-unknown-linux-musl/typst ./build/typst

typst-get: prep
	wget -P ./build https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz

prep: clean
	mkdir ./build

clean:
	rm -rf ./build
