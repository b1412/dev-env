default:
	@awk -F\: '/^[a-z_]+:/ && !/default/ {printf "- %-20s %s\n", $$1, $$2}' Makefile
help:
	@echo "make up: start containers"
	@echo "make down: docker-compose down -v"
	@echo "make logs [CONTAINER]: get container logs"
pull:
	docker-compose pull
up:
	docker-compose up -d $(filter-out $@,$(MAKECMDGOALS))
down:
	docker-compose down $(filter-out $@,$(MAKECMDGOALS))
logs:
	docker-compose logs -f --tail=200 $(filter-out $@,$(MAKECMDGOALS))