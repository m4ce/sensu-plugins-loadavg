#!/usr/bin/env ruby
#
# check-loadavg.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'

class CheckLoadAvg < Sensu::Plugin::Check::CLI
  def self.processor_count()
    %x[cat /proc/cpuinfo].scan(/^processor/).count
  end

  def self.default_thresholds(magic)
    avg15 = (self.processor_count * magic).to_f
    avg5 = (avg15 + 4).to_f
    avg1 = (avg5 + 4).to_f

    {'1m' => avg1, '5m' => avg5, '15m' => avg15}
  end

  def self.thresholds_to_hash(str)
    th = {}
    th['1m'], th['5m'], th['15m'] = str.split(',').map(&:to_f)
    th
  end
    
  option :warn,
         :description => "Warn if avg1/5/15 exceeds the current system load average (default: #{default_thresholds(2).map { |k, v| v }.join(',')})",
         :short => "-w <avg1,avg5,avg15>",
         :long => "--warn <avg1,avg5,avg15>",
         :default => default_thresholds(2),
         :proc => proc { |s| thresholds_to_hash(s) }

  option :crit,
         :description => "Critical if avg1/5/15 exceeds the current system load average (default: #{default_thresholds(4).map { |k, v| v }.join(',')})",
         :short => "-c <avg1,avg5,avg15>",
         :long => "--critical <avg1,avg5,avg15>",
         :default => default_thresholds(4),
         :proc => proc { |s| thresholds_to_hash(s) }

  def initialize()
    super
    @loadavg = get_loadavg

    # sanity checks
    ['1m', '5m', '15m'].each do |i|
      raise "Warning #{i} threshold must be lower than the #{i} critical threshold" if config[:warn][i] >= config[:crit][i]
    end
  end

  def get_loadavg()
    la = {}
    la['1m'], la['5m'], la['15m'] = %x[cat /proc/loadavg].split(' ')[0..2].map(&:to_f)
    la
  end

  def run
    ['1m', '5m', '15m'].each do |i|
      critical("Load average over the last #{i} is too high (#{@loadavg[i]} >= #{config[:crit][i]})") if @loadavg[i] >= config[:crit][i]
    end

    ['1m', '5m', '15m'].each do |i|
      warning("Load average over the last #{i} is high (#{@loadavg[i]} >= #{config[:warn][i]})") if @loadavg[i] >= config[:warn][i]
    end

    ok("Load average is normal #{@loadavg.inspect}")
  end
end
