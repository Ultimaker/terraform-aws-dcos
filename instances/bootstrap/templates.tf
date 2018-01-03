data "template_file" "ip-detect" {
  template = "${file("${path.module}/template/ip-detect.tpl")}"
}

data "template_file" "ip-detect-public" {
  template = "${file("${path.module}/template/ip-detect-public.tpl")}"
}
