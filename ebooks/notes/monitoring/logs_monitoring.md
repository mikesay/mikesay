# Logs collecting and monitoring

## Solutions to sync Alibaba Cloud SLS to OpenTelemetry
Leverage Logstash [SLS input plugin](https://help.aliyun.com/zh/sls/user-guide/use-logstash-to-consume-log-data?spm=a2c4g.11186623.0.0.7ac05d36tRoCPk) to consume SLS logstore in real-time, and [Logstash OpenTelemetry output plugin](https://github.com/paulgrav/logstash-output-opentelemetry) to send logs to OpenTelemetry Collector which will in turn export logs to log backend like Loki.  

Logstash pipeline configuration:  

```yaml
pipelines.yml: |-
    - pipeline.id: main
      config.string: |
        input {
            logservice{
                endpoint => "cn-shanghai-intranet.log.aliyuncs.com"
                access_id => ${ALIBABA_CLOUD_ACCESS_KEY_ID}
                access_key => ${ALIBABA_CLOUD_ACCESS_KEY_SECRET}
                project => "log-ilab-ack"
                logstore => "apiserver-c8f625e15bbf24b0f8244d9075469dafd"
                consumer_group => "quickstart"
                consumer_name => "quickstart-apiserver"
                position => "end"
                checkpoint_second => 30
                include_meta => true
                consumer_name_with_ip => true
            }
        }
        output {
            stdout {}
            opentelemetry {
                endpoint => "http://otel-collector-opentelemetry-collector.otel-collector:4317"
                protocol => "grpc"
                compression => "none"
                body => "[content]"
                name => "[_container_name_]"
            }
      }
```