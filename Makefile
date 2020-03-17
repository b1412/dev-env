default:
	@awk -F\: '/^[a-z_]+:/ && !/default/ {printf "- %-20s %s\n", $$1, $$2}' Makefile
help:
	@echo "make up: start containers"
	@echo "make down: docker-compose down -v"
	@echo "make logs [CONTAINER]: get container logs"
	@echo "make restart: make down && make up"
	@echo "make login [CONTAINER]: login into container"
	@echo "make wipe: remove mysql data"
	@echo "make dance: make down, make wipe, make up"
up:
	docker-compose up -d $(filter-out $@,$(MAKECMDGOALS))
down:
	docker-compose down $(filter-out $@,$(MAKECMDGOALS))
logs:
	docker-compose logs -f --tail=200 mood-tracker-$(filter-out $@,$(MAKECMDGOALS))
dance:
	make down && make wipe && make up
restart:
	make down && make up
login:
	docker exec -it mood-tracker-$(filter-out $@,$(MAKECMDGOALS)) sh
wipe:
	docker volume ls | grep mysql | awk '{print $$2}' | xargs docker volume rm
