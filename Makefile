clean: clean-stack

clean-stack:
	-@docker-compose -f telemetry-stack/docker-compose-$(server).yaml down

clean-virl:
	-@virl down
	-@rm -Rf .virl/

consul-test:
	- sudo curl -fsSL http://10.10.90.10/consul -o /usr/local/bin/consul; chmod +x /usr/local/bin/consul
	- sudo curl -fsSL http://10.10.90.10/consul-esm -o /usr/local/bin/consul-esm; chmod +x /usr/local/bin/consul-esm
	- mkdir -p /etc/consul.d

	# consul service
	- sudo curl -fsSL http://10.10.90.10/systemd/consul.service -o /etc/systemd/system/consul.service

	# configure DNS servers for consul appropriate environment (test/prod)
	- sudo curl -fsSL http://10.10.90.10/systemd/test.resolved.conf -o /etc/systemd/resolved.conf
	- sudo curl -fsSL http://10.10.90.10/consul.d/common.json -o /etc/consul.d/common.json
	- sudo curl -fsSL http://10.10.90.10/consul.d/test.json -o /etc/consul.d/test.json
	- sudo systemctl daemon-reload
	- sudo systemctl enable --now consul
	- sudo systemctl enable --now consul-esm
	- sudo systemctl restart systemd-resolved

consul-prod:
	- sudo curl -fsSL http://10.10.90.10/consul -o /usr/local/bin/consul; chmod +x /usr/local/bin/consul
	- sudo curl -fsSL http://10.10.90.10/consul-esm -o /usr/local/bin/consul-esm; chmod +x /usr/local/bin/consul-esm
	- mkdir -p /etc/consul.d

	# consul service
	- sudo curl -fsSL http://10.10.90.10/systemd/consul.service -o /etc/systemd/system/consul.service

	# configure DNS servers for consul appropriate environment (test/prod)
	- sudo curl -fsSL http://10.10.90.10/systemd/prod.resolved.conf -o /etc/systemd/resolved.conf
	- sudo curl -fsSL http://10.10.90.10/consul.d/common.json -o /etc/consul.d/common.json
	- sudo curl -fsSL http://10.10.90.10/consul.d/prod.json -o /etc/consul.d/prod.json
	- sudo systemctl daemon-reload
	- sudo systemctl enable --now consul
	- sudo systemctl enable --now consul-esm
	- sudo systemctl restart systemd-resolved

lab: stack stack-status



stack: stack-pull stack-build stack-up

stack-up:
	docker-compose -f telemetry-stack/docker-compose-$(server).yaml up -d

stack-build:
	docker-compose -f telemetry-stack/docker-compose-$(server).yaml build

stack-pull:
	docker-compose -f telemetry-stack/docker-compose-$(server).yaml pull

stack-status:
	docker-compose -f telemetry-stack/docker-compose-$(server).yaml ps

stage: stack-pull stack-build

tap:
	docker-compose -f telemetry-stack/docker-compose-$(server).yaml exec unified-pipeline tail -n 1000 telemetry_model_raw.txt

# virl:
# 	@virl up --provision

# clean: clean-netsim clean-nso clean-virl
#
# clean-virl:
# 	-@virl down
# 	-@rm -Rf .virl/
#
# clean-netsim:
# 	-@echo "Stopping All Netsim Instances..."
# 	-@killall confd
# 	-@rm -Rf netsim/
# 	-@rm README.netsim
#
# clean-nso:
# 	-@echo "Stopping NSO..."
# 	-@ncs --stop
# 	-@rm -Rf README.ncs agentStore state.yml logs/ ncs-cdb/ ncs-java-vm.log ncs-python-vm.log ncs.conf state/ storedstate target/
#
# dev: deps netsim nso
#
# deps:
# 	./lab_prep.sh && python3.6 -m venv venv && source venv/bin/activate && pip install -r requirements.txt
#
#
# netsim:
# 	-@ncs-netsim --dir netsim create-device cisco-ios xe
# 	-@ncs-netsim --dir netsim add-device cisco-iosxr xr
# 	-@ncs-netsim --dir netsim add-device cisco-nx nx
# 	-@ncs-netsim start
#
# nso:
# 	ncsc -c packages/pipe-yaml/yaml-c.cli -o packages/yaml-c.ccl
# 	ncs-setup --dest . --package cisco-ios --package cisco-iosxr --package cisco-nx
# 	export PATH=$$PATH:packages/pipe-yaml; echo $$PATH; ncs
#
# test: clean-netsim clean-nso deps virl nso virl
#
# virl: nso
# 	@virl up --provision
# 	virl generate nso --syncfrom
