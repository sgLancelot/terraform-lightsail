output "ip" {
  value = "${aws_lightsail_static_ip.static_ip.ip_address}"
}

output "wordpress_url" {
  value = "${aws_route53_record.no_www.name}"
}

output "www_wordpress_url" {
  value = "${aws_route53_record.www.name}"
}
