module "prometheus_deploy" {
  source  = "fuchicorp/chart/helm"
  deployment_name        = "prometheus-deploy"
  deployment_environment = "${var.deployment_environment}"
  deployment_endpoint    = "prometheus.${var.google_domain_name}"
  deployment_path        = "prometheus"

  template_custom_vars = {

    null_depends_on          = "${null_resource.helm_init.id}"

  }


}