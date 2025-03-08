# This file is part of REANA.
# Copyright (C) 2025 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

FROM ghcr.io/dask/dask-kubernetes-operator:2025.1.1

# Configure shell options
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY requirements.txt /code/

USER root

RUN pip install --no-cache-dir -r /code/requirements.txt

WORKDIR /code
COPY . /code

# Are we debugging?
ARG DEBUG=0
RUN if [ "${DEBUG}" -gt 0 ]; then pip install --no-cache-dir -e ".[debug]"; else pip install --no-cache-dir .; fi;

RUN if test -e modules/reana-commons; then \
      if [ "${DEBUG}" -gt 0 ]; then \
        pip install --no-cache-dir -e "modules/reana-commons[kubernetes]" --upgrade; \
      else \
        pip install --no-cache-dir "modules/reana-commons[kubernetes]" --upgrade; \
      fi \
    fi; \
    if test -e modules/reana-db; then \
      if [ "${DEBUG}" -gt 0 ]; then \
        pip install --no-cache-dir -e "modules/reana-db" --upgrade; \
      else \
        pip install --no-cache-dir "modules/reana-db" --upgrade; \
      fi \
    fi


# Check for any broken Python dependencies
RUN pip check

USER 1000

LABEL org.opencontainers.image.authors="team@reanahub.io"
LABEL org.opencontainers.image.created="CHANGE_ME??2024-03-04"
LABEL org.opencontainers.image.description="REANA reproducible analysis platform - dask kubernetes operator component"
LABEL org.opencontainers.image.documentation="DO_WE_NEED_THIS https://reana-dask-kubernetes-operator.readthedocs.io/"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/reanahub/reana-dask-kubernetes-operator"
LABEL org.opencontainers.image.title="reana-dask-kubernetes-operator"
LABEL org.opencontainers.image.url="https://github.com/reanahub/reana-dask-kubernetes-operator"
LABEL org.opencontainers.image.vendor="reanahub"
# x-release-please-start-version
LABEL org.opencontainers.image.version="CHANGE_ME ?? 0.95.0-alpha.2"
# x-release-please-end
