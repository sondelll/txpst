
x86-docker:
	docker build -t txpst:latest .

metal-docker:
	docker build -t txpst:latest -f aarch64.Dockerfile .

docker-run:
	docker run -itd -p 8787:8787 --name txp txpst:latest

docker-refresh:
	docker stop txp && docker rm txp && docker run -itd -p 8787:8787 --name txp txpst:latest