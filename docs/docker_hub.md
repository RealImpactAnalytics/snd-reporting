# How to enable pull images access on Docker Hub for delivery repositories

Our deployments mainly consist of components packaged as Docker Images published to `riaktr` organization on [Docker Hub](https://hub.docker.com/orgs/riaktr/repositories).
We try as much as possible to push the requirement of each deployment having direct pull access to Docker Hub to simplify and streamline deployments, upgrades and other operations. We then rely on each deployment having a dedicated access we can track and eventually remove it if really required (for instance if the client doesn't pay the product licenses).

A `riaktr-delivery` account has been created on Docker Hub. This users centralises the managements of all deployment accesses to Docker Hub. This account uses [riaktr-delivery@realimpactanalytics.com](https://groups.google.com/a/realimpactanalytics.com/g/riaktr-delivery) as an email. The process of (re)creating that user, if required is described below.

This article describes how to give pull access to a deployment setup leveraging our technical user.

> You might not have permission for some of these steps. Don't hesitate to ask help from the Support team. They are great guys and they don't bite.

## Create a dedicated access token for your delivery repository

1. Login with `riaktrdelivery` account on [Docker Hub](https://hub.docker.com) using [Vault information](https://vault-cloud.rianet.io/ui/vault/secrets/secret/show/Global_customer_credentials/docker-deploy-tokens)
  * Use username and password
2. Then go to the user [Account Settings > Security](https://hub.docker.com/settings/security)
3. Click on ***New Access Token***
   1. Enter Access Token Description following the naming convention <telco>-<country>
   2. Select READ-ONLY as the permission level
   3. Copy the generated access token and keep it carefully
   4. Create a [dedicated Vault Secret](https://vault-cloud.rianet.io/ui/vault/secrets/secret/show/Global_customer_credentials/docker-deploy-tokens) under `riaktrdelivery-tokens`
      1. key   => < access token description >
      2. value => < generated access token content you have copied >

You can now use this access token (content) instead of `riaktrdelivery` password on deployment servers.

To do so you first need to logout from the previously registered account (if there was one) by running:

  ```bash
  # Ensure you are logged in on the server with the deployment user, usually root
  docker logout
  ```

Then you can login with the new credentials
  ```bash
  docker login
  Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
  Username: riaktrdelivery
  Password:
  Login Succeeded
  ```

You can now pull riaktr docker images!

### Test pull

```bash
docker pull riaktr/base:3.12
```

### Remove an existing access token

In some case you might need to remove or regenerate an existing access token. To do so you can delete it by clicking on the target access token edit options on the rigth of the [tokens table](https://hub.docker.com/settings/security) and click on ***DELETE*** button.
