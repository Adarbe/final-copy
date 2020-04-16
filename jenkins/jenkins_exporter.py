import json
import time
import urllib2
from prometheus_client import start_http_server
from prometheus_client.core import GaugeMetricFamily, REGISTRY

class JenkinsCollector(object):
  def collect(self):
    metric = GaugeMetricFamily(
        'jenkins_job_last_successful_build_timestamp_seconds',
        'Jenkins build timestamp in unixtime for lastSuccessfulBuild',
        labels=["jobname"])

    result = json.load(urllib2.urlopen(
        "http://jenkins:8080/api/json?tree="
        + "jobs[name,lastSuccessfulBuild[timestamp]]"))

    for job in result['jobs']:
      name = job['name']
      # If there's a null result, we want to export a zero.
      status = job['lastSuccessfulBuild'] or {}
      metric.add_metric([name], status.get('timestamp', 0) / 1000.0)

    yield metric

if __name__ == "__main__":
  REGISTRY.register(JenkinsCollector())
  start_http_server(9118)
  while True: time.sleep(1)