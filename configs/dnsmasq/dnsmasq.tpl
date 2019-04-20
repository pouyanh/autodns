# This is automatically generated by docker-gen
{{$host_ip := (or .Env.HOST_IP "172.17.0.1")}}

{{range $hostname, $containers := groupByMulti . "Env.HOSTNAME" ","}}
  {{$container := (index $containers 0)}}
  {{$network := (index $container.Networks 0)}}
  {{$env := $container.Env}}

  {{if gt (len $containers) 1}}
{{$host_ip}} {{$hostname}}
  {{else}}
    {{if eq $network.Name "host"}}
{{$host_ip}} {{$hostname}}
    {{else}}
{{$network.IP}} {{$hostname}}
    {{end}}
  {{end}}
{{end}}
