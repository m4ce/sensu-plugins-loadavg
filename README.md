# Sensu plugin for monitoring the system's load average

A sensu plugin to monitor the system's load average

## Usage

The plugin accepts the following command line options:

```
Usage: check-loadavg.rb (options)
    -c, --critical <avg1,avg5,avg15> Critical if avg1/5/15 exceeds the current system load average (default: 16.0,12.0,8.0)
    -w, --warn <avg1,avg5,avg15>     Warn if avg1/5/15 exceeds the current system load average (default: 12.0,8.0,4.0)
```

The default warning thresholds are calculated as follows:

```
  avg15 = processorcount * 2
  avg5 = avg15 + 4
  avg1 = avg5 + 4
```

The default critical thresholds are calculated as follows:

```
  avg15 = processorcount * 4
  avg5 = avg15 + 4
  avg1 = avg5 + 4
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
