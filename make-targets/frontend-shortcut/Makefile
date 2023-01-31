#################################################################
## SECTION: Fast access to the dev and prod UI
#################################################################


connect-prod: ## Connect to the prod server with port forwarding for access to the UI
	sudo killall ssh || true
	ssh -L 19443:localhost:443 $(GROUP_CODE)-$(COUNTRY_CODE)-prod

frontend-prod: ## Access to the prod frontend
	sudo ifconfig lo0 ${DEV_IP} -alias || true
	sudo ifconfig lo0 ${PROD_IP} -alias || true
	sudo ifconfig lo0 ${PROD_IP} alias || true
	echo "rdr pass on lo0 inet proto tcp from any to ${PROD_IP} port 443 -> 127.0.0.1 port 19443" | sudo pfctl -ef - || true
	open https://${PROD_IP}

connect-dev: ## Connect to the dev server with port forwarding for access to the UI
	sudo killall ssh || true
	ssh -L 19443:localhost:443 $(GROUP_CODE)-$(COUNTRY_CODE)-dev

frontend-dev: ## Access to the dev frontend
	sudo ifconfig lo0 ${PROD_IP} -alias || true
	sudo ifconfig lo0 ${DEV_IP} -alias || true
	sudo ifconfig lo0 ${DEV_IP} alias || true
	echo "rdr pass on lo0 inet proto tcp from any to ${DEV_IP} port 443 -> 127.0.0.1 port 19443" | sudo pfctl -ef -|| true
	open https://${DEV_IP}
