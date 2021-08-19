extensions:
  pprof:
    endpoint: 0.0.0.0:1777
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:${grpc_port}

processors:
  batch:

exporters:
  logging:
    loglevel: debug
  otlphttp/1:
    traces_endpoint: "https://${mock_endpoint}"
    insecure: true
  otlphttp/2:
    traces_endpoint: SUMO_ENDPOINT

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp/1, otlphttp/2]
  extensions: [pprof]