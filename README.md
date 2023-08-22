# Test OIDC-enabled Coder deployment

> Note: this deployment is completely stateless and is intended for testing purposes only. All data is lost when the deployment is stopped.

- Edit `env.example` and rename it to `.env`:
  - `CODER_ACCESS_URL` must be the externally-accessible URL of the Coder instance.
  - `CODER_VERSION` determines the version of Coder to use. If unsure, use `latest`.
  - `EXTERNAL_IP` is the external IP address of the machine running this deployment.
  - `KEYCLOAK_ISSUER_URL` should be the publicly-accessible URL of the Keycloak instance.
- Run `./run.sh` to bring up the deployment. You can then access the deploment using the URL specified in `CODER_ACCESS_URL`.
