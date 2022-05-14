# Switchboard Helm Chart

![License](https://img.shields.io/github/license/borchero/switchboard-chart)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/switchboard)](https://artifacthub.io/packages/search?repo=switchboard)

This repository contains the Helm chart as well as detailed instructions for deploying the
[Switchboard Kubernetes operator](https://github.com/borchero/switchboard). Please read through the
main repository's README to understand how Switchboard is operating.

## Prerequisites

Prior to installing Switchboard, you should make sure that your Kubernetes cluster runs the
following applications:

- [Traefik v2](https://github.com/traefik/traefik) with at least the `IngressRoute` CRD installed.
- [cert-manager](https://cert-manager.io) -- this might optionally be installed by this chart by
  setting `cert-manager.install` to `true`.
- [external-dns](https://github.com/kubernetes-sigs/external-dns) with the `DNSEndpoint` CRD
  enabled -- this might optionally be installed by this chart by setting `external-dns.install` to
  `true`.

## Installation

When installing Switchboard, you need to set the following parameters as a minimum:

- `config.targetService.name`: The name of the Kubernetes service to which DNS records should
  point. This is most likely your Traefik instance.
- `config.targetService.namespace`: The namespace of the Kubernetes service to which DNS records
  should point.

Then, you can run the installation as follows:

```bash
helm install \
    --set config.targetService.name=traefik \
    --set config.targetService.namespace=traefik \
    switchboard \
    oci://ghcr.io/borchero/charts/switchboard
```

Note that the above command requires Helm version `>= 3.7.0`. For Helm version `< 3.8.0`, you
additionally need to set `HELM_EXPERIMENTAL_OCI=1`.

## TLS Certificates

While Switchboard always creates a `Certificate` resource when asked to do so, the certificate
needs to be picked up by an issuer. Thus, you need to either create your own `Issuer` or
`ClusterIssuer` resource and reference it, or tell Switchboard how to verify domains in the ACME
challenge.

If you use your own issuer, you need to set the following configuration flags:

- `config.certificateIssuer.kind`: Either `Issuer` or `ClusterIssuer`.
- `config.certificateIssuer.name`: The name of the issuer with the provided kind. If kind is
  `Issuer`, the issuer must be in the same namespace as all the ingress routes for which TLS
  certificates ought to be created.

In case you let the Switchboard Helm chart create a `ClusterIssuer` for you, you need to specify at
least one [solver](https://cert-manager.io/docs/configuration/acme/#configuration):

- `certificateIssuer.create`: Needs to be set to `true`.
- `certificateIssuer.solvers`: An array of solvers exactly as in the `Issuer` CRD (consult the
  solver documentation).

## Filtering

Without specifying any selector, Switchboard processes _all_ `IngressRoute` objects in the cluster.
If you want to constrain the set of ingress routes that the operator processes, you can configure a
filter on the `kubernetes.io/ingress.class` annotation. For example, if you want Switchboard to
only process the ingress routes with an annotation of `external`, add the following flag:

```bash
--set config.selector.ingressClass=external
```
