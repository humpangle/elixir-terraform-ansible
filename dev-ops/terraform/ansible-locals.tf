locals {
  ansible_host_yaml_content = join(
    "\n",
    [
      "all:",
      "  children:",
      "    remote:",
      "      hosts:",
      "        ${var.HOST_NAME}:",
      "          ansible_host: ${aws_instance.web.public_ip}",
      "          ansible_private_key_file: ${local.ssh_private_key_filename}",
      "          ansible_user: ubuntu",
      "",
    ]
  )
}

locals {
  ansible_deploy_yaml_content = join(
    "\n",
    [
      "- name: Run docker",
      "  hosts: ${var.HOST_NAME}",
      "  become: true",
      "  tasks:",
      "    - name: Update apt cache",
      "      ansible.builtin.apt:",
      "        update_cache: true",
      "",
      "    - name: Install Docker dependencies",
      "      ansible.builtin.apt:",
      "        name:",
      "          - python3-pip",
      "        state: present",
      "",
      "    - name: Copy environment file to host",
      "      ansible.builtin.copy:",
      "        src: ${var.ENV_FILENAME_TEMPORARY}",
      "        dest: ${var.ENV_FILENAME}",
      "        mode: \"0400\"",
      "",
      "    - name: Run Docker container  # noqa xx",
      "      ansible.builtin.command:",
      "        chdir: ${var.APP_DEPLOY_ROOT}",
      "        argv:",
      "          - docker",
      "          - run",
      "          - -d",
      "          - --name",
      "          - ${var.CONTAINER_NAME}",
      "          - -p",
      "          - ${var.DOCKER_PUBLISHED_SERVER_LISTEN_PORT}:${var.PORT}",
      "          - --env-file=${var.ENV_FILENAME}",
      "          - ${var.CONTAINER_IMAGE_NAME}",
      "      register: docker_run",
      "      changed_when: docker_run.rc != 0",
      "",
    ]
  )
}
