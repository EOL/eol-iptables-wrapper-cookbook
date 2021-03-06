include_recipe "simple_iptables"

# Always allow ssh (for now--we will whitelist this later, I suspect):
simple_iptables_rule "ssh" do
  rule "--proto tcp --dport 22"
  jump "ACCEPT"
end

# Check for protocols:
dbag = data_bag_item("iptables", node.environment)
node_conf = dbag[node.name]

unless node_conf.nil?
  # SORRY! I am being supremely lazy and copying this block twice, for
  # allow/block.
  unless node_conf["allowed_protocols"].nil?
    node_conf["allowed_protocols"].each do |protocol|
      case protocol
      when "http"
        simple_iptables_rule "http" do
          rule "--proto tcp --dport 80"
          jump "ACCEPT"
        end
      when "https"
        simple_iptables_rule "https" do
          rule "--proto tcp --dport 443"
          jump "ACCEPT"
        end
      when "http_8080"
        simple_iptables_rule "http_8080" do
          rule "--proto tcp --dport 8080"
          jump "ACCEPT"
        end
      when "http_8081"
        simple_iptables_rule "http_8081" do
          rule "--proto tcp --dport 8081"
          jump "ACCEPT"
        end
      when "http_8082"
        simple_iptables_rule "http_8082" do
          rule "--proto tcp --dport 8082"
          jump "ACCEPT"
        end
      when "http_8083"
        simple_iptables_rule "http_8083" do
          rule "--proto tcp --dport 8083"
          jump "ACCEPT"
        end
      when "rsync"
        simple_iptables_rule "rsync" do
          rule "--proto tcp --dport 22"
          jump "ACCEPT"
        end
      when "redis"
        simple_iptables_rule "redis" do
          rule "--proto tcp --dport 6379"
          jump "ACCEPT"
        end
      when "memcached"
        simple_iptables_rule "memcached" do
          rule "--proto tcp --dport 11211"
          jump "ACCEPT"
        end
      when "solr"
        simple_iptables_rule "solr" do
          rule "--proto tcp --dport 8983"
          jump "ACCEPT"
        end
      when "rabbit-mq"
        simple_iptables_rule "rabbit-mq" do
          rule "--proto tcp --dport 5671"
          jump "ACCEPT"
        end
      when "node.js"
        simple_iptables_rule "node.js" do
          rule "--proto tcp --dport 3000"
          jump "ACCEPT"
        end
      when "mysql"
        simple_iptables_rule "mysql" do
          rule "--proto tcp --dport 3306"
          jump "ACCEPT"
        end
      when "sysopia"
        simple_iptables_rule "sysopia" do
          rule "--proto tcp --dport 9999"
          jump "ACCEPT"
        end
      when "virtuoso"
        simple_iptables_rule "virtuoso" do
          rule ["--proto tcp --dport 1111",
                "--proto tcp --dport 8890"]
          jump "ACCEPT"
        end
      else
        raise "I do not understand the #{protocol} protocol."
      end
    end
  end

  unless node_conf["block_protocols"].nil?
    node_conf["block_protocols"].each do |protocol|
      case protocol
      when "http"
        simple_iptables_rule "http" do
          rule "--proto tcp --dport 80"
          jump "DROP"
        end
      when "https"
        simple_iptables_rule "https" do
          rule "--proto tcp --dport 443"
          jump "DROP"
        end
      when "http_8080"
        simple_iptables_rule "http_8080" do
          rule "--proto tcp --dport 8080"
          jump "DROP"
        end
      when "http_8081"
        simple_iptables_rule "http_8081" do
          rule "--proto tcp --dport 8081"
          jump "DROP"
        end
      when "http_8082"
        simple_iptables_rule "http_8082" do
          rule "--proto tcp --dport 8082"
          jump "DROP"
        end
      when "http_8083"
        simple_iptables_rule "http_8083" do
          rule "--proto tcp --dport 8083"
          jump "DROP"
        end
      when "rsync"
        simple_iptables_rule "rsync" do
          rule "--proto tcp --dport 22"
          jump "DROP"
        end
      when "redis"
        simple_iptables_rule "redis" do
          rule "--proto tcp --dport 6379"
          jump "DROP"
        end
      when "memcached"
        simple_iptables_rule "memcached" do
          rule "--proto tcp --dport 11211"
          jump "DROP"
        end
      when "solr"
        simple_iptables_rule "solr" do
          rule "--proto tcp --dport 8983"
          jump "DROP"
        end
      when "rabbit-mq"
        simple_iptables_rule "rabbit-mq" do
          rule "--proto tcp --dport 5671"
          jump "DROP"
        end
      when "node.js"
        simple_iptables_rule "node.js" do
          rule "--proto tcp --dport 3000"
          jump "DROP"
        end
      when "mysql"
        simple_iptables_rule "mysql" do
          rule "--proto tcp --dport 3306"
          jump "DROP"
        end
      when "sysopia"
        simple_iptables_rule "sysopia" do
          rule "--proto tcp --dport 9999"
          jump "DROP"
        end
      when "virtuoso"
        simple_iptables_rule "virtuoso" do
          rule ["--proto tcp --dport 1111",
                "--proto tcp --dport 8890"]
          jump "DROP"
        end
      else
        raise "I do not understand the #{protocol} protocol."
      end
    end
  end
end

# Some intelligent defaults:

simple_iptables_rule "established" do
  rule "-m state --state ESTABLISHED,RELATED"
  jump "ACCEPT"
end

simple_iptables_rule "ping" do
  rule "--proto icmp"
  jump "ACCEPT"
end

simple_iptables_rule "local" do
  rule "--in-interface lo"
  jump "ACCEPT"
end

simple_iptables_rule "prohibited" do
  rule "--reject-with icmp-host-prohibited"
  jump "REJECT"
end

# simple_iptables_rule "forward prohibited" do
  # direction "FORWARD"
  # rule "--reject-with icmp-host-prohibited"
  # jump "REJECT"
# end

if node_conf &&
   node_conf["default_drop"] &&
   node_conf["default_drop"].downcase == "true"
  simple_iptables_policy "INPUT" do
    policy "DROP"
  end
end

