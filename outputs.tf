output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.nginx_bucket.bucket
}
