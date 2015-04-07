## Run NGINX in a container on top of [phusion/baseimage](https://github.com/phusion/baseimage-docker)

	docker build \
		 --tag crobays/nginx \
		 .

	docker run \
		-v ./:/project \
		-e PUBLIC_PATH=/project/public \
		-e TIMEZONE=Etc/UTC \
		-it --rm \
		crobays/nginx
