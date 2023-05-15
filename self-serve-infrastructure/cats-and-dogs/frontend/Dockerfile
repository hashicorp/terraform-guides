# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

FROM    tiangolo/uwsgi-nginx-flask:python3.6

RUN     pip install redis hvac
 
ADD     /azure-vote /app
