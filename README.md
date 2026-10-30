# opencloud-idp-assets

Prebuilt web assets of the embedded identity provider of
[OpenCloud](https://github.com/opencloud-eu/opencloud) (`services/idp`).

They are static files and do not depend on the platform. They exist so that
the FreeBSD port `www/opencloud` can be built without Node.js and without
network access (poudriere).

## Versioning

| What | Value |
|------|-------|
| Release tag | `v<upstream version>`, e.g. `v9.0.0` |
| Asset | `opencloud-idp-assets-<upstream version>.tar.gz` |
| Checksum | `opencloud-idp-assets-<upstream version>.tar.gz.sha256` |

The version always equals the upstream OpenCloud tag the assets were built
from. If the same upstream version has to be rebuilt (for example the build
recipe was wrong), run the workflow with `revision` set to `1`, `2`, ...
That creates the tag `v9.0.0-r1` and the asset
`opencloud-idp-assets-9.0.0-r1.tar.gz`.

Releases are never overwritten: the checksum is recorded in the port's
`distinfo`. Turn on "immutable releases" in the repository settings to have
GitHub enforce this.

## Building

The workflow `Build OpenCloud IdP assets`:

- runs every Monday and builds the latest upstream release when it has no
  release here yet,
- can be started manually (Actions, Run workflow) with a specific `version`.

The archive is built with `scripts/build.sh`, which repeats the steps of
upstream's `services/idp/Makefile`. It uses the pnpm version pinned in
upstream's `package.json`. The same script works locally:

    git clone --depth 1 --branch v9.0.0 https://github.com/opencloud-eu/opencloud src
    sh scripts/build.sh "$PWD/src" "$PWD/dist/opencloud-idp-assets-9.0.0.tar.gz"

## Use in the port

    MASTER_SITES=	https://github.com/opencloud-eu/web/releases/download/${WEB_ASSETS_VERSION}/:web \
    		https://github.com/USER/opencloud-idp-assets/releases/download/v${DISTVERSION}/:idp
    DISTFILES=	web.tar.gz:web \
    		${PORTNAME}-idp-assets-${DISTVERSION}.tar.gz:idp

and in `post-extract`:

    @${TAR} -xzf ${_DISTDIR}/${PORTNAME}-idp-assets-${DISTVERSION}.tar.gz \
    	-C ${WRKSRC}/services/idp

When the port is updated: wait for the release `v<new version>` here, bump
`DISTVERSION` and `WEB_ASSETS_VERSION`, run `make makesum`.
