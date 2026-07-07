FROM alpine:3.20

RUN apk add --no-cache bash git helm jq py3-pip \
 && pip install --no-cache-dir --break-system-packages yq

WORKDIR /

COPY ./pack.sh /

ENTRYPOINT ["/pack.sh"]
