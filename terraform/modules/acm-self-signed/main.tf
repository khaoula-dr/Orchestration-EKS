# Génère un certificat auto-signé et l'importe dans ACM .
# Alternative à un vrai certificat validé par domaine, utilisable sans
# posséder de nom de domaine. Le provider "tls" est déjà déclaré dans
# providers.tf racine (utilisé aussi par le module eks).

resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "demo" {
  private_key_pem = tls_private_key.demo.private_key_pem

  subject {
    common_name  = var.common_name
    organization = "Smartovate Ltd - Demo"
  }

  validity_period_hours = 8760 # 1 an

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "demo" {
  private_key      = tls_private_key.demo.private_key_pem
  certificate_body = tls_self_signed_cert.demo.cert_pem

  tags = {
    Name = "${var.project_name}-demo-self-signed"
  }

  lifecycle {
    create_before_destroy = true
  }
}