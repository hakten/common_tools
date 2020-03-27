module "ingress_controller" {
  source  = "fuchicorp/chart/helm"
  deployment_name        = "ingress-controller-${var.deployment_environment}"
  deployment_environment = "${var.deployment_environment}"
  deployment_endpoint    = "ingress-controller.${var.google_domain_name}"
  deployment_path        = "./ingress-controller"

    template_custom_vars    = {
    null_depends_on       = "${null_resource.helm_init.id}"
    google_project        = "${var.google_project_id}"
  }

}


