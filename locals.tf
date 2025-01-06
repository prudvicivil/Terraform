locals {
    env = var.environment
    instance_name_set = toset(var.aws_ec2_instances)
    ingress_rules = [{
        port = 9090 
        description = "ingress for port 9090"
    },

    {
        port = 8080 
        description ="ingress for port 8080"
    }]
}
