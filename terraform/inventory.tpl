[webservers]
%{ for ip in webservers ~}
${ip}
%{ endfor ~}

[dbservers]
${dbserver}

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3
