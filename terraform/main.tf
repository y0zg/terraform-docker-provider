terraform {
  required_version = "> 0.12.0"
}

# Configure the Docker provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = "echo Build docker image"
  }
  provisioner "local-exec" {
    command = "docker build -t ${var.app_name}:test -f ../Dockerfile ../"
  }
}

resource "null_resource" "run_unittests" {
  provisioner "local-exec" {
    command = "docker rm -f ${var.app_name}-test-container 2> /dev/null || true"
  }
  provisioner "local-exec" {
    command = "echo Creation test docker container"
  }
  provisioner "local-exec" {
    command = "docker run -d --name ${var.app_name}-test-container ${var.app_name}:test"
  }
  provisioner "local-exec" {
    command = "echo Running Unit tests"
  }
  provisioner "local-exec" {
    command = "docker exec ${var.app_name}-test-container npm test"
  }
  provisioner "local-exec" {
    command = "echo Removing test docker container"
  }
  provisioner "local-exec" {
    command = "docker rm -f ${var.app_name}-test-container 2> /dev/null || true"
  }
  depends_on = [
    null_resource.docker_build
  ]
}

resource "null_resource" "check_response" {
  provisioner "local-exec" {
    command = "docker rm -f ${var.app_name}-test-container 2> /dev/null || true"
  }
  provisioner "local-exec" {
    command = "echo Creation test docker container"
  }
  provisioner "local-exec" {
    command = "docker run -d -p ${var.external_port}:${var.internal_port} --name ${var.app_name}-test-container node-app:test"
  }
  provisioner "local-exec" {
    command = "echo Checking response"
  }
  provisioner "local-exec" {
    command = <<EOT
      [ "$(wget --spider -S "http://localhost:${var.external_port}" 2>&1 | grep "HTTP/" | awk '{print $2}')" == 200 ] && echo Response code: 200
    EOT
  }
  provisioner "local-exec" {
    command = "echo Removing test docker container"
  }
  provisioner "local-exec" {
    command = "docker rm -f ${var.app_name}-test-container 2> /dev/null || true"
  }

  depends_on = [
    null_resource.docker_build,
    null_resource.run_unittests
  ]
}

resource "null_resource" "push_docker_image" {
  provisioner "local-exec" {
    command = "echo Sending docker image to Docker hub"
  }
  provisioner "local-exec" {
    command = "docker tag ${var.app_name}:test ${var.dockerhub_repo}/${var.app_name}"
  }
  provisioner "local-exec" {
    command = "docker push ${var.dockerhub_repo}/${var.app_name}"
  }
  depends_on = [
    null_resource.docker_build,
    null_resource.run_unittests,
    null_resource.check_response
  ]
}