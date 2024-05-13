FROM public.ecr.aws/example/helm-chart-publisher-base:latest

WORKDIR /

COPY ./pack.sh /

ENTRYPOINT ["/pack.sh"]
