## Author: Zhen Kai (zhenkai.xyz)
## Date: 24th January 2020
## Purpose: Create AWS Lightsail Instance, map static external IP address to instance and configure Route53
## Version: 1.0.0
## Notes: Refer to terraform.io/docs/providers/aws/r/lightsail_instance.html for further details on the lightsail resource

## refers to ~/.aws/credentials. AWS CLI credentials
provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

## Creates an AWS Lightsail Instance.
resource "aws_lightsail_instance" "lightsail_instance" {
  name              = "instance_name" ## Name of lightsail instance in AWS
  availability_zone = "ap-southeast-1a"
  blueprint_id      = var.lightsail_blueprints["wordpress"] ## Options for "wordpress", "wordpress_multi" or "nginx"
  bundle_id         = "nano_2_0"                            ## Options for instance size
}

## Creates a static public IP address on Lightsail
resource "aws_lightsail_static_ip" "static_ip" {
  name = "static_ip_name" ## Name of static IP in AWS
}

## Attaches static IP address to Lightsail instance
resource "aws_lightsail_static_ip_attachment" "static_ip_attach" {
  static_ip_name = aws_lightsail_static_ip.static_ip.id
  instance_name  = aws_lightsail_instance.lightsail_instance.id
}

## Creates a new Route53 Public Hosted Zone. Uncomment below if you don't have an existing hosted zone.
## resource "aws_route53_zone" "hosted_zone" {
##   name = "example.com" ## Enter your domain name here
## }

## Points to your existing Route 53 public hosted zone. Remove this if you are creating a new Public Hosted Zone
data "aws_route53_zone" "hosted_zone" {
  name = "example.com." ## Enter your domain name here
}

## Creates a Route 53 record for your static Lightsail IP address without www.
resource "aws_route53_record" "no_www" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}" ## Delete "data." if you are creating a new hosted zone
  name    = "${data.aws_route53_zone.hosted_zone.name}"    ## Delete "data." if you are creating a new hosted zone
  type    = "A"
  ttl     = "300"
  records = ["${aws_lightsail_static_ip.static_ip.ip_address}"]
}

## Creates a Route 53 record for your static Lightsail IP address with www.
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"  ## delete "data." if you are creating a new hosted zone
  name    = "www.${data.aws_route53_zone.hosted_zone.name}" ## delete "data." if you are creating a new hosted zone
  type    = "A"
  ttl     = "300"
  records = ["${aws_lightsail_static_ip.static_ip.ip_address}"]
}