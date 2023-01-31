# GROUP Country deployment

## JIRA board

* Related [Jira EPIC](https://realimpactanalytics.atlassian.net/browse/<__TICKET_NUMBER__>)

## Confluence Space

__TODO__

## Access to environment

__TODO__

For the first time you will need to use the password stored on [Vault](https://vault-cloud.rianet.io/ui/vault/secrets/secret/show/Customers). If nothing already exists for your deployment create it or ask support to provision the project (Vault/jira/confluence etc...)

## SSH connection

### Add the server connections details to your ssh config

```bash
vi ${HOME/.ssh/config}

Host <group>-<country code on 2 chars>-dev
  User <user>
  Hostname <dev-server-ip>
  IdentityFile ~/.ssh/id_rsa

Host <group>-<country code on 2 chars>-prod
  User <user>
  Hostname <prod-server-ip>
  IdentityFile ~/.ssh/id_rsa
```

### Connect to the server

For the first time you will need to use the password stored on [Vault](https://vault-cloud.rianet.io/ui/vault/secrets/secret/show/Customers/__GROUP_CODE_TO_SETUP__/___CODE_TO_SETUP__/EngineRoom/access/dev_server)

```bash
ssh <group>-<country code on 2 chars>-dev
```

Then you can setup your public key to avoid having to use the password all the time:

```bash
# If you are the first one to connect to the server
mkdir -p .ssh && chmod 744 .ssh
vi .ssh/authorized_keys # Add your public key to the list
```

Note: Depending of you generated ssh key you might change the private key to use.

## Useful resources

### File structure

* ./secrets/certs: tls certificates. Please do not commit certificates here.
* ./secrets/github_deploy_key: github ssh keys. Please do not commit keys here.
* ./config: product consul configuration used by the deployer
* ./deployment: docker-compose file of the project used by the deployer. This file is often composed after individual component docker-compose file. Generation might be manual or automatic
* ./docs: more documentation
* ./local_assets: reserved folder for local resources in this environment. Not used by UB2. It's your safe space. It also contains some reference scripts that are usually useful.
* ./make-targets: makefile internals
* ./seeds: data seeds used by the deployer

### Dev Server

#### Infrastructure

* XX CPU cores with X threads / core (output of `lscpu` command)
* XXGB memory (output of `free -m`)
* Disk information: (output of `df -h`)

## Operational tools

```bash
❯ make

Make targets (run 'make <target>')



 Targets for configuring local docker client to use deployment's dev and prod environments
  * setup-docker-context                    Configures local docker client to use remote docker daemons as targets
  * use-remote-docker-dev                   Switch your local docker client to use remote docker daemon on dev server
  * use-remote-docker-prod                  Switch your local docker client to use remote docker daemon on prod server
  * use-local-docker                        Switch your local docker client to use default local running docker daemon

 Deployment targets on servers using docker compose (locally on servers)
  * deploy                                  Deploys in offline mode (images need to be loaded preliminarly with docker load -i <images_tarball>)
  * deploy-daemon                           Deploys in daemon mode watching for remote git changes on the delivery repository
  * force-redeploy-daemon                   Force redeploys in daemon mode on the same git commit
  * deployer-daemon-logs                    Get the deployer daemon logs
  * ensure-ria-network                      Ensures the 'ria' docker network required for deployments exists
  * ensure-ria-network-daemonized           Ensures the 'ria' docker network required for daemonized deployments exists
  * clean-deployment                        Resets a standalone deployment stack
  * clean-deployer                          Resets a standalone deployer
  * clean                                   Fully resets a standalone deployment
  * clean-daemonized-deployment             Resets a daemonized deployment stack
  * clean-daemonized-deployer               Resets a daemonized deployer
  * clean-daemonized                        Fully resets a daemonized deployment

 Deployment targets on a swarm cluster (locally on the manager server)
  * swarm-deploy                            Deploys in the swarm cluster
  * swarm-ensure-ria-network                Ensures the 'ria' docker network required for deployments in a swarm cluster exists
  * swarm-clean-deployment                  Resets a standalone deployment stack in a swarm cluster
  * swarm-clean-deployer                    Resets a standalone deployer in a swarm cluster
  * swarm-clean                             Fully resets a standalone deployment in a swarm cluster

 Install docker unix compatible credentials
  * docker-login                            Installs interactively the connection to Docker Hub for UB2
  * check-docker-login                      Checks that the connection to Docker Hub is properly configured to be used by UB2

 ETL provisioning
  * build-etl                               Build etl-provisioning image
  * provision-etl-locally                   Build and runs the provisioning on the local minio instance
  * provision-etl-dev-server                Build and runs the provisioning for deploying on the dev server
  * publish-etl                             Build and push etl-provisioning image

 Fast access to the dev and prod UI
  * connect-prod                            Connect to the prod server with port forwarding for access to the UI
  * frontend-prod                           Access to the prod frontend
  * connect-dev                             Connect to the dev server with port forwarding for access to the UI
  * frontend-dev                            Access to the dev frontend

 Targets for configuring local docker client to use deployment's dev and production environments
  * create-deploy-key                       Generates a ssh key to upload to github as deploy key

 Housekeeing tasks
  * compose-cleanup-airflow-logs            In compose mode. Cleanup airflow scheduler and worker logs + spark tmp folder in the airflow-worker
  * swarm-cleanup-airflow-logs              In swarm mode. Cleanup airflow scheduler and worker logs + spark tmp folder in the airflow-worker

 Packaging targets for offline deployments
  * packages                                Generates docker images tarball for offline deployment
  * download-images                         Downloads the deployment docker images fron Docker Hub for local availability (requires docker login and an account on HUB)
  * package-images                          Packages the deployment docker images into a tarball for offline deployment
  * package-repo                            Packages the git repository receipe for offline deployment
  * mirror-repo-on-remote-dev-server        Upload the repository tarball to the remote dev server
  * mirror-repo-on-remote-prod-server       Upload the repository tarball to the remote prod server
  * images-package-parallel-upload          Uploads the docker images tarball in parallel for faster offline deployments
```

### Use the context

```bash
make use-remote-docker-dev
```

Check it works, you should get the detailled of the remote server

```bash
docker info

...
Kernel Version: 4.14.35-1902.7.3.1.el7uek.x86_64
 Operating System: Oracle Linux Server 7.7
...
```

Note: To use your local docker back again just use

```bash
make use-local-docker
```

## Provisioning issues / Test docker provisioning is working properly

### Test host IP is accessible from inside containers

Keycloak gatekeeper needs to be able to access keycloak server but using the exeternal way like a user would do. Thus the IP/dns of the deployment exposed by Traefik gateway needs to be accessible from both the host and from inside the containers.

To validate it works, you need to get the same output from both the host and inside containers

* From the host:

```bash

[ria@ojengroom01 <delivery-repository>]$ curl -skSL -X GET https://10.1.59.58/auth
<!--
  ~ JBoss, Home of Professional Open Source.
  ~ Copyright (c) 2011, Red Hat, Inc., and individual contributors
  ~ as indicated by the @author tags. See the copyright.txt file in the
  ~ distribution for a full listing of individual contributors.
  ~
  ...
  ~
  ~ You should have received a copy of the GNU Lesser General Public
  ~ License along with this software; if not, write to the Free
  ~ Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
  ~ 02110-1301 USA, or see the FSF site: http://www.fsf.org.
  -->
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Welcome to Keycloak</title>
```

and from any container (here it's failing):

```bash
docker run -i --rm --entrypoint curl riaktrsnd/keycloak-gatekeeper:7.0.0-1 -skSL https://10.1.59.58/auth
curl: (7) Failed to connect to 10.1.59.58 port 443: Host is unreachable
```

## Deploy the product

The deployment strategy depends on the availability of the target server and the tools available on it.

### The target has access to Docker Hub, GitHub and is accessible via ssh.

Requirements:

* Logged in on Docker Hub.
  * To create a user check for a specific deployment, check [this](./docs/docker_hub.md)
* Logged in via ssh.

```bash
git clone https://github.com/RealImpactAnalytics/<delivery-repository>.git
cd <delivery-repository>.git
```

### The target doesn't have access to Docker Hub, GitHub and is accessible via ssh.

Requirements:

* setup VPN and connect
* setup docker context: `make setup-docker-context`

```bash
make packages

# Upload images to server
make load-images

# Upload repository to server and install it in the proper location
make mirror-repo-on-remote-<dev|production>-server
```

Then go on the server and deploy

```bash
cd /RIA/<delivery-repo-name>
make deploy
```

Check no container is restarting (or troubleshoot)

```bash
docker ps -a | grep -i restart
```

###  The target doesn't have access to Docker Hub, GitHub, nor is accessible via ssh.

Provide a value to DELIVERY_REPO_NAME variable in the Makefile.
In the ub2 configuration files, make sure that ***PullGit*** and ***PullDockerImages*** are correctly setup for that environment

Then use this command:

```bash
make packages
```

This will generate two files:
<DELIVERY_REPO_NAME>-git-repo-<DATE>.tar.gz
<DELIVERY_REPO_NAME>-git-images-<DATE>.tar.gz

These files represent the package. After transfert on the target server in the expected location you should do:
```bash
 docker load -i <DELIVERY_REPO_NAME>-images--<DATE>.tar.gz
 mkdir <DELIVERY_REPO_NAME>-git-repo-<DATE>
 tar -xvf <DELIVERY_REPO_NAME>-git-repo-<DATE>.tar.gz -C ./<DELIVERY_REPO_NAME>-git-repo-<DATE>
```

Then you should be in a situation where you can interact with the delivery repository on your offline server.

###  Directly mirror your repo remotely with make mirror-repo-on-remote-dev-server.

- Go to the server and find out the path to rsync: which rsync (normally `/bin/rsync`)

- Edit the `/etc/sudoers` file (Sudoers allows particular users to run various commands as the root user, without needing the root password): `sudo visudo`

- Add the line `<username> ALL=NOPASSWD:<path to rsync>`, where username is the login name of the user that rsync will use to log on (in our case `riauser`). That user must be able to use sudo. (e.g. `riauser ALL=NOPASSWD:/bin/rsync`)

- Add `--rsync-path="sudo rsync` to the rsync in the Makefile locally

- Make sure the Host name in your `.ssh/config` correctly resembles the group code and country code
