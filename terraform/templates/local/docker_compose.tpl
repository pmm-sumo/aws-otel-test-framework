version: "3.8"
services:
  mocked-server:
    build:
      context: ../../mocked_servers/${mocked_server}
    ports:
      - 80:8080
      - 55671:55671

  aws-ot-collector:
    build:
      context: ../../../aws-otel-collector
      dockerfile: cmd/awscollector/Dockerfile

    command: ["--config=/tmp/otconfig.yaml", "--log-level=DEBUG"]
    volumes:
      - ./otconfig.yml:/tmp/otconfig.yaml
    environment:
      - AWS_REGION=${region}
      # faked credentials
      - AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
      - AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
      - GODEBUG=x509ignoreCN=0
    depends_on:
      - mocked-server

  sample_app:
    image: ${sample_app_image}
    ports:
      - "${sample_app_external_port}:${sample_app_listen_address_port}"
    environment:
      - LISTEN_ADDRESS=${sample_app_listen_address}
      - AWS_REGION=${region}
      - OTEL_RESOURCE_ATTRIBUTES=${otel_resource_attributes}
      - INSTANCE_ID=${testing_id}
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://aws-ot-collector:${grpc_port}
      - AWS_XRAY_DAEMON_ADDRESS=aws-ot-collector:${udp_port}
      - COLLECTOR_UDP_ADDRESS=aws-ot-collector:${udp_port}
      - JAEGER_RECEIVER_ENDPOINT=aws-ot-collector:${http_port}
      - ZIPKIN_RECEIVER_ENDPOINT=aws-ot-collector:${http_port}
    depends_on:
      - aws-ot-collector
